
import 'package:hydrate_repository/hydrate_repository.dart';

class Hydrate{
  double waterMeasurment;
  String waterUnit;
  DateTime timeStamp;
  
  Hydrate({
    required this.waterMeasurment,
    required this.waterUnit,
    required this.timeStamp
  });

  //empty user which represents an authenticated user.

  static final empty = Hydrate(
    waterUnit: '',
    waterMeasurment: 0.0,
    timeStamp: DateTime.now(),
  );

  // modify Post parameters
  Hydrate copyWith({
    String? waterUnit,
    double? waterMeasurment,
    DateTime? timeStamp,
  }){
    return Hydrate(
      waterMeasurment: waterMeasurment ?? this.waterMeasurment, 
      waterUnit: waterUnit ?? this.waterUnit, 
      timeStamp: timeStamp?? this.timeStamp,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == Hydrate.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != Hydrate.empty;

  HydrateEntity toEntity(){
    return HydrateEntity(
      waterUnit: waterUnit, 
      waterMeasurment: waterMeasurment,
      timeStamp: timeStamp,
    );
  }

  static Hydrate fromEntity(HydrateEntity entity){
    return Hydrate(
      waterUnit: entity.waterUnit, 
      waterMeasurment: entity.waterMeasurment,
      timeStamp: entity.timeStamp,
    );
  }

  String toString(){
    return '''Hydrate: {
      waterUnit: $waterUnit, 
      waterMeasurement: $waterMeasurment,
      timeStamp: $timeStamp,
    }''';
  }
}