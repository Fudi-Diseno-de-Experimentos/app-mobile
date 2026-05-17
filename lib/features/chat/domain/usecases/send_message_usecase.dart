import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  void call({
    required String groupId,
    required String senderId,
    required String body,
  }) {
    repository.sendMessage(
      groupId: groupId,
      senderId: senderId,
      body: body,
    );
  }
}
