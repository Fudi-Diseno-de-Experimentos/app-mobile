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

/// Single unified feed: every announcement, no type filter chips. Ordered by
/// urgency (URGENT → HIGH → NORMAL), then most-recent-first within a priority.
class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({super.key});

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
          final announcements = _sorted(state.announcements);

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
                        .add(FetchAnnouncements());
                  }
                },
                child: AnnouncementCard(item: item),
              );
            },
          );
        }

        return const Center(child: Text("Initializing..."));
      },
    );
  }
}
