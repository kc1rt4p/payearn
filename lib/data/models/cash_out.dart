import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CashOut extends Equatable {
  final String id;
  final String requestor;
  final Timestamp lastRequestDate;

  CashOut({
    this.id,
    this.requestor,
    this.lastRequestDate,
  });

  @override
  List<Object> get props => [
        id,
        requestor,
        lastRequestDate,
      ];

  factory CashOut.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return CashOut(
      id: docSnapshot.id,
      requestor: docData['requestor'],
      lastRequestDate: docData['lastRequestDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subscriberName': requestor,
      'lastRequestDate': lastRequestDate,
    };
  }
}
