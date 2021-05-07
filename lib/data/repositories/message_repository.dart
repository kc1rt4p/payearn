import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';
import '../models/message.dart';
import '../models/subscriber.dart';

final chatsRef = FirebaseFirestore.instance.collection('chats');
final subscribersRef = FirebaseFirestore.instance.collection('subscribers');

abstract class IMessageRepository {
  Future<void> createChat(String chatRoomId);
  Future<void> addMessage(
      String message, String chatRoomId, Subscriber subscriber);
  Stream<List<Message>> getMessages(String subscriberId);
  Stream<List<Chat>> getChatRooms();
}

class MessageRepository extends IMessageRepository {
  @override
  Stream<List<Chat>> getChatRooms() {
    return chatsRef
        .orderBy('lastUpdate', descending: true)
        .snapshots()
        .transform(documentToChatListTransformer);
  }

  @override
  Stream<List<Message>> getMessages(String subscriberId) {
    return chatsRef
        .doc(subscriberId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .transform(documentToMessageListTransformer);
  }

  StreamTransformer documentToChatListTransformer =
      StreamTransformer<QuerySnapshot, List<Chat>>.fromHandlers(
          handleData: (QuerySnapshot snapshot, EventSink<List<Chat>> sink) {
    sink.add(snapshot.docs.map((doc) => Chat.fromDocument(doc)).toList());
  });

  StreamTransformer documentToMessageListTransformer =
      StreamTransformer<QuerySnapshot, List<Message>>.fromHandlers(
          handleData: (QuerySnapshot snapshot, EventSink<List<Message>> sink) {
    sink.add(snapshot.docs.map((doc) => Message.fromDocument(doc)).toList());
  });

  @override
  Future<void> addMessage(
      String message, String chatRoomId, Subscriber subscriber) async {
    try {
      final chatDoc = await chatsRef.doc(chatRoomId).get();
      if (!chatDoc.exists) {
        await createChat(chatRoomId);
      }
      await chatsRef.doc(chatRoomId).update({
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      await chatsRef.doc(chatRoomId).collection('messages').add({
        'message': message,
        'senderName': '${subscriber.firstName} ${subscriber.lastName}',
        'timestamp': FieldValue.serverTimestamp(),
        'senderId': subscriber.id,
      });
    } catch (e) {
      print('adding message error: ${e.toString()}');
    }
  }

  @override
  Future<void> createChat(String chatRoomId) async {
    try {
      final subscriberDoc = await subscribersRef.doc(chatRoomId).get();
      final subscriber = Subscriber.fromDocument(subscriberDoc);

      await chatsRef.doc(subscriber.id).set({
        'ownerName': '${subscriber.firstName} ${subscriber.lastName}',
        'lastUpdate': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('error creating chat: ${e.toString()}');
      return false;
    }
  }
}
