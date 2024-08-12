import 'package:chat_repository/chat_repository.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class Chats extends Equatable {
  final Map<String, dynamic> messageData;

  const Chats({
    required this.messageData,
  });

  //empty user which represents an authenticated user.
  static const empty = Chats(
    messageData: {},
  );

  // modify MyUser parameters
  Chats copyWith({
    Map<String, dynamic>? messageData,
  }) {
    return Chats(
      messageData: messageData ?? this.messageData,
    );
  }

  /// Convenience getter to determine if the current user is empty
  bool get isEmpty => this == Chats.empty;

  /// Convenience getter to determine if the current user is not empty
  bool get isNotEmpty => this != Chats.empty;

  ChatsEntity toEntity() {
    return ChatsEntity(
      messageData: messageData,
    );
  }

  static Chats fromEntity(ChatsEntity entity) {
    return Chats(
      messageData: entity.messageData,
    );
  }

  @override
  List<Object?> get props => [
        messageData,
      ];
}
