import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;

  /// Booked room id. Every event reserves exactly one managed room.
  final String spaceId;
  final String createdBy;
  final List<String> recipientIds;
  final String createdAt;
  final String updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.spaceId,
    required this.createdBy,
    required this.recipientIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        spaceId,
        createdBy,
        recipientIds,
        createdAt,
        updatedAt,
      ];
}
