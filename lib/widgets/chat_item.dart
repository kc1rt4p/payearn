import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../data/models/message.dart';
import '../services/authentication.dart';

Widget buildChatItem(BuildContext context, Message message) {
  final authService = RepositoryProvider.of<AuthenticationService>(context);
  final currentUserId = authService.currentUserId;

  return Container(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: message.senderId == currentUserId
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              margin: message.senderId == currentUserId
                  ? EdgeInsets.only(right: 15.0)
                  : EdgeInsets.only(left: 15.0),
              child: Text(
                message.senderId == currentUserId ? 'You' : message.senderName,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
              margin: message.senderId == currentUserId
                  ? EdgeInsets.only(right: 10.0)
                  : EdgeInsets.only(left: 10.0),
              width: 200.0,
              decoration: BoxDecoration(
                color: message.senderId == currentUserId
                    ? Colors.blue[300]
                    : Colors.indigo[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(message.message),
            ),
          ],
          mainAxisAlignment: message.senderId == currentUserId
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
        ),
        Row(
          mainAxisAlignment: message.senderId == currentUserId
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              margin: message.senderId == currentUserId
                  ? EdgeInsets.only(right: 5.0, top: 5.0, bottom: 5.0)
                  : EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0),
              child: Text(
                timeago.format(
                  message.timestamp == null
                      ? DateTime.now()
                      : message.timestamp.toDate(),
                ),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
