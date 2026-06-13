import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/company/domain/entities/company_entity.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/assign_company_to_user_usecase.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_profiles_without_company_usecase.dart';
import 'package:flutter/material.dart';

/// Lists profiles not yet attached to any company and lets a manager assign
/// them to [company]. Moved here from the manager profile screen.
class UnassignedEmployeesPage extends StatefulWidget {
  final CompanyEntity company;

  const UnassignedEmployeesPage({super.key, required this.company});

  @override
  State<UnassignedEmployeesPage> createState() =>
      _UnassignedEmployeesPageState();
}

class _UnassignedEmployeesPageState extends State<UnassignedEmployeesPage> {
  List<ProfileEntity> _profiles = [];
  bool _loading = false;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() => _loading = true);
    final result =
        await sl<GetProfilesWithoutCompanyUseCase>()(forceRefresh: forceRefresh);
    if (!mounted) return;
    result.fold(
      (_) => setState(() => _loading = false),
      (profiles) => setState(() {
        _profiles = profiles;
        _loading = false;
      }),
    );
  }

  Future<void> _assign(String userId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result =
        await sl<AssignCompanyToUserUseCase>()(userId, widget.company.id);

    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign user: ${failure.message}')),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee assigned successfully!')),
        );
        _load(forceRefresh: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final filtered = _profiles.where((m) {
      final fullName = '${m.name} ${m.lastname}'.toLowerCase();
      return fullName.contains(_query);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Unassigned Employees')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => _load(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_profiles.isNotEmpty) ...[
                      TextField(
                        controller: _searchController,
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search employee...',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.secondary.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (filtered.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _profiles.isEmpty
                              ? 'All employees are assigned to a company.'
                              : 'No employees match your search.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...filtered.map(
                        (member) => _buildTile(member, colorScheme, textTheme),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTile(
    ProfileEntity member,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
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
                  member.initials,
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
          onPressed: () => _assign(member.userId),
          icon: const Icon(Icons.person_add_alt_1, size: 16),
          label: const Text('Add'),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
