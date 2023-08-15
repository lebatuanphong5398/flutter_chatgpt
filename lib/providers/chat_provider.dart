import 'package:first_app/models/chat_models.dart';
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatNotifier extends StateNotifier<List<ChatModel>> {
  ChatNotifier() : super([]);
  void addUserMessage({required String msg, required String chatid}) {
    state = [...state, ChatModel(msg: msg, chatIndex: 0)];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('conversations').doc(chatid).set({
      'message': listchat,
      'createdAt': Timestamp.now(),
    });
  }

  void refreshChat() {
    state = [];
  }

  Future<List<ChatModel>> getchatlist(String chatid) async {
    final data = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(chatid)
        .get();
    List<ChatModel> listchat = [];
    for (var i = 0; i < data["message"].length; i++) {
      var number = i % 2; // 0 or 1
      listchat.add(ChatModel(msg: data["message"][i], chatIndex: number));
    }
    state = listchat;
    return listchat;
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg,
      required String chosenModelId,
      required String chatid}) async {
    ChatModel chat = await ApiService.sendMessageGPT(
      message: msg,
      modelId: chosenModelId,
    );
    state = [...state, chat];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('conversations').doc(chatid).set({
      'message': listchat,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> sendMessageAndGetImage(
      {required String msg,
      required String chosenModelId,
      required String chatid}) async {
    ChatModel chat = await ApiService.generationsimages(
      message: msg,
    );
    state = [...state, chat];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('conversations').doc(chatid).set({
      'message': listchat,
      'createdAt': Timestamp.now(),
    });
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatModel>>((ref) {
  return ChatNotifier();
});
