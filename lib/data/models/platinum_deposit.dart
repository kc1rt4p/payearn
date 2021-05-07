import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PlatinumDeposit extends Equatable {
  final String id;
  final num amount;
  final Timestamp depositDate;
  final String depositPhotoUrl;
  final bool isVerified;
  final String paymentMethod;
  final String paymentOption;
  final Timestamp dateVerified;

  PlatinumDeposit({
    this.id,
    this.amount,
    this.depositDate,
    this.depositPhotoUrl,
    this.isVerified,
    this.paymentMethod,
    this.paymentOption,
    this.dateVerified,
  });

  factory PlatinumDeposit.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return PlatinumDeposit(
      id: docSnapshot.id,
      amount: docData['amount'],
      depositDate: docData['depositDate'],
      depositPhotoUrl: docData['depositPhotoUrl'],
      isVerified: docData['isVerified'],
      paymentMethod: docData['paymentMethod'],
      paymentOption: docData['paymentOption'],
    );
  }

  @override
  List<Object> get props => [
        id,
        amount,
        depositDate,
        depositPhotoUrl,
        isVerified,
        paymentMethod,
        paymentOption,
        dateVerified,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'depositDate': depositDate,
      'depositPhotoUrl': depositPhotoUrl,
      'isVerified': isVerified,
      'paymentMethod': paymentMethod,
      'paymentOption': paymentOption,
      'dateVerified': dateVerified,
    };
  }
}
