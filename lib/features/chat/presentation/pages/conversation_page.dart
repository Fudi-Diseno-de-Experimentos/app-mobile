import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/message_entity.dart';
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
  bool _convoRequested = false;

  // Mutable so an in-place group edit (3-dot) refreshes the title.
  late GroupEntity _group = widget.group;

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
            groupId: _group.id,
            senderId: senderId,
            body: text,
            isDirect: _group.isDirect,
          ),
        );
    _input.clear();
    _scrollToBottom();
  }

  Future<void> _openMessageMenu(MessageEntity m, Offset globalPos) async {
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        globalPos & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.destructive),
            title: Text(
              'Delete',
              style: TextStyle(color: AppColors.destructive),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
    if (!mounted) return;
    if (selected == 'edit') _editDialog(m);
    if (selected == 'delete') _confirmDelete(m);
  }

  void _editDialog(MessageEntity m) {
    final controller = TextEditingController(text: m.body);
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 1,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final body = controller.text.trim();
              Navigator.of(dialogCtx).pop();
              if (body.isEmpty || body == m.body) return;
              context
                  .read<MessageBloc>()
                  .add(EditMessage(messageId: m.messageId, body: body));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(MessageEntity m) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context
                  .read<MessageBloc>()
                  .add(DeleteMessage(m.messageId));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editGroup() async {
    final updated = await context.push<GroupEntity>(
      '/messages/edit-group',
      extra: _group,
    );
    if (!mounted || updated == null) return;
    setState(() => _group = updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name),
        actions: [
          if (!_group.isDirect)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit-group') _editGroup();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit-group',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Edit group'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
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

          if (profileState is ProfileLoaded && !_convoRequested) {
            _convoRequested = true;
            final companyId = profileState.profile.companyId ?? '';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<MessageBloc>().add(
                      LoadConversation(
                        _group.id,
                        isDirect: _group.isDirect,
                        companyId: companyId,
                      ),
                    );
              }
            });
          }

          return Column(
            children: [
              Expanded(
                child: BlocConsumer<MessageBloc, MessageState>(
                  listener: (context, state) {
                    if (state is ConversationLoaded) _scrollToBottom();
                    if (state is MessageActionFailed) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.destructive,
                        ),
                      );
                    }
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
                    final messages = state is ConversationLoaded
                        ? state.messages
                        : state is MessageActionFailed
                            ? state.messages
                            : null;
                    final senderNames = state is ConversationLoaded
                        ? state.senderNames
                        : state is MessageActionFailed
                            ? state.senderNames
                            : const <String, String>{};
                    if (messages != null) {
                      if (messages.isEmpty) {
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
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          final prev = i > 0 ? messages[i - 1] : null;
                          final mine = m.senderId == currentUserId;
                          final canModify = mine &&
                              !m.isPending &&
                              m.isVisible &&
                              m.status != 'DELETED';
                          // WhatsApp: show the sender label only on the
                          // first message of a consecutive run, groups only.
                          final showName = !_group.isDirect &&
                              !mine &&
                              (prev == null ||
                                  prev.senderId != m.senderId);
                          final name = showName
                              ? (senderNames[m.senderId] ?? '')
                              : '';
                          return _MessageRow(
                            key: ValueKey(m.messageId),
                            message: m,
                            isMine: mine,
                            senderName: name.isEmpty ? null : name,
                            canModify: canModify,
                            onMenu: (pos) => _openMessageMenu(m, pos),
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

/// A message row that "pops" (brief scale-up) on long-press, then surfaces a
/// dropdown of actions at the press point — WhatsApp-style. The pop plays for
/// every message; the menu only opens when [canModify] is true.
class _MessageRow extends StatefulWidget {
  final MessageEntity message;
  final bool isMine;
  final String? senderName;
  final bool canModify;
  final void Function(Offset globalPosition) onMenu;

  const _MessageRow({
    super.key,
    required this.message,
    required this.isMine,
    required this.senderName,
    required this.canModify,
    required this.onMenu,
  });

  @override
  State<_MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<_MessageRow> {
  bool _popped = false;

  Future<void> _onLongPressStart(LongPressStartDetails d) async {
    setState(() => _popped = true);
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (mounted) setState(() => _popped = false);
    if (widget.canModify) widget.onMenu(d.globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      child: AnimatedScale(
        scale: _popped ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: MessageBubble(
          message: widget.message,
          isMine: widget.isMine,
          senderName: widget.senderName,
        ),
      ),
    );
  }
}
