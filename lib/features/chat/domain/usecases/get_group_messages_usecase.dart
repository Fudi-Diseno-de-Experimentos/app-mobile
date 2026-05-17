import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetGroupMessagesUseCase {
  final ChatRepository repository;

  GetGroupMessagesUseCase(this.repository);

  Future<Either<Failure, List<MessageEntity>>> call(String groupId) {
    return repository.getGroupMessages(groupId);
  }
}
