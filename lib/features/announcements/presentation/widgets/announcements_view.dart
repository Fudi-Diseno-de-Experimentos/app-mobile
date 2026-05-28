import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/announcement_entity.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import 'announcement_card.dart';
import 'priority_dot.dart';

/// Single unified feed: announcements page with priority filter chips.
/// Sorted by urgency (URGENT → HIGH → NORMAL), then most-recent-first.
class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView> {
  String _selectedPriority = 'ALL';

  DateTime _parse(String iso) =>
      DateTime.tryParse(iso) ?? DateTime.fromMillisecondsSinceEpoch(0);

  List<AnnouncementEntity> _sorted(List<AnnouncementEntity> items) {
    final list = [...items];
    list.sort((a, b) {
      final byPriority = PriorityStyle.rank(a.priority)
          .compareTo(PriorityStyle.rank(b.priority));
      if (byPriority != 0) return byPriority;
      return _parse(b.createdAt).compareTo(_parse(a.createdAt));
    });
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
              style: const TextStyle(color: AppColors.destructive),
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
                    Color activeColor = colorScheme.primary;
                    if (priority == 'HIGH') activeColor = Colors.orange;
                    if (priority == 'URGENT') activeColor = colorScheme.error;
                    if (priority == 'NORMAL') activeColor = const Color(0xFF2E7D32);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedPriority = priority),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? activeColor.withOpacity(0.12)
                              : colorScheme.secondary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? activeColor : colorScheme.outline.withOpacity(0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            priority,
                            style: textTheme.labelLarge?.copyWith(
                              color: isSelected ? activeColor : colorScheme.onSurface.withOpacity(0.6),
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
                child: announcements.isEmpty
                    ? Center(
                        child: Text(
                          "No ${_selectedPriority == 'ALL' ? '' : _selectedPriority.toLowerCase() + ' '}announcements available",
                          style: const TextStyle(color: AppColors.tertiary),
                        ),
                      )
                    : ListView.builder(
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
                            child: AnnouncementCard(item: item),
                          );
                        },
                      ),
              ),
            ],
          );
        }

        return const Center(child: Text("Initializing..."));
      },
    );
  }
}

