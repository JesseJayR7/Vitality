part of 'create_workout_bloc.dart';

sealed class CreateWorkoutEvent extends Equatable {
  const CreateWorkoutEvent();

  @override
  List<Object> get props => [];
}

class CreateWorkout extends CreateWorkoutEvent {
  final Workout workout;

  const CreateWorkout({required this.workout,});
}