import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class ChatsEntity extends Equatable {
  final Map<String, dynamic> messageData;

  const ChatsEntity({
    required this.messageData,
  });

  Map<String, Object?> toDocument() {
    return {
      'messageData': messageData,
    };
  }

  @override
  List<Object?> get props => [
        messageData,
      ];

  @override
  String toString() {
    return '''ChatsEntity: {
      messageData: $messageData
    }''';
  }
}
