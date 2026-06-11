import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/events/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
              style: TextStyle(color: Theme.of(context).colorScheme.error),
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
                child: Text(
                  'Upcoming Events',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<EventBloc>()
                        .add(const FetchEvents(forceRefresh: true));
                  },
                  child: events.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            alignment: Alignment.center,
                            child: Text(
                              'No upcoming events',
                              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 64),
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final item = events[index];
                            return InkWell(
                              onTap: () async {
                                await context.push('/files/event', extra: item);
                                if (context.mounted) {
                                  context.read<EventBloc>().add(FetchEvents());
                                }
                              },
                              child: EventCard(item: item),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        }

        return const Center(child: Text('Loading events...'));
      },
    );
  }
}
