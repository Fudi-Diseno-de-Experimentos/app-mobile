import '../repositories/chat_repository.dart';

class DisconnectChatUseCase {
  final ChatRepository repository;

  DisconnectChatUseCase(this.repository);

  Future<void> call() => repository.disconnect();
}
