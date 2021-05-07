part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatStart extends ChatEvent {
  final String subscriberId;

  const ChatStart(this.subscriberId);
}

class GetChatRooms extends ChatEvent {}

class ChatLoad extends ChatEvent {
  final List<Message> messages;

  const ChatLoad(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatRoomLoad extends ChatEvent {
  final List<Chat> chats;

  const ChatRoomLoad(this.chats);

  @override
  List<Object> get props => [chats];
}

class ChatAdd extends ChatEvent {
  final String message;
  final String chatRoomId;
  final Subscriber subscriber;

  const ChatAdd(this.message, this.chatRoomId, this.subscriber);

  @override
  List<Object> get props => [
        message,
        chatRoomId,
        subscriber,
      ];
}
