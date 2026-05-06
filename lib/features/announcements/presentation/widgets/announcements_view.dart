import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/announcement_bloc.dart';
import '../bloc/announcement_state.dart';
import 'announcement_card.dart';
import 'avatar_placeholder.dart';

class AnnouncementsView extends StatelessWidget {
  const AnnouncementsView({super.key});

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
          final announcements = state.announcements;
          
          if (announcements.isEmpty) {
            return const Center(
              child: Text(
                "No announcements available",
                style: TextStyle(color: AppColors.tertiary),
              ),
            );
          }

          // Extract unique createdBy uuids for the bottom avatar list
          final uniqueUuids = announcements.map((e) => e.createdBy).toSet().toList();

          return ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 64),
            itemCount: announcements.length + 1,
            itemBuilder: (context, index) {
              if (index == announcements.length) {
                // Return the horizontal avatar list at the bottom
                return BottomAvatarList(uuids: uniqueUuids);
              }

              final item = announcements[index];
              return AnnouncementCard(item: item);
            },
          );
        }
        
        return const Center(child: Text("Initializing..."));
      },
    );
  }
}

