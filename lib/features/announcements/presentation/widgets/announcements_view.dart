import 'package:app_mobile/app/di.dart';
import 'package:app_mobile/features/announcements/domain/entities/announcement_entity.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_bloc.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_event.dart';
import 'package:app_mobile/features/announcements/presentation/bloc/announcement_state.dart';
import 'package:app_mobile/features/announcements/presentation/widgets/announcement_card.dart';
import 'package:app_mobile/features/announcements/presentation/widgets/priority_dot.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Single unified feed: announcements page with priority filter chips.
/// Sorted by urgency (URGENT → HIGH → NORMAL), then most-recent-first.
class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView> {
  String _selectedPriority = 'ALL';
  List<ProfileEntity> _companyMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchCompanyMembers();
  }

  void _fetchCompanyMembers() async {
    final profileState = context.read<ProfileBloc>().state;
    final companyId = profileState.profileOrNull?.companyId;
    if (companyId != null) {
      final usecase = sl<GetCompanyMembersUseCase>();
      final result = await usecase(companyId);
      result.fold(
        (_) {},
        (members) {
          if (mounted) {
            setState(() {
              _companyMembers = members;
            });
          }
        },
      );
    }
  }

  DateTime _parse(String iso) =>
      DateTime.tryParse(iso) ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<AnnouncementEntity> _sorted(List<AnnouncementEntity> items) {
    final list = [...items];
    if (_selectedPriority == 'ALL') {
      list.sort((a, b) => _parse(b.createdAt).compareTo(_parse(a.createdAt)));
    } else {
      list.sort((a, b) {
        final byPriority = PriorityStyle.rank(a.priority)
            .compareTo(PriorityStyle.rank(b.priority));
        if (byPriority != 0) return byPriority;
        return _parse(b.createdAt).compareTo(_parse(a.createdAt));
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<AnnouncementBloc, AnnouncementState>(
      builder: (context, state) {
        if (state is AnnouncementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AnnouncementError) {
          return Center(
            child: Text(
              state.message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        } else if (state is AnnouncementLoaded) {
          var items = state.announcements;
          if (_selectedPriority != 'ALL') {
            items = items
                .where((a) => a.priority.toUpperCase() == _selectedPriority)
                .toList();
          }
          final announcements = _sorted(items);

          return Column(
            children: [
              Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: ['ALL', 'NORMAL', 'HIGH', 'URGENT'].map((priority) {
                    final isSelected = _selectedPriority == priority;
                    final activeColor = priority == 'ALL'
                        ? colorScheme.primary
                        : PriorityStyle.color(context, priority);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withValues(alpha:0.12)
                              : colorScheme.secondary.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? activeColor : colorScheme.outline.withValues(alpha:0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            priority,
                            style: textTheme.labelLarge?.copyWith(
                              color: isSelected ? activeColor : colorScheme.onSurface.withValues(alpha:0.6),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<AnnouncementBloc>()
                        .add(const FetchAnnouncements(forceRefresh: true));
                    _fetchCompanyMembers();
                  },
                  child: announcements.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: Text(
                              "No ${_selectedPriority == 'ALL' ? '' : '${_selectedPriority.toLowerCase()} '}announcements available",
                              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 64),
                          itemCount: announcements.length,
                          itemBuilder: (context, index) {
                            final item = announcements[index];
                            return InkWell(
                              onTap: () async {
                                await context.push('/files/announcement', extra: item);
                                if (context.mounted) {
                                  context
                                      .read<AnnouncementBloc>()
                                      .add(FetchAnnouncements());
                                }
                              },
                              child: AnnouncementCard(
                                item: item,
                                members: _companyMembers,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Initializing...'));
      },
    );
  }
}

