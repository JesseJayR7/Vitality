class MealsEntity{
  String mealName;
  double caloriesGained;
  DateTime timeStamp;

  MealsEntity(
      {
      required this.mealName,
      required this.caloriesGained,
      required this.timeStamp
    });

  Map<String, Object?> toDocument() {
    return {
      'mealName': mealName,
      'caloriesGained': caloriesGained,
      'timeStamp': timeStamp,
    };
  }

  static MealsEntity fromDocument(Map<String, dynamic> doc) {
    return MealsEntity(
			mealName: doc['mealName'] as String,
      caloriesGained: doc['caloriesGained'] as double,
      timeStamp: doc['timeStamp'] as DateTime,
    );
  }
  
  @override
  List<Object?> get props=> [
    mealName,
    caloriesGained,
    timeStamp,
  ];


  @override
  String toString(){
    return '''MealsEntity: {
      mealName: $mealName,
      caloriesGained: $caloriesGained,
      timeStamp: $timeStamp,
    }''';
  }
}