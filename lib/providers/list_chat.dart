import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListChatNotifier extends StateNotifier<List<String>> {
  ListChatNotifier() : super([]);
  void getlistchat() async {
    final list = await FirebaseFirestore.instance.collectionGroup("").get();
    print('______________________________________________-$list');
  }
}

final listchatProvider =
    StateNotifierProvider<ListChatNotifier, List<String>>((ref) {
  return ListChatNotifier();
});
