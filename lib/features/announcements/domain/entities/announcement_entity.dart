import 'package:equatable/equatable.dart';

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String priority;
  final String createdBy;
  final String createdAt;
  final String updatedAt;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        image,
        priority,
        createdBy,
        createdAt,
        updatedAt,
      ];
}
