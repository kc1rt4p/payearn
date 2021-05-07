part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final List<Message> messageList;

  ChatLoaded(this.messageList);

  @override
  List<Object> get props => [messageList];
}

class ChatStarting extends ChatState {}

class ChatGettingChatRooms extends ChatState {}

class ChatRoomsLoaded extends ChatState {
  final List<Chat> chatRooms;

  const ChatRoomsLoaded(this.chatRooms);

  @override
  List<Object> get props => [chatRooms];
}

class ChatAdding extends ChatState {}

class ChatAdded extends ChatState {}

class ChatError extends ChatState {
  final String error;

  const ChatError(this.error);

  @override
  List<Object> get props => [error];
}
