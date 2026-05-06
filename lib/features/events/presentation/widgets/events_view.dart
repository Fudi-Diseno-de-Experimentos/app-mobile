import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/event_bloc.dart';
import '../bloc/event_state.dart';
import 'event_card.dart';
import 'schedule_bar.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        if (state is EventLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is EventError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: AppColors.destructive),
            ),
          );
        } else if (state is EventLoaded) {
          final events = state.events;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming Events Header
              Container(
                margin: const EdgeInsets.only(left: 24, bottom: 12),
                child: const Text(
                  "Upcoming Events",
                  style: TextStyle(
                    color: AppColors.neutral,
                    fontSize: 16,
                  ),
                ),
              ),

              if (events.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      "No upcoming events",
                      style: TextStyle(color: AppColors.tertiary),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 64),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final item = events[index];
                      return EventCard(item: item);
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

