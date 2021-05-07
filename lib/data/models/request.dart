import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Request extends Equatable {
  final String id;
  final num amount;
  final String wallet;
  final String type;
  final String paymentMethod;
  final String paymentOption;
  final String accountName;
  final String accountNumber;
  final Timestamp dateRequested;
  final String subscriberId;
  final String status;
  final String depositPhotoUrl;
  final Timestamp dateApproved;
  final Timestamp dateClaimed;
  final Timestamp dateRejected;

  Request({
    this.id,
    this.amount,
    this.wallet,
    this.type,
    this.paymentMethod,
    this.paymentOption,
    this.accountName,
    this.accountNumber,
    this.dateRequested,
    this.subscriberId,
    this.status,
    this.depositPhotoUrl,
    this.dateApproved,
    this.dateClaimed,
    this.dateRejected,
  });

  factory Request.fromDocument(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Request(
      id: doc.id,
      amount: docData['amount'],
      wallet: docData['wallet'],
      type: docData['type'],
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

  @override
  List<Object> get props => [
        id,
        amount,
        wallet,
        type,
        paymentMethod,
        paymentOption,
        accountName,
        accountNumber,
        dateRequested,
        subscriberId,
        status,
        depositPhotoUrl,
        dateApproved,
        dateClaimed,
        dateRejected,
      ];
}
