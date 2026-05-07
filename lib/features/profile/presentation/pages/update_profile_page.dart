import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../../../core/network/cloudinary_config.dart';
import '../../domain/entities/profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class UpdateProfilePage extends StatefulWidget {
  final ProfileEntity profile;

  const UpdateProfilePage({super.key, required this.profile});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _lastnameController;
  late final TextEditingController _emailController;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _lastnameController = TextEditingController(text: widget.profile.lastname);
    _emailController = TextEditingController(text: widget.profile.email);
    _avatarUrl = widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    final updatedProfile = ProfileEntity(
      id: widget.profile.id,
      username: widget.profile.username, // Maintain existing username
      name: _nameController.text,
      lastname: _lastnameController.text,
      email: _emailController.text,
      roles: widget.profile.roles,
      companyId: widget.profile.companyId,
      avatarUrl: _avatarUrl,
    );

    context.read<ProfileBloc>().add(ProfileUpdateRequested(updatedProfile));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
          context.pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Update Profile',
            style: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    ImageUploadPicker(
                      initialImageUrl: _avatarUrl,
                      onImageUploaded: (url) {
                        setState(() {
                          _avatarUrl = url;
                        });
                      },
                      imageType: ImageType.avatar,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to change photo',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Form Fields
              CustomTextField(
                hintText: 'First Name',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Last Name',
                controller: _lastnameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Email',
                controller: _emailController,
              ),
              const SizedBox(height: 48),
              
              // Action Button
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  return PrimaryButton(
                    text: 'Save Changes',
                    isLoading: state is ProfileUpdating,
                    onPressed: _onUpdate,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
