import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/conversation_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetMyConversationsUseCase {
  final ChatRepository repository;

  GetMyConversationsUseCase(this.repository);

  Future<Either<Failure, List<ConversationEntity>>> call() {
    return repository.getMyConversations();
  }
}
