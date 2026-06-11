import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';

class WatchMessagesUseCase {
  final ChatRepository repository;

  WatchMessagesUseCase(this.repository);

  Stream<MessageEntity> call(String groupId) {
    return repository.watchMessages(groupId);
  }
}
