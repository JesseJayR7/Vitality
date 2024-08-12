class WorkoutEntity{
  List<String> workoutRegions;
  String duration;
  double caloriesBurned;
  DateTime timeStamp;

  WorkoutEntity(
      {
      required this.workoutRegions,
      required this.duration,
      required this.caloriesBurned,
      required this.timeStamp,
    });

  Map<String, Object?> toDocument() {
    return {
      'workoutRegions': workoutRegions,
      'duration': duration,
      'caloriesBurned' : caloriesBurned,
      'timeStamp': timeStamp,
    };
  }

  static WorkoutEntity fromDocument(Map<String, dynamic> doc) {
    return WorkoutEntity(
			workoutRegions: doc['workoutRegions'] as List<String>,
      duration: doc['duration'] as String,
      caloriesBurned: doc['caloriesBurned'] as double,
      timeStamp: doc['timeStamp'] as DateTime,
    );
  }
  
  @override
  List<Object?> get props=> [
    workoutRegions,
    duration,
    caloriesBurned,
    timeStamp,
  ];


  @override
  String toString(){
    return '''WorkoutEntity: {
      workoutRegions: $workoutRegions,
      duration: $duration,
      caloriesBurned: $caloriesBurned
      timeStamp: $timeStamp,
    }''';
  }
}