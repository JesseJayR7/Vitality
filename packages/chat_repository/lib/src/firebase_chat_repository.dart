import 'package:chat_repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import 'chat_repo.dart';

class FirebaseChatsRepository implements ChatRepository {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference<Map<String, dynamic>> chatsCollection;

  @override
  Future<void> setChatData(Chats meals) async {
    CollectionReference<Map<String, dynamic>> chatsCollection =
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Chats');
    try {
      await chatsCollection.doc().set(meals.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
