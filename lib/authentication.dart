import 'dart:developer';

import 'package:chat_repository/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrate_repository/hydrate_repository.dart';
import 'package:meals_repository/meals_repository.dart';
import 'package:steps_repository/steps_repository.dart';
import 'package:vitality/blocs/authentication_bloc/authentication_bloc.dart';
import 'package:vitality/blocs/create_chat_bloc/create_hydrate_bloc.dart';
import 'package:vitality/blocs/create_hydrate_bloc/create_hydrate_bloc.dart';
import 'package:vitality/blocs/create_meals_bloc/create_meals_bloc.dart';
import 'package:vitality/blocs/create_steps_bloc/create_steps_bloc.dart';
import 'package:vitality/blocs/create_workout_bloc/create_workout_bloc.dart';
import 'package:vitality/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:vitality/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'package:vitality/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'package:vitality/screens/home_screen.dart';
import 'package:vitality/screens/sign_up_screen.dart';
import 'package:workout_repository/workout_repository.dart';

class Authentication extends StatefulWidget {
  final String apiKey;
  const Authentication({super.key, required this.apiKey});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
   final _vitalityUsers = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
           final user = FirebaseAuth.instance.currentUser;
            Stream<bool> accountCheck() async* {
              late QuerySnapshot<Map<String, dynamic>> querySnapshot;
    try {
      // Query the collection for documents with the specified email
      querySnapshot = await _vitalityUsers
          .where('email', isEqualTo: user?.email.toString())
          .get();
          
    } catch (error) {
      // Handle errors
      log('Error checking email existence: $error');
    }

    yield querySnapshot.docs.isNotEmpty;
    }
        return StreamBuilder<bool>(
            stream: accountCheck(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Return a loading indicator while waiting for the stream to emit data
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle errors
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    if (state.status == AuthenticationStatus.authenticated &&
                    snapshot.data == true) {
                      return MultiBlocProvider(
                        providers: [
                          // BlocProvider(
                          //   create: (context) => BottomNavBloc(),
                          // ),
                          BlocProvider(
                            create: (context) => SignUpBloc(
                                userRepository: context
                                    .read<AuthenticationBloc>()
                                    .userRepository),
                          ),
                          BlocProvider(
                            create: (context) => SignInBloc(
                                userRepository: context
                                    .read<AuthenticationBloc>()
                                    .userRepository),
                          ),
                          BlocProvider(
                            create: (context) => MyUserBloc(
                                myUserRepository:
                                    context.read<AuthenticationBloc>().userRepository)
                              ..add(GetMyUser(
                                  myUserId:
                                      context.read<AuthenticationBloc>().state.user!.uid)),
                          ),
                          BlocProvider(
                              create: (context) => CreateStepsBloc(
                            stepsRepository: FirebaseStepsRepository())),
                          BlocProvider(
                              create: (context) => CreateWorkoutBloc(
                            workoutRepository: FirebaseWorkoutRepository())),
                          BlocProvider(
                              create: (context) => CreateMealsBloc(
                            mealsRepository: FirebaseMealsRepository())),
                          BlocProvider(
                              create: (context) => CreateHydrateBloc(
                            hydrateRepository: FirebaseHydrateRepository())),
                          BlocProvider(
                              create: (context) => CreateChatBloc(
                            chatRepository: FirebaseChatsRepository())),
                        ],
                        child: const HomeScreen(apiKey: String.fromEnvironment('GEMINI_API_KEY'),),
                      );
                    } else {
                      return BlocProvider(
                        create: (context) => SignUpBloc(
                            userRepository: context
                                .read<AuthenticationBloc>()
                                .userRepository),
                        child: const SignUpScreen(),
                      );
                    }
                  },
                );
              }
            });
      } else{
         return BlocProvider(
                        create: (context) => SignUpBloc(
                            userRepository: context
                                .read<AuthenticationBloc>()
                                .userRepository),
                        child: const SignUpScreen(),
                      );
      }
      },
    );
  }
}
