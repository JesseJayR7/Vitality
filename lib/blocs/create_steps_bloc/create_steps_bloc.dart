import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:steps_repository/steps_repository.dart';

part 'create_steps_event.dart';
part 'create_steps_state.dart';

class CreateStepsBloc extends Bloc<CreateStepsEvent, CreateStepsState> {
  final StepsRepository _stepsRepository;

  CreateStepsBloc({
    required StepsRepository stepsRepository,
  }) : _stepsRepository = stepsRepository,
  super(CreateStepsInitial()) {
    on<CreateSteps>((event, emit) async{
      emit(CreateStepsLoading());
      try {
      _stepsRepository.setStepsData(event.steps);
        emit(CreateStepsSuccess());
      } catch (e) {
        emit(CreateStepsFailure());
      }
    });
  }
}
