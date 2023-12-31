import 'dart:io';

import 'package:first_app/models/srm_model.dart';
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:langchain/langchain.dart';

class SMRNotifier extends StateNotifier<List<SmrModel>> {
  SMRNotifier() : super([]);

  void addfile({required File file}) async {
    state = [
      SmrModel(
          msg: "Xin chào, bạn muốn hỏi gì về tài liệu",
          chatIndex: 1,
          file: file)
    ];
  }

  void addUserMessage(
      {required String msg, required File file, required String chatid}) {
    state = [...state, SmrModel(msg: msg, chatIndex: 0, file: file)];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('Summary').doc(chatid).set({
      'message': listchat,
      'filepath': file.path,
    });
  }

  void refreshChat() {
    state = [];
  }

  Future<List<SmrModel>> getchatlist(String chatid, File file) async {
    final data = await FirebaseFirestore.instance
        .collection('Summary')
        .doc(chatid)
        .get();
    List<SmrModel> listchat = [];
    for (var i = 0; i < data["message"].length; i++) {
      var number = (i + 1) % 2; // 0 or 1
      //print(data["message"][i]);
      listchat.add(
          SmrModel(msg: data["message"][i], chatIndex: number, file: file));
    }
    state = listchat;
    return listchat;
  }

  Future<void> sendMessageSMR(
      {required String msg,
      required String chatid,
      required File file,
      required RetrievalQAChain retrievalQA}) async {
    SmrModel chat = await ApiService.sendMessageSMR(
        message: msg, file: file, retrievalQA: retrievalQA);
    state = [...state, chat];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('Summary').doc(chatid).set({
      'message': listchat,
      'filepath': file.path,
    });
  }
}

final sMRProvider = StateNotifierProvider<SMRNotifier, List<SmrModel>>((ref) {
  return SMRNotifier();
});
