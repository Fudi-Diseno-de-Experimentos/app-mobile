import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;
  final String location;
  final String createdBy;
  final List<String> recipientIds;
  final String createdAt;
  final String updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
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
        location,
        createdBy,
        recipientIds,
        createdAt,
        updatedAt,
      ];
}
