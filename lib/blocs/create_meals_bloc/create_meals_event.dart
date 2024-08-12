part of 'create_meals_bloc.dart';

sealed class CreateMealsEvent extends Equatable {
  const CreateMealsEvent();

  @override
  List<Object> get props => [];
}

class CreateMeals extends CreateMealsEvent {
  final Meals meals;

  const CreateMeals({required this.meals,});
}