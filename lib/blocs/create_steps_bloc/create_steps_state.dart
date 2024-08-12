part of 'create_steps_bloc.dart';

sealed class CreateStepsState extends Equatable {
  const CreateStepsState();
  
  @override
  List<Object> get props => [];
}

final class CreateStepsInitial extends CreateStepsState {}

final class CreateStepsFailure extends CreateStepsState {}
final class CreateStepsLoading extends CreateStepsState {}
final class CreateStepsSuccess extends CreateStepsState {}