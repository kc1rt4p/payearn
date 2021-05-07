import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Quote extends Equatable {
  final String id;
  final String quote;
  final String author;
  final Timestamp dateAdded;

  Quote({
    this.id,
    this.quote,
    this.author,
    this.dateAdded,
  });

  factory Quote.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return Quote(
      id: docSnapshot.id,
      quote: docData['quote'],
      author: docData['author'],
      dateAdded: docData['dateAdded'],
    );
  }

  @override
  List<Object> get props => [
        id,
        quote,
        author,
        dateAdded,
      ];
}
