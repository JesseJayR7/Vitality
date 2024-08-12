part of 'create_meals_bloc.dart';

sealed class CreateMealsState extends Equatable {
  const CreateMealsState();
  
  @override
  List<Object> get props => [];
}

final class CreateMealsInitial extends CreateMealsState {}

final class CreateMealsFailure extends CreateMealsState {}
final class CreateMealsLoading extends CreateMealsState {}
final class CreateMealsSuccess extends CreateMealsState {}