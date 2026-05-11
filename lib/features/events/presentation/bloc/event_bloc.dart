import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_events_usecase.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../../../profile/domain/usecases/get_company_members_usecase.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;
  final CreateEventUseCase createEventUseCase;
  final GetCompanyMembersUseCase getCompanyMembersUseCase;

  EventBloc({
    required this.getEventsUseCase,
    required this.createEventUseCase,
    required this.getCompanyMembersUseCase,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<FetchCompanyMembers>(_onFetchCompanyMembers);
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

  Future<void> _onFetchCompanyMembers(
    FetchCompanyMembers event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await getCompanyMembersUseCase(event.companyId);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (members) => emit(EventMembersLoaded(members)),
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
