part of 'create_workout_bloc.dart';

sealed class CreateWorkoutState extends Equatable {
  const CreateWorkoutState();
  
  @override
  List<Object> get props => [];
}

final class CreateWorkoutInitial extends CreateWorkoutState {}

final class CreateWorkoutFailure extends CreateWorkoutState {}
final class CreateWorkoutLoading extends CreateWorkoutState {}
final class CreateWorkoutSuccess extends CreateWorkoutState {}