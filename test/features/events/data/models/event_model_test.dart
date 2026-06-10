import 'package:flutter_test/flutter_test.dart';
import 'package:app_mobile/features/events/data/models/event_model.dart';

void main() {
  group('EventModel - US18: Creación básica de eventos', () {
    test('fromJson debe crear un modelo válido con todos los campos', () {
      // Arrange
      final json = {
        'id': 'evt-1',
        'title': 'Reunión Trimestral',
        'description': 'Revisión de objetivos Q1',
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
      expect(model.title, 'Reunión Trimestral');
      expect(model.description, 'Revisión de objetivos Q1');
      expect(model.date, '2024-03-15T10:00:00Z');
      expect(model.location, 'Sala Principal');
      expect(model.createdBy, 'manager-1');
      expect(model.recipientIds, ['emp-1', 'emp-2', 'emp-3']);
    });

    test('fromJson debe manejar recipientIds vacío', () {
      // Arrange
      final json = {
        'id': 'evt-2',
        'title': 'Evento sin invitados',
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

    test('fromJson debe manejar recipientIds nulo como lista vacía', () {
      // Arrange
      final json = {
        'id': 'evt-3',
        'title': 'Evento',
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

    test('fromJson debe usar valores por defecto cuando faltan campos', () {
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

    test('toJson debe generar un mapa válido para el API', () {
      // Arrange
      const model = EventModel(
        id: 'evt-1',
        title: 'Reunión',
        description: 'Descripción',
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
      expect(json['title'], 'Reunión');
      expect(json['recipientIds'], ['emp-1', 'emp-2']);
      expect(json['location'], 'Sala A');
    });

    test('toJson/fromJson debe ser simétrico (roundtrip)', () {
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
