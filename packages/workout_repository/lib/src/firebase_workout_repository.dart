import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout_repository/workout_repository.dart';

class FirebaseWorkoutRepository implements WorkoutRepository {
  final user = FirebaseAuth.instance.currentUser;
  late CollectionReference<Map<String, dynamic>> workoutCollection;

  @override
  Future<void> setWorkoutData(Workout workout) async {
    CollectionReference<Map<String, dynamic>> stepsCollection =
  FirebaseFirestore.instance.collection('Users').doc(user!.uid).collection('Workout');
    try {   
      workout.timeStamp =
          DateTime.now();
      await stepsCollection.doc().set(workout.toEntity().toDocument());
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}
