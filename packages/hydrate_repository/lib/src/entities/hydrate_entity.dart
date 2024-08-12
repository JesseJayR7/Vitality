class HydrateEntity{
  double waterMeasurment;
  String waterUnit;
  DateTime timeStamp;

  HydrateEntity(
      {
      required this.waterMeasurment,
      required this.waterUnit,
      required this.timeStamp
    });

  Map<String, Object?> toDocument() {
    return {
      'waterMeasurement': waterMeasurment,
      'waterUnit': waterUnit,
      'timeStamp': timeStamp,
    };
  }

  static HydrateEntity fromDocument(Map<String, dynamic> doc) {
    return HydrateEntity(
			waterMeasurment: doc['waterMeasurement'] as double,
      waterUnit: doc['waterUnit'] as String,
      timeStamp: doc['timeStamp'] as DateTime,
    );
  }
  
  @override
  List<Object?> get props=> [
    waterMeasurment,
    waterUnit,
    timeStamp,
  ];


  @override
  String toString(){
    return '''HydrateEntity: {
      waterMeasurement: $waterMeasurment,
      waterUnit: $waterUnit,
      timeStamp: $timeStamp,
    }''';
  }
}