import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:steps_repository/steps_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStepsRepository implements StepsRepository {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference<Map<String, dynamic>> stepsCollection;

  @override
  Future<void> setStepsData(Steps steps) async {
    CollectionReference<Map<String, dynamic>> stepsCollection =
  FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Steps');
    try {   
      steps.timeStamp =
          DateTime.now();
      await stepsCollection.doc().set(steps.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
