import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/bloc/chat_bloc.dart';
import '../data/models/chat.dart';
import '../data/models/message.dart';
import '../data/models/subscriber.dart';
import '../data/repositories/message_repository.dart';
import '../services/authentication.dart';
import '../widgets/chat_item.dart';
import '../widgets/dropdown_subscriber_list.dart';
import '../widgets/progress.dart';
import '../widgets/styled_text_field.dart';

TextEditingController _messageController = TextEditingController();
bool _sendingMessage = false;
String selectedSubscriberId;
String selectedSubscriberName;

class ChatPage extends StatefulWidget {
  final String subscriberId;

  const ChatPage({this.subscriberId}) : super();

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    selectedSubscriberId = widget.subscriberId;
  }

  @override
  Widget build(BuildContext context) {
    final authService = RepositoryProvider.of<AuthenticationService>(context);
    final messageRepository = MessageRepository();
    return Column(
      children: [
        Expanded(
          child: BlocProvider<ChatBloc>(
            create: authService.currentUserType == 'subscriber'
                ? (context) => ChatBloc(messageRepository)
                  ..add(ChatStart(widget.subscriberId))
                : (context) => ChatBloc(messageRepository)..add(GetChatRooms()),
            child: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatAdding) {
                  setState(() {
                    _sendingMessage = true;
                  });
                }

                if (state is ChatAdded) {
                  setState(() {
                    _sendingMessage = false;
                    _messageController.clear();
                  });
                }
              },
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                    if (state.messageList.isNotEmpty) {
                      return buildChatList(context, state.messageList);
                    } else {
                      return buildEmptyChat(context);
                    }
                  }

                  if (state is ChatRoomsLoaded) {
                    if (state.chatRooms.isNotEmpty) {
                      return buildChatRoomList(context, state.chatRooms);
                    } else {
                      return buildEmptyChatRoom(context);
                    }
                  }

                  return circularProgress();
                },
              ),
            ),
          ),
        ),
        Center(
          child: AppodealBanner(
            placementName: 'ChatPage',
          ),
        ),
      ],
    );
  }
}

handleSelectChatRoom(BuildContext context, String ownerId, String ownerName) {
  selectedSubscriberId = ownerId;
  selectedSubscriberName = ownerName;
  BlocProvider.of<ChatBloc>(context).add(ChatStart(ownerId));
}

handleOnSubscriberSelect(BuildContext context, Subscriber subscriber) {
  selectedSubscriberId = subscriber.id;
  selectedSubscriberName = '${subscriber.firstName} ${subscriber.lastName}';
  BlocProvider.of<ChatBloc>(context).add(ChatStart(selectedSubscriberId));
}

buildChatRoomList(BuildContext context, List<Chat> chatRooms) {
  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: buildSubscriberField(
          onChanged: (subscriber) =>
              handleOnSubscriberSelect(context, subscriber),
        ),
      ),
      Expanded(
        child: ListView(
          children: chatRooms.map((cr) {
            return Card(
              child: ListTile(
                  title: Text(cr.ownerName),
                  tileColor: Colors.blue[100],
                  subtitle: Text(
                      'Last message was sent ${timeago.format(cr.lastUpdate.toDate())}'),
                  onTap: () =>
                      handleSelectChatRoom(context, cr.id, cr.ownerName)),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

buildEmptyChatRoom(BuildContext context) {
  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: buildSubscriberField(
          onChanged: (subscriber) =>
              handleOnSubscriberSelect(context, subscriber),
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble,
              size: 130.0,
              color: Colors.blue[900],
            ),
            Text(
              'EMPTY INBOX',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              'You can select a subscriber to start chatting with them',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ],
  );
}

buildMessageField(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: Row(
      children: [
        Expanded(
          flex: 4,
          child: StyledTextField(
            controller: _messageController,
            hint: 'Enter message here',
          ),
        ),
        SizedBox(width: 5.0),
        _sendingMessage
            ? circularProgress()
            : GestureDetector(
                onTap: () => handleSend(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidPaperPlane,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
      ],
    ),
  );
}

handleSend(BuildContext context) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);

  BlocProvider.of<ChatBloc>(context).add(ChatAdd(_messageController.text.trim(),
      selectedSubscriberId, authService.currentSubscriber));
}

buildEmptyChat(BuildContext context) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: Container(
          color: Colors.blue[100],
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Center(
                child: authService.currentUserType == 'subscriber'
                    ? Text('Chat with admins')
                    : Text(
                        'Chat with $selectedSubscriberName',
                      ),
              ),
              Positioned(
                child: Visibility(
                  visible: authService.currentUserType != 'subscriber',
                  child: IconButton(
                    onPressed: () {
                      BlocProvider.of<ChatBloc>(context).add(GetChatRooms());
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                left: 0,
                bottom: -15,
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble,
              size: 130.0,
              color: Colors.blue[900],
            ),
            Text(
              'NO MESSAGES',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.blue[900],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            // authService.currentUserType == 'subscriber'
            //     ? Text(
            //         'Talk to admins using this Chat feature',
            //         textAlign: TextAlign.center,
            //       )
            //     : Text(
            //         'Talk to subscriber using this Chat feature',
            //         textAlign: TextAlign.center,
            //       ),
          ],
        ),
      ),
      buildMessageField(context),
    ],
  );
}

buildChatList(BuildContext context, List<Message> messages) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);

  return Column(
    children: [
      Material(
        elevation: 10.0,
        child: Container(
          color: Colors.blue[100],
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Center(
                child: authService.currentUserType == 'subscriber'
                    ? Text('Chat with admins')
                    : Text(
                        'Chat with $selectedSubscriberName',
                      ),
              ),
              Positioned(
                child: Visibility(
                  visible: authService.currentUserType != 'subscriber',
                  child: IconButton(
                    onPressed: () {
                      BlocProvider.of<ChatBloc>(context).add(GetChatRooms());
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ),
                left: 0,
                bottom: -15,
              ),
            ],
          ),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            reverse: true,
            children: messages
                .map((message) => buildChatItem(context, message))
                .toList(),
          ),
        ),
      ),
      buildMessageField(context),
    ],
  );
}
