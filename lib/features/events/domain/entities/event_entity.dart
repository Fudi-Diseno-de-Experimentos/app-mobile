import 'package:equatable/equatable.dart';

/// A recipient's response to an event invitation. A `null` status from the API
/// (legacy rows) is treated as [pending].
enum RecipientStatus { pending, accepted, declined }

/// One invited member plus their invitation status. The [userId] is a *user*
/// id (not a profile id) — it's what accept/decline and the recipient filter
/// key on (see ProfileEntity docs).
class EventRecipient extends Equatable {
  final String userId;
  final RecipientStatus status;

  const EventRecipient({
    required this.userId,
    this.status = RecipientStatus.pending,
  });

  @override
  List<Object?> get props => [userId, status];
}

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String date;

  /// Booked room id. Every event reserves exactly one managed room.
  final String spaceId;
  final String createdBy;

  /// Invited members with their per-recipient status.
  final List<EventRecipient> recipients;

  /// The authenticated caller's own invitation status, or `null` when the
  /// caller isn't a recipient (e.g. the creator). Gates the accept/decline UI.
  final RecipientStatus? myStatus;

  final String createdAt;
  final String updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.spaceId,
    required this.createdBy,
    required this.recipients,
    this.myStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  /// User ids of all recipients. Kept for display widgets (AvatarGroup, counts)
  /// and the recipient picker, which don't care about per-recipient status.
  List<String> get recipientIds => recipients.map((r) => r.userId).toList();

  /// This caller's invitation status. Prefers the server's [myStatus] hint
  /// (also set optimistically on accept/decline); otherwise derives it from
  /// [recipients] by matching [userId]. Returns null when [userId] isn't a
  /// recipient (e.g. the creator). This is the single source of truth for
  /// gating the accept/decline controls — `myStatus` alone is unreliable
  /// because the list endpoint doesn't always populate it.
  RecipientStatus? statusFor(String? userId) {
    if (myStatus != null) return myStatus;
    if (userId == null) return null;
    for (final r in recipients) {
      if (r.userId == userId) return r.status;
    }
    return null;
  }

  EventEntity copyWith({
    List<EventRecipient>? recipients,
    RecipientStatus? myStatus,
  }) {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      date: date,
      spaceId: spaceId,
      createdBy: createdBy,
      recipients: recipients ?? this.recipients,
      myStatus: myStatus ?? this.myStatus,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        spaceId,
        createdBy,
        recipients,
        myStatus,
        createdAt,
        updatedAt,
      ];
}
