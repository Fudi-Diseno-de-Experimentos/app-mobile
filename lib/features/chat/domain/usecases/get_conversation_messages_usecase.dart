import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationMessagesUseCase {
  final ChatRepository repository;

  GetConversationMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String conversationId) {
    return repository.getConversationMessages(conversationId);
  }
}
