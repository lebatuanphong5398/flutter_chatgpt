import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ChatidNotifier extends StateNotifier<String> {
  ChatidNotifier() : super("${uuid.v4()}");

  void changeChatid() {
    state = uuid.v4();
  }
}

final chatidProvider = StateNotifierProvider<ChatidNotifier, String>((ref) {
  return ChatidNotifier();
});
