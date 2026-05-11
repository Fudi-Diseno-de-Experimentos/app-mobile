import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_events_usecase.dart';
import '../../domain/usecases/create_event_usecase.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;
  final CreateEventUseCase createEventUseCase;

  EventBloc({
    required this.getEventsUseCase,
    required this.createEventUseCase,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<CreateEventRequested>(_onCreateEventRequested);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final failureOrEvents = await getEventsUseCase();
    failureOrEvents.fold(
      (failure) => emit(EventError(failure.message)),
      (events) => emit(EventLoaded(events)),
    );
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final failureOrEvent = await createEventUseCase(
      title: event.title,
      description: event.description,
      date: event.date,
      location: event.location,
      createdBy: event.createdBy,
      recipientIds: event.recipientIds,
    );

    failureOrEvent.fold(
      (failure) => emit(EventError(failure.message)),
      (_) {
        emit(EventCreateSuccess());
        add(FetchEvents()); // Refresh list
      },
    );
  }
}
