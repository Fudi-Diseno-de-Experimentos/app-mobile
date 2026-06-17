import 'package:app_mobile/features/events/data/models/event_model.dart';
import 'package:app_mobile/features/events/domain/entities/event_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel - US18: Basic event creation', () {
    test('fromJson should parse the recipients[] + myStatus shape', () {
      // Arrange
      final json = {
        'id': 'evt-1',
        'title': 'Quarterly Meeting',
        'description': 'Q1 goals review',
        'date': '2024-03-15T10:00:00Z',
        'spaceId': 'room-1',
        'createdBy': 'manager-1',
        'recipients': [
          {'userId': 'emp-1', 'status': 'ACCEPTED'},
          {'userId': 'emp-2', 'status': 'PENDING'},
          {'userId': 'emp-3', 'status': 'DECLINED'},
        ],
        'myStatus': 'PENDING',
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-01T00:00:00Z',
      };

      // Act
      final model = EventModel.fromJson(json);

      // Assert
      expect(model.id, 'evt-1');
      expect(model.title, 'Quarterly Meeting');
      expect(model.createdBy, 'manager-1');
      expect(model.recipientIds, ['emp-1', 'emp-2', 'emp-3']);
      expect(model.recipients[0].status, RecipientStatus.accepted);
      expect(model.recipients[1].status, RecipientStatus.pending);
      expect(model.recipients[2].status, RecipientStatus.declined);
      expect(model.myStatus, RecipientStatus.pending);
    });

    test('fromJson treats a null recipient status as PENDING', () {
      final json = {
        'id': 'evt-1',
        'recipients': [
          {'userId': 'emp-1', 'status': null},
        ],
      };

      final model = EventModel.fromJson(json);

      expect(model.recipients.single.status, RecipientStatus.pending);
    });

    test('fromJson keeps myStatus null when the caller is not a recipient', () {
      final json = {
        'id': 'evt-1',
        'recipients': [
          {'userId': 'emp-1', 'status': 'ACCEPTED'},
        ],
        'myStatus': null,
      };

      final model = EventModel.fromJson(json);

      expect(model.myStatus, isNull);
    });

    test('fromJson falls back to the legacy flat recipientIds shape', () {
      final json = {
        'id': 'evt-2',
        'recipientIds': ['emp-1', 'emp-2'],
      };

      final model = EventModel.fromJson(json);

      expect(model.recipientIds, ['emp-1', 'emp-2']);
      expect(model.recipients.first.status, RecipientStatus.pending);
    });

    test('fromJson should use defaults when fields are missing', () {
      final json = <String, dynamic>{};

      final model = EventModel.fromJson(json);

      expect(model.id, '');
      expect(model.title, '');
      expect(model.recipientIds, isEmpty);
      expect(model.myStatus, isNull);
    });

    test('toJson should produce a valid map for the API/cache', () {
      const model = EventModel(
        id: 'evt-1',
        title: 'Meeting',
        description: 'Description',
        date: '2024-03-15T10:00:00Z',
        spaceId: 'room-1',
        createdBy: 'manager-1',
        recipients: [
          EventRecipient(userId: 'emp-1', status: RecipientStatus.accepted),
          EventRecipient(userId: 'emp-2'),
        ],
        myStatus: RecipientStatus.pending,
        createdAt: '2024-01-01T00:00:00Z',
        updatedAt: '2024-01-02T00:00:00Z',
      );

      final json = model.toJson();

      expect(json['id'], 'evt-1');
      expect(json['title'], 'Meeting');
      expect(json['spaceId'], 'room-1');
      expect(json['myStatus'], 'PENDING');
      expect(json['recipients'], [
        {'userId': 'emp-1', 'status': 'ACCEPTED'},
        {'userId': 'emp-2', 'status': 'PENDING'},
      ]);
    });

    test('toJson/fromJson should be symmetric (roundtrip)', () {
      const original = EventModel(
        id: 'evt-1',
        title: 'Roundtrip',
        description: 'Test',
        date: '2024-03-15',
        spaceId: 'room-3',
        createdBy: 'user-1',
        recipients: [
          EventRecipient(userId: 'emp-1', status: RecipientStatus.declined),
        ],
        myStatus: RecipientStatus.declined,
        createdAt: '2024-01-01',
        updatedAt: '2024-01-02',
      );

      final json = original.toJson();
      final restored = EventModel.fromJson(json);

      expect(restored, equals(original));
    });
  });

  group('EventEntity.statusFor', () {
    const event = EventModel(
      id: 'evt-1',
      title: 'Meeting',
      description: 'Desc',
      date: '2024-03-15',
      spaceId: 'room-1',
      createdBy: 'manager-1',
      recipients: [
        EventRecipient(userId: 'emp-1'),
        EventRecipient(userId: 'emp-2', status: RecipientStatus.accepted),
      ],
      createdAt: '2024-01-01',
      updatedAt: '2024-01-01',
    );

    test('derives my status from recipients[] when myStatus is null', () {
      expect(event.statusFor('emp-1'), RecipientStatus.pending);
      expect(event.statusFor('emp-2'), RecipientStatus.accepted);
    });

    test('returns null when the user is not a recipient (e.g. the creator)', () {
      expect(event.statusFor('manager-1'), isNull);
      expect(event.statusFor(null), isNull);
    });

    test('prefers the myStatus hint when present (optimistic update)', () {
      final accepted = event.copyWith(myStatus: RecipientStatus.accepted);
      // myStatus wins even though emp-1's recipient row is still pending.
      expect(accepted.statusFor('emp-1'), RecipientStatus.accepted);
    });
  });
}
