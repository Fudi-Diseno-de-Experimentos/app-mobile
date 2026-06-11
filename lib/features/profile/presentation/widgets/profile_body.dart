import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_usecase.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/domain/usecases/assign_company_to_user_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profiles_without_company_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/widgets/profile_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

String _positionLabel(String role) {
  switch (role) {
    case 'ROLE_ADMIN':
      return 'Admin';
    case 'ROLE_MANAGER':
      return 'Manager';
    case 'ROLE_USER':
      return 'Member';
    default:
      if (role.startsWith('ROLE_')) {
        final raw = role.substring(5).toLowerCase();
        return raw.isEmpty ? role : raw[0].toUpperCase() + raw.substring(1);
      }
      return role;
  }
}

class ProfileBody extends StatefulWidget {
  final ProfileEntity profile;

  const ProfileBody({super.key, required this.profile});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  CompanyEntity? _company;
  List<ProfileEntity> _noCompanyProfiles = [];
  bool _loadingCompany = false;
  bool _loadingNoCompany = false;
  final _searchNoCompanyController = TextEditingController();
  String _searchNoCompanyQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
    _loadNoCompanyProfiles();
    _searchNoCompanyController.addListener(() {
      setState(() {
        _searchNoCompanyQuery = _searchNoCompanyController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchNoCompanyController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.companyId != oldWidget.profile.companyId ||
        widget.profile.userId != oldWidget.profile.userId) {
      _loadCompanyDetails();
      _loadNoCompanyProfiles();
    }
  }

  Future<void> _loadCompanyDetails() async {
    if (widget.profile.companyId == null || widget.profile.companyId!.isEmpty) {
      if (mounted) {
        setState(() {
          _company = null;
        });
      }
      return;
    }
    setState(() {
      _loadingCompany = true;
    });

    final usecase = sl<GetCompanyUseCase>();
    final result = await usecase(widget.profile.companyId!);
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _loadingCompany = false;
          });
        }
      },
      (company) {
        if (mounted) {
          setState(() {
            _company = company;
            _loadingCompany = false;
          });
        }
      },
    );
  }

  Future<void> _loadNoCompanyProfiles({bool forceRefresh = false}) async {
    final roles = widget.profile.roles ?? [];
    final isManagerOrAdmin = roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');
    if (!isManagerOrAdmin) return;

    setState(() {
      _loadingNoCompany = true;
    });

    final usecase = sl<GetProfilesWithoutCompanyUseCase>();
    final result = await usecase(forceRefresh: forceRefresh);
    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _loadingNoCompany = false;
          });
        }
      },
      (profiles) {
        if (mounted) {
          setState(() {
            _noCompanyProfiles = profiles;
            _loadingNoCompany = false;
          });
        }
      },
    );
  }

  Future<void> _assignUser(String userId) async {
    if (_company == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final usecase = sl<AssignCompanyToUserUseCase>();
    final result = await usecase(userId, _company!.id);
    
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to assign user: ${failure.message}')),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Employee assigned to company successfully!')),
          );
          _loadNoCompanyProfiles(forceRefresh: true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final roles = widget.profile.roles ?? const <String>[];
    final isManagerOrAdmin = roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');

    return Container(
      constraints: const BoxConstraints.expand(),
      color: theme.scaffoldBackgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          await sl<ProfileRepository>().clearCache();
          if (context.mounted) {
            context.read<ProfileBloc>().add(ProfileLoadRequested());
          }
          await _loadCompanyDetails();
          await _loadNoCompanyProfiles(forceRefresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.surface,
                  image: widget.profile.avatarUrl != null && widget.profile.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.profile.avatarUrl!),
                          fit: BoxFit.cover,
                          )
                      : null,
                ),
                child: widget.profile.avatarUrl == null || widget.profile.avatarUrl!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 80,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.profile.name} ${widget.profile.lastname}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              if (roles.isNotEmpty)
                Text(
                  roles.map(_positionLabel).join(' · '),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.profile.email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ProfileActionButton(icon: Icons.phone, onPressed: () {}),
                  const SizedBox(width: 18),
                  ProfileActionButton(icon: Icons.message, onPressed: () {}),
                  const SizedBox(width: 18),
                  ProfileActionButton(icon: Icons.email, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 32),
              _buildCompanySection(colorScheme, textTheme, isManagerOrAdmin),
              if (isManagerOrAdmin && _company != null) ...[
                const SizedBox(height: 32),
                _buildUnassignedEmployeesSection(colorScheme, textTheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySection(ColorScheme colorScheme, TextTheme textTheme, bool isManager) {
    if (_loadingCompany) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_company == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
        ),
        child: Text(
          'No company assigned.',
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COMPANY DETAILS',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (isManager)
                GestureDetector(
                  onTap: () async {
                    final updated = await context.push('/profile/company-edit', extra: _company);
                    if (updated == true) {
                      _loadCompanyDetails();
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  image: _company!.iconUrl != null && _company!.iconUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_company!.iconUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _company!.iconUrl == null || _company!.iconUrl!.isEmpty
                    ? Icon(Icons.business, size: 30, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _company!.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RUC: ${_company!.ruc}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isManager) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOIN CODE',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _company!.joinCode,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy Code',
                  color: colorScheme.primary,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _company!.joinCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Join code copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnassignedEmployeesSection(ColorScheme colorScheme, TextTheme textTheme) {
    if (_loadingNoCompany) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UNASSIGNED EMPLOYEES',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    final filtered = _noCompanyProfiles.where((m) {
      final fullName = '${m.name} ${m.lastname}'.toLowerCase();
      return fullName.contains(_searchNoCompanyQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNASSIGNED EMPLOYEES',
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (_noCompanyProfiles.isNotEmpty) ...[
          TextField(
            controller: _searchNoCompanyController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search employee...',
              hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4)),
              prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              filled: true,
              fillColor: colorScheme.secondary.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (filtered.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _noCompanyProfiles.isEmpty
                  ? 'All employees are assigned to a company.'
                  : 'No employees match your search.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final member = filtered[index];
              final initials = member.initials;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                        ? NetworkImage(member.avatarUrl!)
                        : null,
                    child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                        ? Text(
                            initials,
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    '${member.name} ${member.lastname}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    member.email,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: TextButton.icon(
                    onPressed: () => _assignUser(member.userId),
                    icon: const Icon(Icons.person_add_alt_1, size: 16),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
