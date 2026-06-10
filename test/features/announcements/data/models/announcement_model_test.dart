import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/announcements/data/models/announcement_model.dart';

void main() {
  group('AnnouncementModel - US10: Publicación básica de anuncios', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'id': 'ann-1',
        'title': 'Anuncio Importante',
        'description': 'Contenido del anuncio',
        'image': 'https://example.com/image.png',
        'priority': 'HIGH',
        'createdBy': 'user-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-02T00:00:00Z',
      };

      // Act
      final model = AnnouncementModel.fromJson(json);

      // Assert
      expect(model.id, 'ann-1');
      expect(model.title, 'Anuncio Importante');
      expect(model.description, 'Contenido del anuncio');
      expect(model.image, 'https://example.com/image.png');
      expect(model.priority, 'HIGH');
      expect(model.createdBy, 'user-1');
      expect(model.createdAt, '2024-01-01T00:00:00Z');
      expect(model.updatedAt, '2024-01-02T00:00:00Z');
    });

    test('fromJson debe manejar imagen nula correctamente', () {
      // Arrange
      final json = {
        'id': 'ann-2',
        'title': 'Sin imagen',
        'description': 'Descripción',
        'image': null,
        'priority': 'NORMAL',
        'createdBy': 'user-1',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      // Act
      final model = AnnouncementModel.fromJson(json);

      // Assert
      expect(model.image, isNull);
    });

    test('fromJson debe usar valores por defecto cuando faltan campos', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = AnnouncementModel.fromJson(json);

      // Assert
      expect(model.id, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.priority, 'NORMAL');
      expect(model.createdBy, '');
    });

    test('toJson debe generar un mapa válido para el API', () {
      // Arrange
      const model = AnnouncementModel(
        id: 'ann-1',
        title: 'Título',
        description: 'Descripción',
        image: 'url.png',
        priority: 'HIGH',
        createdBy: 'user-1',
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-02T00:00:00Z',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'ann-1');
      expect(json['title'], 'Título');
      expect(json['description'], 'Descripción');
      expect(json['image'], 'url.png');
      expect(json['priority'], 'HIGH');
      expect(json['createdBy'], 'user-1');
    });

    test('toJson/fromJson debe ser simétrico (roundtrip)', () {
      // Arrange
      const original = AnnouncementModel(
        id: 'ann-1',
        title: 'Roundtrip',
        description: 'Test',
        image: 'img.png',
        priority: 'HIGH',
        createdBy: 'user-1',
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-02T00:00:00Z',
      );

      // Act
      final json = original.toJson();
      final restored = AnnouncementModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });
  });

  group('AnnouncementModel - US11: Priorización de anuncios', () {
    test('fromJson debe parsear prioridad HIGH correctamente', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Urgente',
        'description': 'Desc',
        'priority': 'HIGH',
        'createdBy': 'u1',
        'createdAt': '',
        'updatedAt': '',
      };

      // Act
      final model = AnnouncementModel.fromJson(json);

      // Assert
      expect(model.priority, 'HIGH');
    });

    test('fromJson debe asignar NORMAL como prioridad por defecto', () {
      // Arrange
      final json = {
        'id': '1',
        'title': 'Normal',
        'description': 'Desc',
        'createdBy': 'u1',
        'createdAt': '',
        'updatedAt': '',
      };

      // Act
      final model = AnnouncementModel.fromJson(json);

      // Assert
      expect(model.priority, 'NORMAL');
    });
  });
}
