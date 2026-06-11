import 'package:app_mobile/features/chat/domain/repositories/chat_repository.dart';

class DisconnectChatUseCase {
  final ChatRepository repository;

  DisconnectChatUseCase(this.repository);

  Future<void> call() => repository.disconnect();
}
