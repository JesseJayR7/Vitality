import 'package:workout_repository/workout_repository.dart';

abstract class WorkoutRepository{

  Future<void> setWorkoutData(Workout workout);
}