import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/update_event_usecase.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/domain/usecases/get_company_members_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final GetEventsUseCase getEventsUseCase;
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final DeleteEventUseCase deleteEventUseCase;
  final GetCompanyMembersUseCase getCompanyMembersUseCase;

  EventBloc({
    required this.getEventsUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.getCompanyMembersUseCase,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<FetchCompanyMembers>(_onFetchCompanyMembers);
    on<CreateEventRequested>(_onCreateEventRequested);
    on<UpdateEventRequested>(_onUpdateEventRequested);
    on<DeleteEventRequested>(_onDeleteEventRequested);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final failureOrEvents =
        await getEventsUseCase(forceRefresh: event.forceRefresh);
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

  Future<void> _onUpdateEventRequested(
    UpdateEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await updateEventUseCase(
      id: event.id,
      title: event.title,
      description: event.description,
      date: event.date,
      location: event.location,
      recipientIds: event.recipientIds,
    );
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (updated) => emit(EventUpdateSuccess(updated)),
    );
  }

  Future<void> _onDeleteEventRequested(
    DeleteEventRequested event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    final result = await deleteEventUseCase(event.id);
    result.fold(
      (failure) => emit(EventError(failure.message)),
      (_) => emit(EventDeleteSuccess(event.id)),
    );
  }
}
