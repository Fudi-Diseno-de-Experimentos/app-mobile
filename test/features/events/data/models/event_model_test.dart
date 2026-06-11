import 'package:app_mobile/features/events/data/models/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel - US18: Basic event creation', () {
    test('fromJson should build a valid model with all fields', () {
      // Arrange
      final json = {
        'id': 'evt-1',
        'title': 'Quarterly Meeting',
        'description': 'Q1 goals review',
        'date': '2024-03-15T10:00:00Z',
        'location': 'Sala Principal',
        'createdBy': 'manager-1',
        'recipientIds': ['emp-1', 'emp-2', 'emp-3'],
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      // Act
      final model = EventModel.fromJson(json);

      // Assert
      expect(model.id, 'evt-1');
      expect(model.title, 'Quarterly Meeting');
      expect(model.description, 'Q1 goals review');
      expect(model.date, '2024-03-15T10:00:00Z');
      expect(model.location, 'Sala Principal');
      expect(model.createdBy, 'manager-1');
      expect(model.recipientIds, ['emp-1', 'emp-2', 'emp-3']);
    });

    test('fromJson should handle empty recipientIds', () {
      // Arrange
      final json = {
        'id': 'evt-2',
        'title': 'Event without invitees',
        'description': 'Desc',
        'date': '2024-03-15',
        'location': 'Sala B',
        'createdBy': 'manager-1',
        'recipientIds': [],
        'createdAt': '',
        'updatedAt': '',
      };

      // Act
      final model = EventModel.fromJson(json);

      // Assert
      expect(model.recipientIds, isEmpty);
    });

    test('fromJson should handle null recipientIds as an empty list', () {
      // Arrange
      final json = {
        'id': 'evt-3',
        'title': 'Event',
        'description': 'Desc',
        'date': '',
        'location': '',
        'createdBy': '',
        'createdAt': '',
        'updatedAt': '',
      };

      // Act
      final model = EventModel.fromJson(json);

      // Assert
      expect(model.recipientIds, isEmpty);
    });

    test('fromJson should use defaults when fields are missing', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final model = EventModel.fromJson(json);

      // Assert
      expect(model.id, '');
      expect(model.title, '');
      expect(model.description, '');
      expect(model.date, '');
      expect(model.location, '');
      expect(model.createdBy, '');
      expect(model.recipientIds, isEmpty);
    });

    test('toJson should produce a valid map for the API', () {
      // Arrange
      const model = EventModel(
        id: 'evt-1',
        title: 'Meeting',
        description: 'Description',
        date: '2024-03-15T10:00:00Z',
        location: 'Sala A',
        createdBy: 'manager-1',
        recipientIds: ['emp-1', 'emp-2'],
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-02T00:00:00Z',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 'evt-1');
      expect(json['title'], 'Meeting');
      expect(json['recipientIds'], ['emp-1', 'emp-2']);
      expect(json['location'], 'Sala A');
    });

    test('toJson/fromJson should be symmetric (roundtrip)', () {
      // Arrange
      const original = EventModel(
        id: 'evt-1',
        title: 'Roundtrip',
        description: 'Test',
        date: '2024-03-15',
        location: 'Sala',
        createdBy: 'user-1',
        recipientIds: ['emp-1'],
        createdAt: '2024-01-01',
        updatedAt: '2024-01-02',
      );

      // Act
      final json = original.toJson();
      final restored = EventModel.fromJson(json);

      // Assert
      expect(restored, equals(original));
    });
  });
}
