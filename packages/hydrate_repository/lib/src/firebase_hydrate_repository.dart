import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hydrate_repository/hydrate_repository.dart';
import 'package:hydrate_repository/src/hydrate_repo.dart';

class FirebaseHydrateRepository implements HydrateRepository {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference<Map<String, dynamic>> hdyrateCollection;

  @override
  Future<void> setHydrateData(Hydrate hydrate) async {
    CollectionReference<Map<String, dynamic>> hydrateCollection =
  FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Hydrate');
    try {   
      hydrate.timeStamp =
          DateTime.now();
      await hydrateCollection.doc().set(hydrate.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
