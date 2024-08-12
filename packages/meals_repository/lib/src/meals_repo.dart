import 'package:meals_repository/meals_repository.dart';

abstract class MealsRepository{

  Future<void> setMealsData(Meals meals);
}