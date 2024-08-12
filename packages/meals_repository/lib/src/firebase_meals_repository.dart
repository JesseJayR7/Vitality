import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meals_repository/meals_repository.dart';

class FirebaseMealsRepository implements MealsRepository {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference<Map<String, dynamic>> mealsCollection;

  @override
  Future<void> setMealsData(Meals meals) async {
    CollectionReference<Map<String, dynamic>> mealsCollection =
  FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Meals');
    try {   
      meals.timeStamp =
          DateTime.now();
      await mealsCollection.doc().set(meals.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
