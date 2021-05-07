import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String senderName;
  final String senderId;
  final Timestamp timestamp;
  final String message;

  Message({
    this.id,
    this.senderId,
    this.senderName,
    this.timestamp,
    this.message,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Message(
      id: doc.id,
      senderId: docData['senderId'],
      senderName: docData['senderName'],
      timestamp: docData['timestamp'],
      message: docData['message'],
    );
  }

  @override
  List<Object> get props => [
        id,
        senderId,
        senderName,
        timestamp,
        message,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
      'message': message,
    };
  }
}
