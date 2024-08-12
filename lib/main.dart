import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:vitality/app.dart';
import 'package:vitality/firebase_options.dart';
import 'package:vitality/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

   // Set Bloc observer
  Bloc.observer = SimpleBlocObserver();
  
  // Set preferred device orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(MainApp(FirebaseUserRepository(), const String.fromEnvironment('GEMINI_API_KEY')));
}