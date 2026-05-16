import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_event.dart';
import '../bloc/announcement_state.dart';
import 'announcement_card.dart';

class AnnouncementsView extends StatefulWidget {
  const AnnouncementsView({super.key});

  @override
  State<AnnouncementsView> createState() => _AnnouncementsViewState();
}

class _AnnouncementsViewState extends State<AnnouncementsView> {
  // null = all; otherwise the API priority enum (NORMAL|HIGH|URGENT).
  String? _priority;

  static const _filters = <({String label, String? value})>[
    (label: 'Todos', value: null),
    (label: 'Normal', value: 'NORMAL'),
    (label: 'Alta', value: 'HIGH'),
    (label: 'Urgente', value: 'URGENT'),
  ];

  void _select(String? priority) {
    if (_priority == priority) return;
    setState(() => _priority = priority);
    context
        .read<AnnouncementBloc>()
        .add(FetchAnnouncementsByPriority(priority));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(),
        Expanded(
          child: BlocBuilder<AnnouncementBloc, AnnouncementState>(
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
                final announcements = state.announcements;

                if (announcements.isEmpty) {
                  return const Center(
                    child: Text(
                      "No announcements available",
                      style: TextStyle(color: AppColors.tertiary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 16, bottom: 64),
                  itemCount: announcements.length,
                  itemBuilder: (context, index) {
                    final item = announcements[index];
                    return InkWell(
                      onTap: () async {
                        await context.push('/files/announcement', extra: item);
                        if (context.mounted) {
                          context
                              .read<AnnouncementBloc>()
                              .add(FetchAnnouncementsByPriority(_priority));
                        }
                      },
                      child: AnnouncementCard(item: item),
                    );
                  },
                );
              }

              return const Center(child: Text("Initializing..."));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _priority == filter.value;
          return GestureDetector(
            onTap: () => _select(filter.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.neutral
                    : AppColors.secondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                filter.label,
                style: TextStyle(
                  color: selected ? AppColors.surface : AppColors.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
