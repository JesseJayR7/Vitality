part of 'my_user_bloc.dart';

@immutable
abstract class MyUserEvent extends Equatable{
  const MyUserEvent();

  @override
  List<Object> get props => [];
} 

class GetMyUser extends MyUserEvent{
  final String myUserId;

  const GetMyUser({required this.myUserId});

  @override
  List<Object> get props => [myUserId];
}

class UpdateMyUser extends MyUserEvent{
  final MyUser myUser;

  const UpdateMyUser({required this.myUser});

  @override
  List<Object> get props => [myUser];
}