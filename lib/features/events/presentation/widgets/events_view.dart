import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/events/presentation/widgets/event_card.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:app_mobile/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  /// Role-aware refresh: regular members get a recipient-scoped list (declined
  /// events hidden); admins/managers get the full company list.
  void _refresh(BuildContext context, {bool forceRefresh = false}) {
    final profile = context.read<ProfileBloc>().state.profileOrNull;
    context
        .read<EventBloc>()
        .add(FetchEvents.forProfile(profile, forceRefresh: forceRefresh));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventState>(
      // Surface accept/decline failures without tearing down the list.
      listenWhen: (_, curr) => curr is InvitationResponseFailure,
      listener: (context, state) {
        if (state is InvitationResponseFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: BlocBuilder<EventBloc, EventState>(
        // Ignore transient invitation states so the optimistic EventLoaded
        // re-emit is what actually refreshes the list.
        buildWhen: (_, curr) =>
            curr is EventLoading || curr is EventLoaded || curr is EventError,
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
                      _refresh(context, forceRefresh: true);
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
                              final currentUserId = context
                                  .read<ProfileBloc>()
                                  .state
                                  .profileOrNull
                                  ?.userId;
                              return InkWell(
                                onTap: () async {
                                  await context.push('/files/event', extra: item);
                                  if (context.mounted) {
                                    _refresh(context);
                                  }
                                },
                                child: EventCard(
                                  item: item,
                                  currentUserId: currentUserId,
                                ),
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
      ),
    );
  }
}
