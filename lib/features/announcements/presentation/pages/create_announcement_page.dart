import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../../../core/network/cloudinary_config.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../domain/entities/announcement_entity.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';

class CreateAnnouncementPage extends StatefulWidget {
  final AnnouncementEntity? announcement;

  const CreateAnnouncementPage({super.key, this.announcement});

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'NORMAL';
  String? _uploadedImageUrl;

  final List<String> _priorities = ['NORMAL', 'HIGH', 'URGENT'];

  bool get _isEditMode => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.announcement;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _priority = _priorities.contains(existing.priority)
          ? existing.priority
          : 'NORMAL';
      _uploadedImageUrl = existing.image;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.announcement;
    if (existing != null) {
      context.read<AnnouncementBloc>().add(
            UpdateAnnouncementRequested(
              id: existing.id,
              title: _titleController.text,
              description: _descriptionController.text,
              priority: _priority,
              image: _uploadedImageUrl,
            ),
          );
      return;
    }

    final profileState = context.read<ProfileBloc>().state;
    String userId = '00000000-0000-0000-0000-000000000000'; // Fallback

    if (profileState is ProfileLoaded) {
      userId = profileState.profile.id;
    } else if (profileState is ProfileUpdateSuccess) {
      userId = profileState.profile.id;
    }

    context.read<AnnouncementBloc>().add(
          CreateAnnouncementRequested(
            title: _titleController.text,
            description: _descriptionController.text,
            priority: _priority,
            image: _uploadedImageUrl,
            createdBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<AnnouncementBloc, AnnouncementState>(
      listener: (context, state) {
        if (state is AnnouncementCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement published successfully!')),
          );
          context.pop();
        } else if (state is AnnouncementUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement updated successfully!')),
          );
          context.pop();
        } else if (state is AnnouncementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: colorScheme.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            _isEditMode ? 'Edit Announcement' : 'Create Announcement',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditMode ? "Edit Announcement" : "New Announcement",
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditMode
                        ? "Update the details below and save your changes."
                        : "Fill out the details below to broadcast a new announcement to your company feed.",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title Input
                  _buildLabel("Title", colorScheme),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _buildInputDecoration("Enter announcement title", colorScheme),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Priority Dropdown
                  _buildLabel("Priority", colorScheme),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _buildInputDecoration("Select priority", colorScheme),
                    items: _priorities.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          _priority = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description Input
                  _buildLabel("Description", colorScheme),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: _buildInputDecoration("Enter announcement details...", colorScheme),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Image Upload Component
                  ImageUploadPicker(
                    onImageUploaded: (url) {
                      setState(() {
                        _uploadedImageUrl = url;
                      });
                    },
                    imageType: ImageType.announcement,
                  ),
                  const SizedBox(height: 48),

                  // Submit Button
                  BlocBuilder<AnnouncementBloc, AnnouncementState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state is AnnouncementLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.onSurface,
                            foregroundColor: colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: state is AnnouncementLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.surface,
                                  ),
                                )
                              : Text(
                                  _isEditMode
                                      ? 'Save Changes'
                                      : 'Publish Announcement',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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

  InputDecoration _buildInputDecoration(String hint, ColorScheme colorScheme) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
      filled: true,
      fillColor: colorScheme.secondary.withValues(alpha: 0.1),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
