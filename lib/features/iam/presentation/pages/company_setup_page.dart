import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/logo_header.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/image_upload_picker.dart';
import '../../../../core/network/cloudinary_config.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../company/presentation/bloc/company_bloc.dart';
import '../../../company/presentation/bloc/company_event.dart';
import '../../../company/presentation/bloc/company_state.dart';
import '../bloc/iam_bloc.dart';
import '../bloc/iam_event.dart';
import '../bloc/iam_state.dart';

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
  final _nombreController = TextEditingController();
  String? _uploadedIconUrl;

  final String _defaultIconUrl =
      'https://i.pinimg.com/736x/fb/59/7c/fb597cc50905b6911bf36d3690b9fbc4.jpg';

  @override
  void dispose() {
    _codeController.dispose();
    _rucController.dispose();
    _nombreController.dispose();
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
    if (_rucController.text.isEmpty || _nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields')),
      );
      return;
    }

    context.read<CompanyBloc>().add(
          CreateCompanyRequested(
            ruc: _rucController.text,
            nombre: _nombreController.text,
            iconUrl: _uploadedIconUrl ?? _defaultIconUrl,
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
                final roles = profileState.profile.roles ?? [];
                final isManager = roles.contains('ROLE_MANAGER') ||
                    roles.contains('ROLE_ADMIN');

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LogoHeader(),
                      const SizedBox(height: 32),
                      Text(
                        "Setup Company",
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isManager
                            ? "You can choose to create a new company or join an existing one."
                            : "Join an existing company using the code provided by your admin.",
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
                                    "Join Company",
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
                                    "Create Company",
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

              return const Center(child: Text("Unable to load profile data."));
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
          controller: _nombreController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          hintText: 'RUC',
          controller: _rucController,
        ),
        const SizedBox(height: 20),
        ImageUploadPicker(
          imageType: ImageType.announcement,
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
