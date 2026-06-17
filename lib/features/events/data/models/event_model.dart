import 'package:app_mobile/features/events/domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.spaceId,
    required super.createdBy,
    required super.recipients,
    super.myStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      spaceId: json['spaceId'] ?? '',
      createdBy: json['createdBy'] ?? '',
      recipients: _parseRecipients(json),
      myStatus: _statusOrNull(json['myStatus']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'spaceId': spaceId,
      'createdBy': createdBy,
      'recipients': recipients
          .map((r) => {'userId': r.userId, 'status': _statusToJson(r.status)})
          .toList(),
      'myStatus': myStatus == null ? null : _statusToJson(myStatus!),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Parses the new `recipients: [{userId, status}]` shape, falling back to the
  /// legacy flat `recipientIds: [uuid]` shape (older payloads / stale cache).
  static List<EventRecipient> _parseRecipients(Map<String, dynamic> json) {
    final raw = json['recipients'];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => EventRecipient(
                userId: (e['userId'] ?? '').toString(),
                status: _statusFromJson(e['status']),
              ))
          .toList();
    }
    final legacy = json['recipientIds'];
    if (legacy is List) {
      return legacy
          .map((e) => EventRecipient(userId: e.toString()))
          .toList();
    }
    return const [];
  }

  /// Per-recipient status. A null/unknown value means PENDING (legacy rows).
  static RecipientStatus _statusFromJson(dynamic value) {
    switch ((value as String?)?.toUpperCase()) {
      case 'ACCEPTED':
        return RecipientStatus.accepted;
      case 'DECLINED':
        return RecipientStatus.declined;
      default:
        return RecipientStatus.pending;
    }
  }

  /// Caller's own status, where null genuinely means "not a recipient".
  static RecipientStatus? _statusOrNull(dynamic value) {
    if (value == null) return null;
    return _statusFromJson(value);
  }

  static String _statusToJson(RecipientStatus status) {
    switch (status) {
      case RecipientStatus.accepted:
        return 'ACCEPTED';
      case RecipientStatus.declined:
        return 'DECLINED';
      case RecipientStatus.pending:
        return 'PENDING';
    }
  }
}
