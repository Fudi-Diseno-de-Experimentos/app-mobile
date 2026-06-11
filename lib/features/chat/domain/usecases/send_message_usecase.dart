import 'package:app_mobile/core/error/failures.dart';
import 'package:app_mobile/features/chat/domain/entities/message_entity.dart';
import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Persists a message over REST and returns the stored copy. `senderId` is
/// derived server-side from the JWT, so it is not part of the request.
class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, MessageEntity>> call({
    required String chatId,
    required bool isDirect,
    required String body,
  }) {
    return repository.sendMessage(
      chatId: chatId,
      isDirect: isDirect,
      body: body,
    );
  }
}
