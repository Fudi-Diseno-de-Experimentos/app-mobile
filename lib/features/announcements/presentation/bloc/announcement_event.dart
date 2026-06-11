import 'package:equatable/equatable.dart';

abstract class AnnouncementEvent extends Equatable {
  const AnnouncementEvent();

  @override
  List<Object> get props => [];
}

class FetchAnnouncements extends AnnouncementEvent {
  /// Skip caches and hit the API (pull-to-refresh).
  final bool forceRefresh;

  const FetchAnnouncements({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

/// Fetch announcements filtered by priority. A null/empty [priority] loads all
/// (`GET /announcements`); a value loads `GET /announcements/priority/{priority}`.
class FetchAnnouncementsByPriority extends AnnouncementEvent {
  final String? priority;

  const FetchAnnouncementsByPriority(this.priority);

  @override
  List<Object> get props => [priority ?? ''];
}

/// Fetch announcements filtered by creator
/// (`GET /announcements/creator/{createdBy}`). A null/empty [createdBy] loads
/// all (`GET /announcements`).
class FetchAnnouncementsByCreator extends AnnouncementEvent {
  final String? createdBy;

  const FetchAnnouncementsByCreator(this.createdBy);

  @override
  List<Object> get props => [createdBy ?? ''];
}

/// Fetch a single announcement (`GET /announcements/{id}`) for a fresh detail
/// view instead of relying on possibly-stale route-passed data.
class FetchAnnouncementById extends AnnouncementEvent {
  final String id;

  const FetchAnnouncementById(this.id);

  @override
  List<Object> get props => [id];
}

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

class UpdateAnnouncementRequested extends AnnouncementEvent {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String priority;

  const UpdateAnnouncementRequested({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.priority,
  });

  @override
  List<Object> get props => [id, title, description, image ?? '', priority];
}

class DeleteAnnouncementRequested extends AnnouncementEvent {
  final String id;

  const DeleteAnnouncementRequested(this.id);

  @override
  List<Object> get props => [id];
}
