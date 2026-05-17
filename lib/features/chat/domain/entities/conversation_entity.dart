import 'package:equatable/equatable.dart';

/// A 1:1 direct conversation (`ConversationResource` from
/// `GET/POST /api/v1/conversations`). The backend models it as an internal
/// `DIRECT` group; [id] is the group/conversation id used for both the message
/// endpoints and the WebSocket topic. [otherUserId] is the participant that is
/// not the current user — used to resolve the display name client-side.
class ConversationEntity extends Equatable {
  final String id;
  final String otherUserId;
  final List<String> memberIds;
  final String createdAt;
  final String updatedAt;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        otherUserId,
        memberIds,
        createdAt,
        updatedAt,
      ];
}
