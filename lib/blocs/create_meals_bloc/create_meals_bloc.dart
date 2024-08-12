import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meals_repository/meals_repository.dart';

part 'create_meals_event.dart';
part 'create_meals_state.dart';

class CreateMealsBloc extends Bloc<CreateMealsEvent, CreateMealsState> {
  final MealsRepository _mealsRepository;
  

  CreateMealsBloc({
    required  mealsRepository,
  }) : _mealsRepository = mealsRepository,
  super(CreateMealsInitial()) {
    on<CreateMeals>((event, emit) async{
      emit(CreateMealsLoading());
      try {
      _mealsRepository.setMealsData(event.meals);
        emit(CreateMealsSuccess());
      } catch (e) {
        emit(CreateMealsFailure());
      }
    });
  }
}
