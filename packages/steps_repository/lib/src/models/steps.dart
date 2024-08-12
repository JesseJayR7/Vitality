import 'package:steps_repository/steps_repository.dart';

class Steps{
  int steps;
  DateTime timeStamp;
  
  Steps({
    required this.steps,
    required this.timeStamp,
  });

  //empty user which represents an authenticated user.

  static final empty = Steps(
    steps: 0,
    timeStamp: DateTime.now(),
  );

  // modify Post parameters
  Steps copyWith({
    int? steps,
    DateTime? timeStamp,
  }){
    return Steps(
      steps: steps ?? this.steps, 
      timeStamp: timeStamp?? this.timeStamp,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == Steps.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != Steps.empty;

  StepsEntity toEntity(){
    return StepsEntity(
      steps: steps,
      timeStamp: timeStamp,
    );
  }

  static Steps fromEntity(StepsEntity entity){
    return Steps(
      steps: entity.steps,
      timeStamp: entity.timeStamp,
    );
  }

  String toString(){
    return '''Steps: {
      steps: $steps,
      timeStamp: $timeStamp,
    }''';
  }
}