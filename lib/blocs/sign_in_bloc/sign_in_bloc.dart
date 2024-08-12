import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final UserRepository _userRepository;

  SignInBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SignInInitial()) {
    on<SignInRequired>((event, emit) async{
      emit(SignInProcess());
      try {        
        await _userRepository.signIn(event.email, event.password);     
         emit(SignInSuccess());
      } on FirebaseAuthException catch (e) {
        log(e.code.toString());      
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'This email does not exist';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password';
            break;
          case 'user-disabled':
            errorMessage = 'This user has been disabled';
            break;
          case 'invalid-credential':
            errorMessage = 'Email or password credential incorrect';
            break;
          case 'too-many-requests':
            errorMessage = 'We have blocked all requests from this device due to unusual activity. Try again later.';
            break;
          default:
            errorMessage = 'An unknown error occurred';
        }
        emit(SignInFailure(errorMessage: errorMessage));
      }
    });
    on<SignOutRequired>((event, emit) async{
      await _userRepository.logOut();   
    });
  }
}
