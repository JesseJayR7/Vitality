part of 'create_hydrate_bloc.dart';

sealed class CreateChatEvent extends Equatable {
  const CreateChatEvent();

  @override
  List<Object> get props => [];
}

class CreateChat extends CreateChatEvent {
  final Chats chat;

  const CreateChat({required this.chat,});
}