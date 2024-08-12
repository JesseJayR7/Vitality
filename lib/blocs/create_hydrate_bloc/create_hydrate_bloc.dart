import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrate_repository/hydrate_repository.dart';
import 'package:hydrate_repository/src/hydrate_repo.dart';

part 'create_hydrate_event.dart';
part 'create_hydrate_state.dart';

class CreateHydrateBloc extends Bloc<CreateHydrateEvent, CreateHydrateState> {
  final HydrateRepository _hydrateRepository;

  CreateHydrateBloc({
    required HydrateRepository hydrateRepository,
  }) : _hydrateRepository = hydrateRepository,
  super(CreateHydrateInitial()) {
    on<CreateHydrate>((event, emit) async{
      emit(CreateHydrateLoading());
      try {
      _hydrateRepository.setHydrateData(event.hydrate);
        emit(CreateHydrateSuccess());
      } catch (e) {
        emit(CreateHydrateFailure());
      }
    });
  }
}
