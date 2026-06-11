import 'package:app_mobile/features/announcements/data/models/announcement_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnnouncementModel - US10: Basic announcement publishing', () {
    test('fromJson should build a valid model with all fields', () {
      // Arrange
      final json = {
        'id': 'ann-1',
        'title': 'Important Announcement',
        'description': 'Announcement content',
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
      expect(model.title, 'Important Announcement');
      expect(model.description, 'Announcement content');
      expect(model.image, 'https://example.com/image.png');
      expect(model.priority, 'HIGH');
      expect(model.createdBy, 'user-1');
      expect(model.createdAt, '2024-01-01T00:00:00Z');
      expect(model.updatedAt, '2024-01-02T00:00:00Z');
    });

    test('fromJson should handle a null image correctly', () {
      // Arrange
      final json = {
        'id': 'ann-2',
        'title': 'Sin imagen',
        'description': 'Description',
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

    test('fromJson should use defaults when fields are missing', () {
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

    test('toJson should produce a valid map for the API', () {
      // Arrange
      const model = AnnouncementModel(
        id: 'ann-1',
        title: 'Title',
        description: 'Description',
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
      expect(json['title'], 'Title');
      expect(json['description'], 'Description');
      expect(json['image'], 'url.png');
      expect(json['priority'], 'HIGH');
      expect(json['createdBy'], 'user-1');
    });

    test('toJson/fromJson should be symmetric (roundtrip)', () {
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

  group('AnnouncementModel - US11: Announcement prioritization', () {
    test('fromJson should parse HIGH priority correctly', () {
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

    test('fromJson should default the priority to NORMAL', () {
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
