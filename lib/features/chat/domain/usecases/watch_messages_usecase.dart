import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<MessageEntity> call(String groupId) {
    return repository.watchMessages(groupId);
  }
}
