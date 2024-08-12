import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_repository/workout_repository.dart';

part 'create_workout_event.dart';
part 'create_workout_state.dart';

class CreateWorkoutBloc extends Bloc<CreateWorkoutEvent, CreateWorkoutState> {
  final WorkoutRepository _workoutRepository;

  CreateWorkoutBloc({
    required WorkoutRepository workoutRepository,
  }) : _workoutRepository = workoutRepository,
  super(CreateWorkoutInitial()) {
    on<CreateWorkout>((event, emit) async{
      emit(CreateWorkoutLoading());
      try {
      _workoutRepository.setWorkoutData(event.workout);
        emit(CreateWorkoutSuccess());
      } catch (e) {
        emit(CreateWorkoutFailure());
      }
    });
  }
}
