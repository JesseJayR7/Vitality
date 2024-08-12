part of 'create_steps_bloc.dart';

sealed class CreateStepsEvent extends Equatable {
  const CreateStepsEvent();

  @override
  List<Object> get props => [];
}

class CreateSteps extends CreateStepsEvent {
  final Steps steps;

  const CreateSteps({required this.steps,});
}