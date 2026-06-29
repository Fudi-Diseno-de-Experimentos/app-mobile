import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/domain/usecases/accept_invitation_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/decline_invitation_usecase.dart';
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
  final AcceptInvitationUseCase acceptInvitationUseCase;
  final DeclineInvitationUseCase declineInvitationUseCase;
  final GetCompanyMembersUseCase getCompanyMembersUseCase;

  /// Last loaded list and the filter mode it was fetched with, kept so an
  /// accept/decline can update the list optimistically without a refetch.
  List<EventEntity> _events = const [];
  String? _lastFilterType;

  EventBloc({
    required this.getEventsUseCase,
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.acceptInvitationUseCase,
    required this.declineInvitationUseCase,
    required this.getCompanyMembersUseCase,
  }) : super(EventInitial()) {
    on<FetchEvents>(_onFetchEvents);
    on<FetchCompanyMembers>(_onFetchCompanyMembers);
    on<CreateEventRequested>(_onCreateEventRequested);
    on<UpdateEventRequested>(_onUpdateEventRequested);
    on<DeleteEventRequested>(_onDeleteEventRequested);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
  }

  Future<void> _onFetchEvents(
    FetchEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    _lastFilterType = event.filterType;
    final failureOrEvents = await getEventsUseCase(
      forceRefresh: event.forceRefresh,
      userId: event.userId,
      filterType: event.filterType,
    );
    failureOrEvents.fold(
      (failure) => emit(EventError(failure.message)),
      (events) {
        _events = events;
        emit(EventLoaded(_events));
      },
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
      spaceId: event.spaceId,
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
      spaceId: event.spaceId,
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

  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<EventState> emit,
  ) async {
    final result = await acceptInvitationUseCase(event.eventId);
    result.fold(
      (failure) {
        emit(InvitationResponseFailure(failure.message));
        emit(EventLoaded(_events)); // keep the list on screen
      },
      (updated) {
        // Accepting keeps the event in the list; just update its status.
        _events = _events
            .map((e) => e.id == updated.id
                ? e.copyWith(myStatus: RecipientStatus.accepted)
                : e)
            .toList();
        emit(InvitationResponseSuccess(updated));
        emit(EventLoaded(_events));
      },
    );
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<EventState> emit,
  ) async {
    final result = await declineInvitationUseCase(event.eventId);
    result.fold(
      (failure) {
        emit(InvitationResponseFailure(failure.message));
        emit(EventLoaded(_events));
      },
      (updated) {
        // Declined events vanish from a recipient-scoped list (server hides
        // them); on an unfiltered admin list they stay with a DECLINED status.
        if (_lastFilterType == 'recipient') {
          _events = _events.where((e) => e.id != updated.id).toList();
        } else {
          _events = _events
              .map((e) => e.id == updated.id
                  ? e.copyWith(myStatus: RecipientStatus.declined)
                  : e)
              .toList();
        }
        emit(InvitationResponseSuccess(updated));
        emit(EventLoaded(_events));
      },
    );
  }
}
