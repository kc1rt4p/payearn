import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Platinum extends Equatable {
  final String id;
  final Timestamp startDate;
  final num capital;
  final String status; // pending, active, complete
  final Timestamp lastDepositDate;
  final Timestamp endDate;

  Platinum({
    this.id,
    this.startDate,
    this.capital,
    this.status,
    this.lastDepositDate,
    this.endDate,
  });

  factory Platinum.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return Platinum(
      id: docSnapshot.id,
      startDate: docData['startDate'],
      capital: docData['capital'],
      status: docData['status'],
      lastDepositDate: docData['lastDepositDate'],
      endDate: docData['endDate'],
    );
  }

  @override
  List<Object> get props => [
        id,
        startDate,
        capital,
        status,
        lastDepositDate,
        endDate,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate,
      'capital': capital,
      'status': status,
      'lastDepositDate': lastDepositDate,
      'endDate': endDate,
    };
  }
}
