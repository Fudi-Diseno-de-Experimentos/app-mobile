import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class FetchEvents extends EventEvent {
  /// Skip caches and hit the API (pull-to-refresh).
  final bool forceRefresh;

  const FetchEvents({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class FetchCompanyMembers extends EventEvent {
  final String companyId;

  const FetchCompanyMembers(this.companyId);

  @override
  List<Object> get props => [companyId];
}

class CreateEventRequested extends EventEvent {
  final String title;
  final String description;
  final String date;
  final String location;
  final String? spaceId;
  final String createdBy;
  final List<String> recipientIds;

  const CreateEventRequested({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.spaceId,
    required this.createdBy,
    required this.recipientIds,
  });

  @override
  List<Object?> get props =>
      [title, description, date, location, spaceId, createdBy, recipientIds];
}

class UpdateEventRequested extends EventEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String location;
  final String? spaceId;
  final List<String> recipientIds;

  const UpdateEventRequested({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    this.spaceId,
    required this.recipientIds,
  });

  @override
  List<Object?> get props =>
      [id, title, description, date, location, spaceId, recipientIds];
}

class DeleteEventRequested extends EventEvent {
  final String id;

  const DeleteEventRequested(this.id);

  @override
  List<Object> get props => [id];
}
