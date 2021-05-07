import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/chat.dart';
import '../models/message.dart';
import '../models/subscriber.dart';
import '../repositories/message_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessageRepository messageRepository;

  ChatBloc(this.messageRepository) : super(ChatInitial());

  StreamSubscription chatList;
  StreamSubscription chatRoomList;

  @override
  Stream<ChatState> mapEventToState(
    ChatEvent event,
  ) async* {
    if (event is GetChatRooms) {
      yield ChatGettingChatRooms();

      chatRoomList?.cancel();

      chatRoomList = messageRepository.getChatRooms().listen((list) {
        add(ChatRoomLoad(list));
      });
    }

    if (event is ChatStart) {
      yield ChatStarting();

      chatList?.cancel();

      chatList =
          messageRepository.getMessages(event.subscriberId).listen((list) {
        add(ChatLoad(list));
      });
    }

    if (event is ChatAdd) {
      try {
        await messageRepository.addMessage(
            event.message, event.chatRoomId, event.subscriber);
        yield ChatAdded();
      } catch (e) {
        yield ChatError('Error adding message');
      }
    }

    if (event is ChatLoad) {
      yield ChatLoaded(event.messages);
    }

    if (event is ChatRoomLoad) {
      yield (ChatRoomsLoaded(event.chats));
    }
  }

  @override
  Future<void> close() {
    chatRoomList?.cancel();
    chatList?.cancel();
    return super.close();
  }
}
