import 'package:chat_repository/chat_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'create_hydrate_event.dart';
part 'create_hydrate_state.dart';

class CreateChatBloc extends Bloc<CreateChatEvent, CreateChatState> {
  final ChatRepository _chatRepository;

  CreateChatBloc({
    required ChatRepository chatRepository,
  }) : _chatRepository = chatRepository,
  super(CreateChatInitial()) {
    on<CreateChat>((event, emit) async{
      emit(CreateChatLoading());
      try {
      _chatRepository.setChatData(event.chat);
        emit(CreateChatSuccess());
      } catch (e) {
        emit(CreateChatFailure());
      }
    });
  }
}
