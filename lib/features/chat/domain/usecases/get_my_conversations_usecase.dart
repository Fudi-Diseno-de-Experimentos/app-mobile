import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetMyConversationsUseCase {
  final ChatRepository repository;

  GetMyConversationsUseCase(this.repository);

  Future<Either<Failure, List<ConversationEntity>>> call() {
    return repository.getMyConversations();
  }
}
