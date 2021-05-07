import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CashOutRequest extends Equatable {
  final String id;
  final String wallet;
  final num amount;
  final String paymentMethod;
  final String paymentOption;
  final String accountName;
  final String accountNumber;
  final Timestamp dateRequested;
  final String subscriberId;
  final String status; // approved, claimed, rejected
  final String depositPhotoUrl;
  final Timestamp dateApproved;
  final Timestamp dateClaimed;
  final Timestamp dateRejected;

  CashOutRequest({
    this.id,
    this.wallet,
    this.amount,
    this.paymentMethod,
    this.paymentOption,
    this.accountName,
    this.accountNumber,
    this.dateApproved,
    this.dateClaimed,
    this.dateRejected,
    this.dateRequested,
    this.subscriberId,
    this.status,
    this.depositPhotoUrl,
  });

  @override
  List<Object> get props => [
        id,
        wallet,
        amount,
        paymentMethod,
        paymentOption,
        accountName,
        accountNumber,
        dateApproved,
        dateClaimed,
        dateRejected,
        dateRequested,
        subscriberId,
        status,
        depositPhotoUrl,
      ];

  factory CashOutRequest.fromDocument(DocumentSnapshot doc) {
    Map docData = doc.data();
    return CashOutRequest(
      id: doc.id,
      amount: docData['amount'],
      wallet: docData['wallet'],
      paymentMethod: docData['paymentMethod'],
      paymentOption: docData['paymentOption'],
      accountName: docData['accountName'],
      accountNumber: docData['accountNumber'],
      dateRequested: docData['dateRequested'],
      subscriberId: docData['subscriberId'],
      status: docData['status'],
      depositPhotoUrl: docData['depositPhotoUrl'],
      dateApproved: docData['dateApproved'],
      dateClaimed: docData['dateClaimed'],
      dateRejected: docData['dateRejected'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wallet': wallet,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentOption': paymentOption,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'dateApproved': dateApproved,
      'dateClaimed': dateClaimed,
      'dateRejected': dateRejected,
      'dateRequested': dateRequested,
      'subscriberId': subscriberId,
      'status': status,
      'depositPhotoUrl': depositPhotoUrl,
    };
  }
}
