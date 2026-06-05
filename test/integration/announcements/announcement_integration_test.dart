import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:app_mobile/core/error/exceptions.dart';
import 'package:app_mobile/features/announcements/data/models/announcement_model.dart';
import 'package:app_mobile/features/announcements/data/repositories/announcement_repository_impl.dart';
import 'package:app_mobile/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/create_announcement_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/update_announcement_usecase.dart';
import 'package:app_mobile/features/announcements/domain/usecases/delete_announcement_usecase.dart';

import '../../mocks/generate_mocks.mocks.dart';

void main() {
  late MockAnnouncementRemoteDataSource mockDataSource;
  late MockSharedPreferences mockPrefs;
  late AnnouncementRepositoryImpl repository;

  const tModel = AnnouncementModel(
    id: 'ann-1',
    title: 'Anuncio Integración',
    description: 'Test de integración completo',
    image: 'img.png',
    priority: 'NORMAL',
    createdBy: 'user-1',
    createdAt: '2024-01-01',
    updatedAt: '2024-01-01',
  );

  setUp(() {
    mockDataSource = MockAnnouncementRemoteDataSource();
    mockPrefs = MockSharedPreferences();
    when(mockPrefs.getString(any)).thenReturn(null);
    when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
    when(mockPrefs.remove(any)).thenAnswer((_) async => true);
    repository = AnnouncementRepositoryImpl(
      remoteDataSource: mockDataSource,
      sharedPreferences: mockPrefs,
    );
  });

  group('US10 - Integración: Datasource → Repository → UseCase (Publicación de anuncios)', () {
    test('debe obtener anuncios desde el datasource a través del repositorio y use case', () async {
      // Arrange
      when(mockDataSource.getAnnouncements())
          .thenAnswer((_) async => [tModel]);
      final useCase = GetAnnouncementsUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (announcements) {
          expect(announcements.length, 1);
          expect(announcements.first.id, 'ann-1');
          expect(announcements.first.title, 'Anuncio Integración');
        },
      );
      verify(mockDataSource.getAnnouncements()).called(1);
    });

    test('debe crear un anuncio pasando por todas las capas', () async {
      // Arrange
      when(mockDataSource.createAnnouncement(
        title: anyNamed('title'),
        description: anyNamed('description'),
        image: anyNamed('image'),
        priority: anyNamed('priority'),
        createdBy: anyNamed('createdBy'),
      )).thenAnswer((_) async => tModel);
      final useCase = CreateAnnouncementUseCase(repository);

      // Act
      final result = await useCase(
        title: 'Anuncio Integración',
        description: 'Test de integración completo',
        image: 'img.png',
        priority: 'NORMAL',
        createdBy: 'user-1',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (announcement) => expect(announcement.id, 'ann-1'),
      );
    });

    test('debe propagar errores del datasource como ServerFailure', () async {
      // Arrange
      when(mockDataSource.getAnnouncements())
          .thenThrow(ServerException(message: 'Error 500'));
      final useCase = GetAnnouncementsUseCase(repository);

      // Act
      final result = await useCase();

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('US12 - Integración: Edición de anuncios', () {
    test('debe actualizar un anuncio y limpiar la caché', () async {
      // Arrange
      const updatedModel = AnnouncementModel(
        id: 'ann-1',
        title: 'Título Actualizado',
        description: 'Nueva descripción',
        priority: 'HIGH',
        createdBy: 'user-1',
        createdAt: '2024-01-01',
        updatedAt: '2024-01-02',
      );
      when(mockDataSource.updateAnnouncement(
        id: anyNamed('id'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        image: anyNamed('image'),
        priority: anyNamed('priority'),
      )).thenAnswer((_) async => updatedModel);
      final useCase = UpdateAnnouncementUseCase(repository);

      // Act
      final result = await useCase(
        id: 'ann-1',
        title: 'Título Actualizado',
        description: 'Nueva descripción',
        priority: 'HIGH',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Debería ser Right'),
        (announcement) {
          expect(announcement.title, 'Título Actualizado');
          expect(announcement.priority, 'HIGH');
        },
      );
    });
  });

  group('US13 - Integración: Eliminación de anuncios', () {
    test('debe eliminar un anuncio y limpiar la caché', () async {
      // Arrange
      when(mockDataSource.deleteAnnouncement('ann-1'))
          .thenAnswer((_) async {});
      final useCase = DeleteAnnouncementUseCase(repository);

      // Act
      final result = await useCase('ann-1');

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.deleteAnnouncement('ann-1')).called(1);
    });
  });

  group('US10 - Integración: Caché de anuncios', () {
    test('debe usar caché en memoria para la segunda llamada', () async {
      // Arrange
      when(mockDataSource.getAnnouncements())
          .thenAnswer((_) async => [tModel]);
      final useCase = GetAnnouncementsUseCase(repository);

      // Act
      await useCase();
      final result = await useCase();

      // Assert
      expect(result.isRight(), true);
      verify(mockDataSource.getAnnouncements()).called(1);
    });

    test('debe refrescar datos después de limpiar caché', () async {
      // Arrange
      when(mockDataSource.getAnnouncements())
          .thenAnswer((_) async => [tModel]);

      // Act
      await repository.getAnnouncements();
      await repository.clearCache();
      await repository.getAnnouncements();

      // Assert
      verify(mockDataSource.getAnnouncements()).called(2);
    });
  });
}
