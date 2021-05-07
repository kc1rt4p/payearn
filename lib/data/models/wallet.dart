import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final Accumulated accumulated;
  final Electronic electronic;
  final Loyalty loyalty;
  final Referral referral;

  Wallet({
    this.id,
    this.accumulated,
    this.electronic,
    this.loyalty,
    this.referral,
  });

  factory Wallet.fromDocument(DocumentSnapshot doc) {
    Map docData = doc.data();
    return Wallet(
      id: doc.id,
      accumulated: Accumulated.fromDocData(docData['accumulated']),
      electronic: Electronic.fromDocData(docData['electronic']),
      loyalty: Loyalty.fromDocData(docData['loyalty']),
      referral: Referral.fromDocData(docData['referral']),
    );
  }

  @override
  List<Object> get props => [
        id,
        accumulated,
        electronic,
        loyalty,
        referral,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accumulated': accumulated,
      'electronic': electronic,
      'loyalty': loyalty,
      'referral': referral,
    };
  }
}

class Accumulated extends Equatable {
  final num amount;
  final Timestamp lastUpdate;

  Accumulated({
    this.amount,
    this.lastUpdate,
  });

  factory Accumulated.fromDocData(Map doc) {
    return Accumulated(
      amount: doc['amount'],
      lastUpdate: doc['lastUpdate'] ?? doc['lastUpdate'],
    );
  }

  @override
  List<Object> get props => [
        amount,
        lastUpdate,
      ];
}

class Electronic extends Equatable {
  final num amount;
  final Timestamp lastUpdate;
  final Timestamp lastRedeem;

  Electronic({
    this.amount,
    this.lastUpdate,
    this.lastRedeem,
  });

  factory Electronic.fromDocData(Map doc) {
    return Electronic(
      amount: doc['amount'],
      lastUpdate: doc['lastUpdate'] ?? doc['lastUpdate'],
      lastRedeem: doc['lastRedeem'] ?? doc['lastRedeem'],
    );
  }

  @override
  List<Object> get props => [
        amount,
        lastUpdate,
        lastRedeem,
      ];
}

class Loyalty extends Equatable {
  final num amount;
  final Timestamp lastUpdate;
  final num rewardCount;
  final Timestamp lastRewardReceived;
  final Timestamp lastRedeem;

  Loyalty({
    this.amount,
    this.lastUpdate,
    this.rewardCount,
    this.lastRewardReceived,
    this.lastRedeem,
  });

  factory Loyalty.fromDocData(Map doc) {
    return Loyalty(
      amount: doc['amount'],
      lastUpdate: doc['lastUpdate'] ?? doc['lastUpdate'],
      rewardCount: doc['rewardCount'] ?? doc['rewardCount'],
      lastRewardReceived:
          doc['lastRewardReceived'] ?? doc['lastRewardReceived'],
      lastRedeem: doc['lastRedeem'] ?? doc['lastRedeem'],
    );
  }

  @override
  List<Object> get props => [
        amount,
        lastUpdate,
        rewardCount,
        lastRewardReceived,
        lastRedeem,
      ];
}

class Referral extends Equatable {
  final num amount;
  final Timestamp lastUpdate;
  final Timestamp lastRedeem;

  Referral({
    this.amount,
    this.lastUpdate,
    this.lastRedeem,
  });

  factory Referral.fromDocData(Map doc) {
    return Referral(
      amount: doc['amount'],
      lastUpdate: doc['lastUpdate'] ?? doc['lastUpdate'],
      lastRedeem: doc['lastRedeem'] ?? doc['lastRedeem'],
    );
  }

  @override
  List<Object> get props => [
        amount,
        lastUpdate,
      ];
}
