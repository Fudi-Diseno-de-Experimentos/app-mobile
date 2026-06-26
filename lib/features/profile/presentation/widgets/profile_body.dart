import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/company/domain/usecases/get_company_usecase.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_event.dart';
import 'package:app_mobile/features/profile/presentation/widgets/profile_action_button.dart';
import 'package:flutter/material.dart';
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
  bool _loadingCompany = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyDetails();
  }

  @override
  void didUpdateWidget(covariant ProfileBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile.companyId != oldWidget.profile.companyId ||
        widget.profile.userId != oldWidget.profile.userId) {
      _loadCompanyDetails();
    }
  }

  Future<void> _loadCompanyDetails() async {
    if (widget.profile.companyId == null || widget.profile.companyId!.isEmpty) {
      if (mounted) setState(() => _company = null);
      return;
    }
    setState(() => _loadingCompany = true);

    final result = await sl<GetCompanyUseCase>()(widget.profile.companyId!);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingCompany = false),
      (company) => setState(() {
        _company = company;
        _loadingCompany = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final roles = widget.profile.roles ?? const <String>[];
    final isManagerOrAdmin =
        roles.contains('ROLE_ADMIN') || roles.contains('ROLE_MANAGER');

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
                  image: widget.profile.avatarUrl != null &&
                          widget.profile.avatarUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.profile.avatarUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.profile.avatarUrl == null ||
                        widget.profile.avatarUrl!.isEmpty
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanySection(
    ColorScheme colorScheme,
    TextTheme textTheme,
    bool isManager,
  ) {
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

    // Managers/admins get a button into the dedicated Company screen, where all
    // company management (details, spaces, unassigned employees) lives.
    if (isManager) {
      return _buildCompanyButton(colorScheme, textTheme);
    }

    // Members get a read-only company card inline.
    return _buildReadOnlyCard(colorScheme, textTheme);
  }

  Widget _buildCompanyButton(ColorScheme colorScheme, TextTheme textTheme) {
    final company = _company!;
    return InkWell(
      onTap: () async {
        await context.push('/company', extra: company);
        // The company may have been edited on the hub — refresh the label.
        _loadCompanyDetails();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: colorScheme.secondary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                image: company.iconUrl != null && company.iconUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(company.iconUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: company.iconUrl == null || company.iconUrl!.isEmpty
                  ? Icon(Icons.business, size: 24, color: colorScheme.primary)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage company',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyCard(ColorScheme colorScheme, TextTheme textTheme) {
    final company = _company!;
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
          Text(
            'COMPANY',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
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
                  image: company.iconUrl != null && company.iconUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(company.iconUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: company.iconUrl == null || company.iconUrl!.isEmpty
                    ? Icon(Icons.business, size: 30, color: colorScheme.primary)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RUC: ${company.ruc}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
