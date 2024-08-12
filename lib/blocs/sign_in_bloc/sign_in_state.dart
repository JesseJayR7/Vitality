part of 'sign_in_bloc.dart';

@immutable
abstract class SignInState extends Equatable{
  const SignInState();

  @override
  List<Object> get props => [];
}

final class SignInInitial extends SignInState {}

final class SignInSuccess extends SignInState {}

// ignore: must_be_immutable
final class SignInFailure extends SignInState {
  String errorMessage;

  SignInFailure({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class SignInProcess extends SignInState {}