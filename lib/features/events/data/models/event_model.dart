import 'package:app_mobile/features/events/domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    required super.location,
    required super.createdBy,
    required super.recipientIds,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      createdBy: json['createdBy'] ?? '',
      recipientIds: List<String>.from(json['recipientIds'] ?? []),
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
      'location': location,
      'createdBy': createdBy,
      'recipientIds': recipientIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
