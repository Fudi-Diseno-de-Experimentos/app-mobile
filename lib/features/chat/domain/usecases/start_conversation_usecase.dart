import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

/// Get-or-create a 1:1 DM with [targetUserId] (`POST /api/v1/conversations`).
/// Idempotent: returns the existing conversation if one already exists.
class StartConversationUseCase {
  final ChatRepository repository;

  StartConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call(String targetUserId) {
    return repository.startConversation(targetUserId);
  }
}
