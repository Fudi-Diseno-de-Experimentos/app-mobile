import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object> get props => [];
}

class FetchAnnouncements extends AnnouncementEvent {}

class CreateAnnouncementRequested extends AnnouncementEvent {
  final String title;
  final String description;
  final String? image;
  final String priority;
  final String createdBy;

  const CreateAnnouncementRequested({
    required this.title,
    required this.description,
    this.image,
    required this.priority,
    required this.createdBy,
  });

  @override
  List<Object> get props => [title, description, image ?? '', priority, createdBy];
}
