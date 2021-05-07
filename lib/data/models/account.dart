import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String username;
  final String password;
  final String type;
  final String referralCode;
  final String referrerId;
  final Timestamp dateCreated;

  Account({
    this.id,
    this.username,
    this.password,
    this.type,
    this.referralCode,
    this.referrerId,
    this.dateCreated,
  });

  @override
  List<Object> get props => [
        id,
        username,
        password,
        type,
        referralCode,
        referrerId,
      ];

  factory Account.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return Account(
      id: docSnapshot.id,
      username: docData['username'],
      password: docData['password'],
      type: docData['type'],
      referralCode: docData['referralCode'],
      referrerId: docData['referrerId'],
      dateCreated: docData['dateCreated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'type': type,
      'referralCode': referralCode,
      'referrerId': referrerId,
      'dateCreated': FieldValue.serverTimestamp(),
    };
  }
}
