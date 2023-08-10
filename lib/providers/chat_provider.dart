import 'package:first_app/models/chat_models.dart';
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotifier extends StateNotifier<List<ChatModel>> {
  ChatNotifier() : super([]);
  void addUserMessage({required String msg}) {
    state = [...state, ChatModel(msg: msg, chatIndex: 0)];
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId}) async {
    state = [
      ...state,
      await ApiService.sendMessageGPT(message: msg, modelId: chosenModelId)
    ];
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatModel>>((ref) {
  return ChatNotifier();
});
