import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/events/data/models/event_model.dart';
import 'package:app_mobile/features/events/data/repositories/event_repository_impl.dart';
import 'package:app_mobile/features/events/domain/usecases/create_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/delete_event_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/get_events_usecase.dart';
import 'package:app_mobile/features/events/domain/usecases/update_event_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockEventRemoteDataSource mockDataSource;
  late MockSharedPreferences mockPrefs;
  late EventRepositoryImpl repository;

  const tModel = EventModel(
    id: 'evt-1',
    title: 'General Meeting',
    description: 'Quarterly review',
    date: '2024-03-15T10:00:00Z',
    location: 'Auditorio',
    createdBy: 'manager-1',
    recipientIds: ['emp-1', 'emp-2'],
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  setUp(() {
    mockDataSource = MockEventRemoteDataSource();
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    repository = EventRepositoryImpl(
      remoteDataSource: mockDataSource,
      sharedPreferences: mockPrefs,
    );
  });

  group('US18 - Integration: Datasource → Repository → UseCase (Event creation)', () {
    test('should fetch events from the datasource through repository and use case', () async {
      // Arrange
      when(mockDataSource.getEvents())
          .thenAnswer((_) async => [tModel]);
      final useCase = GetEventsUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (events) {
          expect(events.length, 1);
          expect(events.first.title, 'General Meeting');
          expect(events.first.recipientIds, ['emp-1', 'emp-2']);
        },
      );
    });

    test('should create an event through all layers', () async {
      // Arrange
      when(mockDataSource.createEvent(
        title: anyNamed('title'),
        description: anyNamed('description'),
        date: anyNamed('date'),
        location: anyNamed('location'),
        createdBy: anyNamed('createdBy'),
        recipientIds: anyNamed('recipientIds'),
      )).thenAnswer((_) async => tModel);
      final useCase = CreateEventUseCase(repository);

      // Act
      final result = await useCase(
        title: 'General Meeting',
        description: 'Quarterly review',
        date: '2024-03-15T10:00:00Z',
        location: 'Auditorio',
        createdBy: 'manager-1',
        recipientIds: ['emp-1', 'emp-2'],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (event) {
          expect(event.id, 'evt-1');
          expect(event.location, 'Auditorio');
        },
      );
    });

    test('should propagate datasource errors as ServerFailure', () async {
      // Arrange
      when(mockDataSource.getEvents())
          .thenThrow(ServerException(message: 'Timeout'));
      final useCase = GetEventsUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('US20 - Integration: Event modification', () {
    test('should update an event and clear the cache', () async {
      // Arrange
      const updatedModel = EventModel(
        id: 'evt-1',
        title: 'Postponed Meeting',
        description: 'Nueva fecha',
        date: '2024-04-15T10:00:00Z',
        location: 'Sala B',
        createdBy: 'manager-1',
        recipientIds: ['emp-1', 'emp-2', 'emp-3'],
        createdAt: '2024-01-01',
        updatedAt: '2024-02-01',
      );
      when(mockDataSource.updateEvent(
        id: anyNamed('id'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        date: anyNamed('date'),
        location: anyNamed('location'),
        recipientIds: anyNamed('recipientIds'),
      )).thenAnswer((_) async => updatedModel);
      final useCase = UpdateEventUseCase(repository);

      // Act
      final result = await useCase(
        id: 'evt-1',
        title: 'Postponed Meeting',
        description: 'Nueva fecha',
        date: '2024-04-15T10:00:00Z',
        location: 'Sala B',
        recipientIds: ['emp-1', 'emp-2', 'emp-3'],
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (event) {
          expect(event.title, 'Postponed Meeting');
          expect(event.recipientIds.length, 3);
        },
      );
    });
  });

  group('US19 - Integration: Event cancellation', () {
    test('should delete an event and clear the cache', () async {
      // Arrange
      when(mockDataSource.deleteEvent('evt-1'))
          .thenAnswer((_) async {});
      final useCase = DeleteEventUseCase(repository);

      // Act
      final result = await useCase('evt-1');

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.deleteEvent('evt-1')).called(1);
    });
  });

  group('US18 - Integration: Event cache', () {
    test('should use the in-memory cache for the second call', () async {
      // Arrange
      when(mockDataSource.getEvents())
          .thenAnswer((_) async => [tModel]);

      // Act
      await repository.getEvents();
      final result = await repository.getEvents();

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.getEvents()).called(1);
    });

    test('should refresh data after creating an event (cache invalidation)', () async {
      // Arrange
      when(mockDataSource.getEvents())
          .thenAnswer((_) async => [tModel]);
      when(mockDataSource.createEvent(
        title: anyNamed('title'),
        description: anyNamed('description'),
        date: anyNamed('date'),
        location: anyNamed('location'),
        createdBy: anyNamed('createdBy'),
        recipientIds: anyNamed('recipientIds'),
      )).thenAnswer((_) async => tModel);

      // Act
      await repository.getEvents();
      await repository.createEvent(
        title: 'Nuevo',
        description: 'Desc',
        date: '2024-01-01',
        location: 'Sala',
        createdBy: 'user-1',
        recipientIds: [],
      );
      await repository.getEvents();

      // Assert
      verify(mockDataSource.getEvents()).called(2);
    });
  });
}
