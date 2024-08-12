import 'package:intl/intl.dart';
import 'package:workout_repository/workout_repository.dart';

class Workout {
  List<String> workoutRegions;
  String duration;
  double caloriesBurned;
  DateTime timeStamp;

  Workout({
    required this.workoutRegions,
    required this.duration,
    required this.caloriesBurned,
    required this.timeStamp,
  });

  //empty user which represents an authenticated user.

  static final empty = Workout(
    workoutRegions : [],
    duration : DateFormat('HH:mm').format(DateTime.now()),
    caloriesBurned : 0.0,
    timeStamp: DateTime.now(),
  );

  // modify Post parameters
  Workout copyWith({
    List<String>? workoutRegions,
    String? duration,
    double? caloriesBurned,
    DateTime? timeStamp,
  }) {
    return Workout(
      workoutRegions : workoutRegions ?? this.workoutRegions,
      duration : duration ?? this.duration,
      caloriesBurned : caloriesBurned ?? this.caloriesBurned,
      timeStamp: timeStamp ?? this.timeStamp,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == Workout.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != Workout.empty;

  WorkoutEntity toEntity() {
    return WorkoutEntity(
      workoutRegions : workoutRegions,
      duration : duration,
      caloriesBurned : caloriesBurned,
      timeStamp: timeStamp,
    );
  }

  static Workout fromEntity(WorkoutEntity entity) {
    return Workout(
      workoutRegions : entity.workoutRegions,
      duration : entity.duration,
      caloriesBurned : entity.caloriesBurned,
      timeStamp: entity.timeStamp,
    );
  }

  String toString() {
    return '''Workout: {
      workoutRegions : $workoutRegions,
      duration : $duration,
      caloriesBurned : $caloriesBurned,
      timeStamp: $timeStamp,
    }''';
  }
}
