import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_bloc.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_event.dart';
import 'package:app_mobile/features/events/presentation/bloc/event_state.dart';
import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';

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
    title: 'Reunión Trimestral',
    description: 'Revisión de objetivos',
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

  group('US18 - Creación básica de eventos', () {
    blocTest<EventBloc, EventState>(
      'debe emitir [Loading, Loaded] al obtener eventos exitosamente',
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
      'debe emitir [Loading, Error] cuando falla la obtención de eventos',
      build: () {
        when(mockGetEvents())
            .thenAnswer((_) async => const Left(ServerFailure('Sin conexión')));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchEvents()),
      expect: () => [
        EventLoading(),
        const EventError('Sin conexión'),
      ],
    );

    blocTest<EventBloc, EventState>(
      'debe emitir [Loading, CreateSuccess, Loading, Loaded] al crear un evento exitosamente',
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
        title: 'Reunión Trimestral',
        description: 'Revisión de objetivos',
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
      'debe emitir [Loading, Error] cuando falla la creación de evento',
      build: () {
        when(mockCreateEvent(
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          createdBy: anyNamed('createdBy'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Left(ServerFailure('Campos inválidos')));
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
        const EventError('Campos inválidos'),
      ],
    );
  });

  group('US18 - Cargar miembros de la compañía para selección de invitados', () {
    blocTest<EventBloc, EventState>(
      'debe emitir [Loading, MembersLoaded] al obtener miembros exitosamente',
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

  group('US20 - Modificación de eventos', () {
    blocTest<EventBloc, EventState>(
      'debe emitir [Loading, UpdateSuccess] al actualizar un evento exitosamente',
      build: () {
        const updatedEvent = EventEntity(
          id: 'evt-1',
          title: 'Reunión Pospuesta',
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
        title: 'Reunión Pospuesta',
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
      'debe emitir [Loading, Error] cuando falla la actualización del evento',
      build: () {
        when(mockUpdateEvent(
          id: anyNamed('id'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          date: anyNamed('date'),
          location: anyNamed('location'),
          recipientIds: anyNamed('recipientIds'),
        )).thenAnswer((_) async => const Left(ServerFailure('Evento no encontrado')));
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateEventRequested(
        id: 'evt-999',
        title: 'No existe',
        description: 'Desc',
        date: '2024-01-01',
        location: 'Sala',
        recipientIds: [],
      )),
      expect: () => [
        EventLoading(),
        const EventError('Evento no encontrado'),
      ],
    );
  });

  group('US19 - Cancelación de eventos', () {
    blocTest<EventBloc, EventState>(
      'debe emitir [Loading, DeleteSuccess] al eliminar un evento exitosamente',
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
      'debe emitir [Loading, Error] cuando falla la eliminación del evento',
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
