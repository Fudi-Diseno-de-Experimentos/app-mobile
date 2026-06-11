import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Soft-deletes a message (status -> DELETED, hidden from the thread).
class DeleteMessageUseCase {
  final ChatRepository repository;

  DeleteMessageUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String chatId,
    required String messageId,
  }) {
    return repository.deleteMessage(chatId: chatId, messageId: messageId);
  }
}
