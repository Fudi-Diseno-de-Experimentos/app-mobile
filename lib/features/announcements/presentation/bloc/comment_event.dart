import 'package:equatable/equatable.dart';

abstract class CommentEvent extends Equatable {
  const CommentEvent();

  @override
  List<Object> get props => [];
}

class FetchComments extends CommentEvent {
  final String announcementId;

  /// Skip the cache and hit the API (pull-to-refresh).
  final bool forceRefresh;

  const FetchComments(this.announcementId, {this.forceRefresh = false});

  @override
  List<Object> get props => [announcementId, forceRefresh];
}

class CreateCommentRequested extends CommentEvent {
  final String announcementId;
  final String content;
  final String authorId;

  const CreateCommentRequested({
    required this.announcementId,
    required this.content,
    required this.authorId,
  });

  @override
  List<Object> get props => [announcementId, content, authorId];
}

class DeleteCommentRequested extends CommentEvent {
  final String commentId;
  final String announcementId;

  const DeleteCommentRequested({
    required this.commentId,
    required this.announcementId,
  });

  @override
  List<Object> get props => [commentId, announcementId];
}
