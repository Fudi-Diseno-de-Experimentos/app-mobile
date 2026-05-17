import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/cloudinary_config.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../../profile/domain/entities/profile_entity.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/segmented_selector.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _visibilityIndex = 1; // 0 = PUBLIC, 1 = PRIVATE (default)
  String? _uploadedImageUrl;
  final Set<String> _selectedMemberIds = {};
  List<ProfileEntity> _members = const [];

  bool _membersRequested = false;
  bool _profileRequested = false;

  static const _visibilities = ['PUBLIC', 'PRIVATE'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(String currentUserId) {
    if (!_formKey.currentState!.validate()) return;

    final memberIds = <String>{currentUserId, ..._selectedMemberIds}.toList();

    context.read<ChatBloc>().add(
          CreateGroupRequested(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            imageUrl: _uploadedImageUrl,
            visibility: _visibilities[_visibilityIndex],
            memberIds: memberIds,
            createdBy: currentUserId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        if (profileState is ProfileInitial && !_profileRequested) {
          _profileRequested = true;
          context.read<ProfileBloc>().add(ProfileLoadRequested());
        }

        ProfileEntity? me;
        if (profileState is ProfileLoaded) {
          me = profileState.profile;
        } else if (profileState is ProfileUpdateSuccess) {
          me = profileState.profile;
        }

        if (me == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('New group')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final currentUserId = me.userId;
        final companyId = me.companyId;

        if (!_membersRequested && companyId != null && companyId.isNotEmpty) {
          _membersRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<ChatBloc>().add(LoadCompanyMembers(companyId));
            }
          });
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'New group',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
              onPressed: () => context.pop(),
            ),
          ),
          body: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is CompanyMembersLoaded) {
                setState(() => _members = state.members);
              } else if (state is GroupCreated) {
                context.pop(state.group);
              } else if (state is ChatError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              final creating = state is GroupCreating;
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Group Name', colorScheme),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration:
                              _decoration('Enter group name', colorScheme),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Please enter a name'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        _label('Description', colorScheme),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          style: TextStyle(color: colorScheme.onSurface),
                          decoration: _decoration(
                            'Optional group description...',
                            colorScheme,
                          ),
                        ),
                        const SizedBox(height: 24),

                        _label('Visibility', colorScheme),
                        SegmentedSelector(
                          labels: _visibilities,
                          selectedIndex: _visibilityIndex,
                          onChanged: (i) =>
                              setState(() => _visibilityIndex = i),
                        ),
                        const SizedBox(height: 24),

                        ImageUploadPicker(
                          onImageUploaded: (url) =>
                              setState(() => _uploadedImageUrl = url),
                          imageType: ImageType.chat,
                        ),
                        const SizedBox(height: 24),

                        _buildMemberPicker(
                          currentUserId,
                          colorScheme,
                          textTheme,
                          state,
                        ),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                creating ? null : () => _submit(currentUserId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.onSurface,
                              foregroundColor: colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: creating
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.surface,
                                    ),
                                  )
                                : const Text(
                                    'Create Group',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberPicker(
    String currentUserId,
    ColorScheme colorScheme,
    TextTheme textTheme,
    ChatState state,
  ) {
    final people =
        _members.where((m) => m.userId != currentUserId).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label('Add Members', colorScheme)),
            if (people.isNotEmpty)
              Text(
                '${_selectedMemberIds.length} selected',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (state is CompanyMembersLoading && _members.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (people.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'No members found for your organization.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          Column(
            children: people.map((m) {
              final selected = _selectedMemberIds.contains(m.userId);
              final initials =
                  '${m.name.isNotEmpty ? m.name[0] : ''}${m.lastname.isNotEmpty ? m.lastname[0] : ''}'
                      .toUpperCase();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.08)
                      : colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                child: CheckboxListTile(
                  value: selected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedMemberIds.add(m.userId);
                      } else {
                        _selectedMemberIds.remove(m.userId);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        colorScheme.secondary.withValues(alpha: 0.3),
                    backgroundImage:
                        (m.avatarUrl != null && m.avatarUrl!.isNotEmpty)
                            ? NetworkImage(m.avatarUrl!)
                            : null,
                    child: (m.avatarUrl == null || m.avatarUrl!.isEmpty)
                        ? Text(
                            initials,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    '${m.name} ${m.lastname}'.trim(),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    m.email,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  activeColor: colorScheme.primary,
                  checkColor: colorScheme.onPrimary,
                  controlAffinity: ListTileControlAffinity.trailing,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _label(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: colorScheme.secondary.withValues(alpha: 0.1),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorStyle: TextStyle(color: colorScheme.error),
    );
  }
}
