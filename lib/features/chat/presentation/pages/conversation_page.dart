import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/group_entity.dart';
import '../bloc/message_bloc.dart';
import '../bloc/message_event.dart';
import '../bloc/message_state.dart';
import '../widgets/message_bubble.dart';

class ConversationPage extends StatefulWidget {
  final GroupEntity group;

  const ConversationPage({super.key, required this.group});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _profileRequested = false;

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(
          LoadConversation(
            widget.group.id,
            isDirect: widget.group.isDirect,
          ),
        );
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String senderId) {
    final text = _input.text.trim();
    if (text.isEmpty || senderId.isEmpty) return;
    context.read<MessageBloc>().add(
          SendChatMessage(
            groupId: widget.group.id,
            senderId: senderId,
            body: text,
          ),
        );
    _input.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileInitial && !_profileRequested) {
            _profileRequested = true;
            context.read<ProfileBloc>().add(ProfileLoadRequested());
          }
          final currentUserId =
              profileState is ProfileLoaded
                  ? profileState.profile.userId
                  : '';

          return Column(
            children: [
              Expanded(
                child: BlocConsumer<MessageBloc, MessageState>(
                  listener: (context, state) {
                    if (state is ConversationLoaded) _scrollToBottom();
                  },
                  builder: (context, state) {
                    if (state is MessageLoading ||
                        state is MessageInitial) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (state is MessageError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(
                              color: AppColors.destructive),
                        ),
                      );
                    }
                    if (state is ConversationLoaded) {
                      if (state.messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet. Say hi 👋',
                            style: TextStyle(color: AppColors.tertiary),
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: state.messages.length,
                        itemBuilder: (context, i) {
                          final m = state.messages[i];
                          return MessageBubble(
                            message: m,
                            isMine: m.senderId == currentUserId,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              _buildInputBar(context, currentUserId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, String currentUserId) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(currentUserId),
                decoration: InputDecoration(
                  hintText: 'Message',
                  filled: true,
                  fillColor:
                      colorScheme.secondary.withValues(alpha: 0.12),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: () => _send(currentUserId),
              icon: const Icon(Icons.send),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
