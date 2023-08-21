import 'dart:io';

import 'package:first_app/models/chat_models.dart';
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageNotifier extends StateNotifier<List<ChatModel>> {
  ImageNotifier() : super([]);
  void addUserMessage({required String msg, required String chatid}) {
    state = [...state, ChatModel(msg: msg, chatIndex: 0)];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('images').doc(chatid).set({
      'message': listchat,
      'createdAt': Timestamp.now(),
    });
  }

  void refreshChat() {
    state = [];
  }

  void deleteimage({required String imageName}) {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$imageName.jpg');
    storageRef.delete();
  }

  Future<List<ChatModel>> getchatlist(String chatid) async {
    final data =
        await FirebaseFirestore.instance.collection('images').doc(chatid).get();
    List<ChatModel> listchat = [];
    for (var i = 0; i < data["message"].length; i++) {
      var number = i % 2; // 0 or 1
      listchat.add(ChatModel(msg: data["message"][i], chatIndex: number));
    }
    state = listchat;
    return listchat;
  }

  Future<void> sendMessageAndGetImage(
      {required String msg,
      required String chosenModelId,
      required String chatid}) async {
    ChatModel chat = await ApiService.generationsimages(
      message: msg,
    );

    final imageUrl = chat.msg;
    final response = await http.get(Uri.parse(imageUrl));

    final appDocDir = await getApplicationDocumentsDirectory();
    Timestamp time = Timestamp.now();
    final imageName = '$time.jpg';
    final imagePath = '${appDocDir.path}/$imageName';
    final imageFile = File(imagePath);
    await imageFile.writeAsBytes(response.bodyBytes);

    final storageRef =
        FirebaseStorage.instance.ref().child('user_images').child('$time.jpg');
    await storageRef.putFile(imageFile);
    final imageUrl2 = await storageRef.getDownloadURL();
    //print(imageUrl2);
    chat.msg = '$imageUrl2/${time.toString()}';

    imageFile.deleteSync();
    state = [...state, chat];
    List<String> listchat = state.map((e) => e.msg).toList();
    FirebaseFirestore.instance.collection('images').doc(chatid).set({
      'message': listchat,
      'createdAt': time,
    });
  }
}

final imageProvider =
    StateNotifierProvider<ImageNotifier, List<ChatModel>>((ref) {
  return ImageNotifier();
});
