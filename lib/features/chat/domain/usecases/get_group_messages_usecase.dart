import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetGroupMessagesUseCase {
  final ChatRepository repository;

  GetGroupMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String groupId) {
    return repository.getGroupMessages(groupId);
  }
}
