part of 'create_hydrate_bloc.dart';

sealed class CreateHydrateState extends Equatable {
  const CreateHydrateState();
  
  @override
  List<Object> get props => [];
}

final class CreateHydrateInitial extends CreateHydrateState {}

final class CreateHydrateFailure extends CreateHydrateState {}
final class CreateHydrateLoading extends CreateHydrateState {}
final class CreateHydrateSuccess extends CreateHydrateState {}