import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Edits a message body. Only the author may edit (enforced server-side).
class EditMessageUseCase {
  final ChatRepository repository;

  EditMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call({
    required String chatId,
    required String messageId,
    required String body,
  }) {
    return repository.editMessage(
      chatId: chatId,
      messageId: messageId,
      body: body,
    );
  }
}
