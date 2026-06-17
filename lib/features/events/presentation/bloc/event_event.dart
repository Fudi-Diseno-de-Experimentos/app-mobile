import 'package:app_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:equatable/equatable.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class FetchEvents extends EventEvent {
  /// Skip caches and hit the API (pull-to-refresh).
  final bool forceRefresh;

  /// Recipient-scoping params. When set the list is filtered to this user's
  /// invitations and the server hides events they've declined. Left null for
  /// admins/managers, who see every company event (declined ones included).
  final String? userId;
  final String? filterType;

  const FetchEvents({
    this.forceRefresh = false,
    this.userId,
    this.filterType,
  });

  /// Builds the role-aware fetch: admins/managers (and an unknown profile) get
  /// the unfiltered company list; regular members get only events they're a
  /// recipient of, with declined ones hidden server-side.
  factory FetchEvents.forProfile(
    ProfileEntity? profile, {
    bool forceRefresh = false,
  }) {
    if (profile == null || profile.isManagerOrAdmin) {
      return FetchEvents(forceRefresh: forceRefresh);
    }
    return FetchEvents(
      forceRefresh: forceRefresh,
      userId: profile.userId,
      filterType: 'recipient',
    );
  }

  @override
  List<Object?> get props => [forceRefresh, userId, filterType];
}

class AcceptInvitation extends EventEvent {
  final String eventId;

  const AcceptInvitation(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class DeclineInvitation extends EventEvent {
  final String eventId;

  const DeclineInvitation(this.eventId);

  @override
  List<Object> get props => [eventId];
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
  final String spaceId;
  final String createdBy;
  final List<String> recipientIds;

  const CreateEventRequested({
    required this.title,
    required this.description,
    required this.date,
    required this.spaceId,
    required this.createdBy,
    required this.recipientIds,
  });

  @override
  List<Object?> get props =>
      [title, description, date, spaceId, createdBy, recipientIds];
}

class UpdateEventRequested extends EventEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String spaceId;
  final List<String> recipientIds;

  const UpdateEventRequested({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.spaceId,
    required this.recipientIds,
  });

  @override
  List<Object?> get props =>
      [id, title, description, date, spaceId, recipientIds];
}

class DeleteEventRequested extends EventEvent {
  final String id;

  const DeleteEventRequested(this.id);

  @override
  List<Object> get props => [id];
}
