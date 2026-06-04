import 'package:flutter/material.dart';
import '../../../../app/di.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_company_members_usecase.dart';
import 'member_detail_sheet.dart';

class MembersTabContent extends StatefulWidget {
  final String companyId;

  const MembersTabContent({super.key, required this.companyId});

  @override
  State<MembersTabContent> createState() => _MembersTabContentState();
}

class _MembersTabContentState extends State<MembersTabContent> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<ProfileEntity> _allMembers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadMembers() async {
    final usecase = sl<GetCompanyMembersUseCase>();
    final result = await usecase(widget.companyId);
    result.fold(
      (_) => setState(() => _loading = false),
      (members) {
        if (mounted) {
          setState(() {
            _allMembers = members;
            _loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _allMembers.where((m) {
      final fullName = '${m.name} ${m.lastname}'.toLowerCase();
      return fullName.contains(_searchQuery) ||
          m.email.toLowerCase().contains(_searchQuery);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search member...',
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
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await sl<ProfileRepository>().clearCache();
                _loadMembers();
              },
              child: filtered.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
                        child: Text(
                          'No members found',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final member = filtered[index];
                        final initials =
                            '${member.name.isNotEmpty ? member.name[0] : ''}${member.lastname.isNotEmpty ? member.lastname[0] : ''}'
                                .toUpperCase();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              backgroundImage: member.avatarUrl != null &&
                                      member.avatarUrl!.isNotEmpty
                                  ? NetworkImage(member.avatarUrl!)
                                  : null,
                              child: member.avatarUrl == null ||
                                      member.avatarUrl!.isEmpty
                                  ? Text(
                                      initials,
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              '${member.name} ${member.lastname}',
                              style: textTheme.bodyLarge?.copyWith(
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
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            onTap: () =>
                                _showMemberDetail(context, member, colorScheme, textTheme),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMemberDetail(
    BuildContext context,
    ProfileEntity member,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: MemberDetailSheet(member: member),
        );
      },
    );
  }
}
