class StepsEntity{
  int steps;
  DateTime timeStamp;

  StepsEntity(
      {
      required this.steps,
      required this.timeStamp
    });

  Map<String, Object?> toDocument() {
    return {
      'steps': steps,
      'timeStamp': timeStamp,
    };
  }

  static StepsEntity fromDocument(Map<String, dynamic> doc) {
    return StepsEntity(
			steps: doc['steps'] as int,
      timeStamp: doc['timeStamp'] as DateTime,
    );
  }
  
  @override
  List<Object?> get props=> [
    steps,
    timeStamp,
  ];


  @override
  String toString(){
    return '''StepsEntity: {
      steps: $steps,
      timeStamp: $timeStamp,
    }''';
  }
}