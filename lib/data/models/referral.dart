import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Referral extends Equatable {
  final String id;
  final Timestamp dateReferred;
  final bool bonusGiven;
  final String referrerId;
  final String referredId;
  final String referralCodeUsed;

  Referral({
    this.id,
    this.dateReferred,
    this.bonusGiven,
    this.referralCodeUsed,
    this.referredId,
    this.referrerId,
  });

  @override
  List<Object> get props => [
        id,
        dateReferred,
        bonusGiven,
        referralCodeUsed,
        referredId,
        referrerId,
      ];

  factory Referral.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return Referral(
      id: docSnapshot.id,
      dateReferred: docData['dateReferred'],
      bonusGiven: docData['bonusGiven'],
      referrerId: docData['ownerId'],
      referredId: docData['referredId'],
      referralCodeUsed: docData['referralCodeUsed'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateReferred': dateReferred,
      'bonusGiven': bonusGiven,
      'referralCodeUsed': referralCodeUsed,
      'referredId': referredId,
      'referrerId': referrerId,
    };
  }
}
