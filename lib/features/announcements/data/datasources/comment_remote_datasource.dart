import 'package:app_mobile/core/network/api_client.dart';
import 'package:app_mobile/features/announcements/data/models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getComments(String announcementId);
  Future<CommentModel> createComment({
    required String announcementId,
    required String content,
    required String authorId,
  });
  Future<void> deleteComment(String commentId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final ApiClient apiClient;
  CommentRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CommentModel>> getComments(String announcementId) async {
    final response = await apiClient.get('/announcements/$announcementId/comments');
    if (response.data != null && response.data is List) {
      return (response.data as List)
          .map((json) =>
              CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<CommentModel> createComment({
    required String announcementId,
    required String content,
    required String authorId,
  }) async {
    final response = await apiClient.post(
      '/announcements/$announcementId/comments',
      // CreateCommentResource = { employeeId, content }
      data: {'employeeId': authorId, 'content': content},
    );
    return CommentModel.fromJson(response.data);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await apiClient.delete('/comments/$commentId');
  }
}
