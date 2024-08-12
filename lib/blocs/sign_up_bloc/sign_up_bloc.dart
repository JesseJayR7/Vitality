import 'dart:developer' as dev;
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final UserRepository _userRepository;
  Future<String> generateClientCode() async {
    const length = 17;
    const lettersLowercase = 'abcdefghijkmnopqrstuvwxyz';
    const lettersUppercase = 'ABCDEFGHJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';

    const chars = '$lettersLowercase$lettersUppercase$numbers';

    String generatedCode;

      generatedCode = List.generate(length, (index) {
        final indexRandom = Random.secure().nextInt(chars.length);
        return chars[indexRandom];
      }).join('');

    return generatedCode;
  }


  SignUpBloc({required userRepository})
      : _userRepository = userRepository,
        super(SignUpInitial()) {
    on<SignUpRequired>((event, emit) async{
      emit(SignUpProcess());
      try {        
        final code = await generateClientCode();
        MyUser user = await _userRepository.signUp(event.user, event.password, code);
        await _userRepository.setUserData(user);
        emit(SignUpSuccess());
      } catch (e) {
        dev.log(e.toString());
        SignUpFailure();
      }
    });
  }
}
