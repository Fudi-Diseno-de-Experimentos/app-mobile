import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
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
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _lastnameController = TextEditingController(text: widget.profile.lastname);
    _usernameController = TextEditingController(text: widget.profile.username);
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onUpdate() {
    final updatedProfile = ProfileEntity(
      id: widget.profile.id,
      username: _usernameController.text,
      name: _nameController.text,
      lastname: _lastnameController.text,
      email: _emailController.text,
      roles: widget.profile.roles,
      companyId: widget.profile.companyId,
      avatarUrl: widget.profile.avatarUrl,
    );

    context.read<ProfileBloc>().add(ProfileUpdateRequested(updatedProfile));
  }

  @override
  Widget build(BuildContext context) {
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
        appBar: AppBar(title: const Text('Update Profile')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                hintText: 'Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              CustomTextField(hintText: 'Email', controller: _emailController),
              const SizedBox(height: 48),
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
