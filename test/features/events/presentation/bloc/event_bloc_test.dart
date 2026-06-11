import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../../../mocks/generate_mocks.mocks.dart';
import '../../../../mocks/mock_helpers.dart';

void main() {
  late MockGetEventsUseCase mockGetEvents;
  late MockCreateEventUseCase mockCreateEvent;
  late MockUpdateEventUseCase mockUpdateEvent;
  late MockDeleteEventUseCase mockDeleteEvent;
  late MockGetCompanyMembersUseCase mockGetCompanyMembers;
  late EventBloc bloc;

  const tEvent = EventEntity(
    id: 'evt-1',
    title: 'Quarterly Meeting',
    description: 'Goals review',
    date: '2024-03-15T10:00:00Z',
    location: 'Sala Principal',
    createdBy: 'manager-1',
    recipientIds: ['emp-1', 'emp-2'],
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  const tMember = ProfileEntity(
    id: 'profile-1',
    userId: 'emp-1',
    username: 'jperez',
    name: 'Juan',
    lastname: 'Pérez',
    email: 'juan@test.com',
    roles: ['ROLE_USER'],
  );

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetEvents = MockGetEventsUseCase();
    mockCreateEvent = MockCreateEventUseCase();
    mockUpdateEvent = MockUpdateEventUseCase();
    mockDeleteEvent = MockDeleteEventUseCase();
    mockGetCompanyMembers = MockGetCompanyMembersUseCase();
    bloc = EventBloc(
      getEventsUseCase: mockGetEvents,
      createEventUseCase: mockCreateEvent,
      updateEventUseCase: mockUpdateEvent,
      deleteEventUseCase: mockDeleteEvent,
      getCompanyMembersUseCase: mockGetCompanyMembers,
    );
  });

  tearDown(() => bloc.close());

  group('US18 - Basic event creation', () {
    blocTest<EventBloc, EventState>(
      'should emit [Loading, Loaded] when events are fetched successfully',
      build: () {
        when(mockGetEvents())
            .thenAnswer((_) async => const Right([tEvent]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchEvents()),
      expect: () => [
        EventLoading(),
        const EventLoaded([tEvent]),
      ],
    );

    blocTest<EventBloc, EventState>(
      'should emit [Loading, Error] when fetching events fails',
      build: () {
        when(mockGetEvents())
            .thenAnswer((_) async => const Left(ServerFailure('No connection')));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchEvents()),
      expect: () => [
        EventLoading(),
        const EventError('No connection'),
      ],
    );

    blocTest<EventBloc, EventState>(
      'should emit [Loading, CreateSuccess, Loading, Loaded] when an event is created successfully',
      build: () {
        when(mockCreateEvent(
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          createdBy: anyNamed('createdBy'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Right(tEvent));
        when(mockGetEvents())
            .thenAnswer((_) async => const Right([tEvent]));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateEventRequested(
        title: 'Quarterly Meeting',
        description: 'Goals review',
        date: '2024-03-15T10:00:00Z',
        location: 'Sala Principal',
        createdBy: 'manager-1',
        recipientIds: ['emp-1', 'emp-2'],
      )),
      expect: () => [
        EventLoading(),
        EventCreateSuccess(),
        EventLoading(),
        const EventLoaded([tEvent]),
      ],
    );

    blocTest<EventBloc, EventState>(
      'should emit [Loading, Error] when event creation fails',
      build: () {
        when(mockCreateEvent(
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          createdBy: anyNamed('createdBy'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Left(ServerFailure('Invalid fields')));
        return bloc;
      },
      act: (bloc) => bloc.add(const CreateEventRequested(
        title: '',
        description: '',
        date: '',
        location: '',
        createdBy: 'manager-1',
        recipientIds: [],
      )),
      expect: () => [
        EventLoading(),
        const EventError('Invalid fields'),
      ],
    );
  });

  group('US18 - Load company members for invitee selection', () {
    blocTest<EventBloc, EventState>(
      'should emit [Loading, MembersLoaded] when members are fetched successfully',
      build: () {
        when(mockGetCompanyMembers('comp-1'))
            .thenAnswer((_) async => const Right([tMember]));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchCompanyMembers('comp-1')),
      expect: () => [
        EventLoading(),
        const EventMembersLoaded([tMember]),
      ],
    );
  });

  group('US20 - Event modification', () {
    blocTest<EventBloc, EventState>(
      'should emit [Loading, UpdateSuccess] when an event updates successfully',
      build: () {
        const updatedEvent = EventEntity(
          id: 'evt-1',
          title: 'Postponed Meeting',
          description: 'Nueva fecha',
          date: '2024-04-15T10:00:00Z',
          location: 'Sala B',
          createdBy: 'manager-1',
          recipientIds: ['emp-1', 'emp-2'],
          createdAt: '2024-01-01',
          updatedAt: '2024-02-01',
        );
        when(mockUpdateEvent(
          id: anyNamed('id'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Right(updatedEvent));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateEventRequested(
        id: 'evt-1',
        title: 'Postponed Meeting',
        description: 'Nueva fecha',
        date: '2024-04-15T10:00:00Z',
        location: 'Sala B',
        recipientIds: ['emp-1', 'emp-2'],
      )),
      expect: () => [
        EventLoading(),
        isA<EventUpdateSuccess>(),
      ],
    );

    blocTest<EventBloc, EventState>(
      'should emit [Loading, Error] when the event update fails',
      build: () {
        when(mockUpdateEvent(
          id: anyNamed('id'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Left(ServerFailure('Event not found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateEventRequested(
        id: 'evt-999',
        title: 'Does not exist',
        description: 'Desc',
        date: '2024-01-01',
        location: 'Sala',
        recipientIds: [],
      )),
      expect: () => [
        EventLoading(),
        const EventError('Event not found'),
      ],
    );
  });

  group('US19 - Event cancellation', () {
    blocTest<EventBloc, EventState>(
      'should emit [Loading, DeleteSuccess] when an event is deleted successfully',
      build: () {
        when(mockDeleteEvent('evt-1'))
            .thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteEventRequested('evt-1')),
      expect: () => [
        EventLoading(),
        const EventDeleteSuccess('evt-1'),
      ],
    );

    blocTest<EventBloc, EventState>(
      'should emit [Loading, Error] when the event deletion fails',
      build: () {
        when(mockDeleteEvent('evt-1'))
            .thenAnswer((_) async => const Left(ServerFailure('Permiso denegado')));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteEventRequested('evt-1')),
      expect: () => [
        EventLoading(),
        const EventError('Permiso denegado'),
      ],
    );
  });
}
