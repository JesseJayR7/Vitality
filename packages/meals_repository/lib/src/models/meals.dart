import 'package:meals_repository/meals_repository.dart';

class Meals{
  String mealName;
  double caloriesGained;
  DateTime timeStamp;
  
  Meals({
    required this.mealName,
    required this.caloriesGained,
    required this.timeStamp
  });

  //empty user which represents an authenticated user.

  static final empty = Meals(
    mealName: '',
    caloriesGained: 0.0,
    timeStamp: DateTime.now(),
  );

  // modify Post parameters
  Meals copyWith({
    String? mealName,
    double? caloriesGained,
    DateTime? timeStamp,
  }){
    return Meals(
      mealName: mealName ?? this.mealName, 
      caloriesGained: caloriesGained ?? this.caloriesGained, 
      timeStamp: timeStamp?? this.timeStamp,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == Meals.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != Meals.empty;

  MealsEntity toEntity(){
    return MealsEntity(
      mealName: mealName, 
      caloriesGained: caloriesGained,
      timeStamp: timeStamp,
    );
  }

  static Meals fromEntity(MealsEntity entity){
    return Meals(
      mealName: entity.mealName, 
      caloriesGained: entity.caloriesGained,
      timeStamp: entity.timeStamp,
    );
  }

  String toString(){
    return '''Meals: {
      mealName: $mealName, 
      caloriesGained: $caloriesGained,
      timeStamp: $timeStamp,
    }''';
  }
}