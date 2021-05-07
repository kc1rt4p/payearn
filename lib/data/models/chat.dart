import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String ownerName;
  final Timestamp lastUpdate;

  Chat({this.id, this.ownerName, this.lastUpdate});

  @override
  List<Object> get props => [id, ownerName, lastUpdate];

  factory Chat.fromDocument(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Chat(
      id: doc.id,
      ownerName: docData['ownerName'],
      lastUpdate: docData['lastUpdate'],
    );
  }
}
