import 'package:chat_repository/chat_repository.dart';

abstract class ChatRepository{

  Future<void> setChatData(Chats user);
}