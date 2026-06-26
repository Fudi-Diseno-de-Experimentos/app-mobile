import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/core/network/cloudinary_config.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_bloc.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_event.dart';
import 'package:app_mobile/features/company/presentation/bloc/company_state.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_bloc.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_event.dart';
import 'package:app_mobile/features/iam/presentation/bloc/iam_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:app_mobile/shared/widgets/custom_text_field.dart';
import 'package:app_mobile/shared/widgets/image_upload_picker.dart';
import 'package:app_mobile/shared/widgets/logo_header.dart';
import 'package:app_mobile/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompanySetupPage extends StatefulWidget {
  const CompanySetupPage({super.key});

  @override
  State<CompanySetupPage> createState() => _CompanySetupPageState();
}

class _CompanySetupPageState extends State<CompanySetupPage> {
  // Tab control: 0 = Join, 1 = Create (Only for Manager)
  int _activeTab = 0;

  // Join form controller
  final _codeController = TextEditingController();

  // Create form controllers
  final _rucController = TextEditingController();
  final _companyNameController = TextEditingController();
  String? _uploadedIconUrl;

  @override
  void dispose() {
    _codeController.dispose();
    _rucController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  void _onJoinCompany() {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a join code')),
      );
      return;
    }
    context.read<IamBloc>().add(
          JoinCompanySubmitted(joinCode: _codeController.text),
        );
  }

  void _onCreateCompany(String userId) {
    if (_rucController.text.isEmpty || _companyNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    context.read<CompanyBloc>().add(
          CreateCompanyRequested(
            ruc: _rucController.text,
            name: _companyNameController.text,
            // Null is fine: every display site falls back to a local icon.
            iconUrl: _uploadedIconUrl,
            isActive: true,
            userId: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<IamBloc, IamState>(
          listener: (context, state) async {
            if (state is IamJoinCompanySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joined company successfully!')),
              );
              await sl<ProfileRepository>().clearCache();
              if (context.mounted) {
                context.read<ProfileBloc>().add(ProfileLoadRequested());
                context.go('/home');
              }
            } else if (state is IamSignOutSuccess) {
              context.read<ProfileBloc>().add(ProfileReset());
              context.go('/sign-in');
            } else if (state is IamError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
        BlocListener<CompanyBloc, CompanyState>(
          listener: (context, state) async {
            if (state is CompanyCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Company created successfully!')),
              );
              await sl<ProfileRepository>().clearCache();
              if (context.mounted) {
                context.read<ProfileBloc>().add(ProfileLoadRequested());
                context.go('/home');
              }
            } else if (state is CompanyFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            TextButton.icon(
              onPressed: () {
                context.read<IamBloc>().add(const SignOutSubmitted());
              },
              icon: Icon(Icons.logout, color: colorScheme.error, size: 20),
              label: Text(
                'Sign Out',
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              if (profileState is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (profileState is ProfileLoaded) {
                final isManager = profileState.profile.isManagerOrAdmin;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LogoHeader(),
                      const SizedBox(height: 32),
                      Text(
                        'Setup Company',
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isManager
                            ? 'You can choose to create a new company or join an existing one.'
                            : 'Join an existing company using the code provided by your admin.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isManager) ...[
                        // Tab selector
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeTab = 0),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _activeTab == 0
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Join Company',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: _activeTab == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _activeTab == 0
                                          ? colorScheme.primary
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _activeTab = 1),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: _activeTab == 1
                                            ? colorScheme.primary
                                            : Colors.transparent,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Create Company',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: _activeTab == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _activeTab == 1
                                          ? colorScheme.primary
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (!isManager || _activeTab == 0)
                        _buildJoinForm(colorScheme)
                      else
                        _buildCreateForm(colorScheme, profileState.profile.userId),
                    ],
                  ),
                );
              }

              return const Center(child: Text('Unable to load profile data.'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJoinForm(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Enter 6-digit code',
          controller: _codeController,
        ),
        const SizedBox(height: 32),
        BlocBuilder<IamBloc, IamState>(
          builder: (context, state) {
            return PrimaryButton(
              text: 'Join Company',
              isLoading: state is IamLoading,
              onPressed: _onJoinCompany,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCreateForm(ColorScheme colorScheme, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          hintText: 'Company Name',
          controller: _companyNameController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'RUC',
          controller: _rucController,
        ),
        const SizedBox(height: 20),
        ImageUploadPicker(
          imageType: ImageType.company,
          onImageUploaded: (url) {
            setState(() {
              _uploadedIconUrl = url;
            });
          },
        ),
        const SizedBox(height: 32),
        BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            return PrimaryButton(
              text: 'Create Company',
              isLoading: state is CompanyLoading,
              onPressed: () => _onCreateCompany(userId),
            );
          },
        ),
      ],
    );
  }
}
