part of 'create_hydrate_bloc.dart';

sealed class CreateHydrateEvent extends Equatable {
  const CreateHydrateEvent();

  @override
  List<Object> get props => [];
}

class CreateHydrate extends CreateHydrateEvent {
  final Hydrate hydrate;

  const CreateHydrate({required this.hydrate,});
}