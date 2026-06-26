import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Get-or-create a 1:1 DM with [targetUserId] (`POST /api/v1/conversations`).
/// Idempotent: returns the existing conversation if one already exists.
class StartConversationUseCase {
  final ChatRepository repository;

  StartConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call(String targetUserId) {
    return repository.startConversation(targetUserId);
  }
}
