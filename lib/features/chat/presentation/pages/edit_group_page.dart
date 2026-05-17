import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/cloudinary_config.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../domain/entities/group_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Edit a group's name / description / image (`PUT /api/v1/groups/{id}`,
/// `UpdateGroupResource`). Visibility and membership use separate endpoints
/// and are intentionally out of scope here.
class EditGroupPage extends StatefulWidget {
  final GroupEntity group;

  const EditGroupPage({super.key, required this.group});

  @override
  State<EditGroupPage> createState() => _EditGroupPageState();
}

class _EditGroupPageState extends State<EditGroupPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.group.name);
  late final TextEditingController _descriptionController =
      TextEditingController(text: widget.group.description ?? '');

  late String? _imageUrl = widget.group.imageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChatBloc>().add(
          UpdateGroupRequested(
            groupId: widget.group.id,
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            imageUrl:
                (_imageUrl != null && _imageUrl!.isNotEmpty) ? _imageUrl : null,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Edit group',
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
          if (state is GroupUpdated) {
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
          final saving = state is GroupUpdating;
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

                    ImageUploadPicker(
                      initialImageUrl: _imageUrl,
                      onImageUploaded: (url) =>
                          setState(() => _imageUrl = url),
                      imageType: ImageType.chat,
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.onSurface,
                          foregroundColor: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: saving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.surface,
                                ),
                              )
                            : const Text(
                                'Save Changes',
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
      hintStyle:
          TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
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
