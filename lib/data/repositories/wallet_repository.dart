import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:ntp/ntp.dart';

import '../models/platinum.dart';
import '../models/wallet.dart';

final walletsRef = FirebaseFirestore.instance.collection('wallets');
final platinumsRef = FirebaseFirestore.instance.collection('platinums');
final subscribersRef = FirebaseFirestore.instance.collection('subscribers');
final cashOutsRef = FirebaseFirestore.instance.collection('cashOuts');

abstract class IWalletRepository {
  Future<Wallet> get(String id);
  Future<List<Wallet>> getAll();
  Future<Wallet> create(Wallet wallet);
  Future<bool> update(String id, Map<String, dynamic> walletData);
  Future<bool> delete(String id);
  Future<void> checkDailyEarnings(String subscriberId);
  Stream<Wallet> streamWallet(String id);
}

class WalletRepository extends IWalletRepository {
  @override
  Future<Wallet> create(Wallet wallet) async {
    try {
      final docRef = await walletsRef.add(wallet.toMap());
      final docSnapshot = await docRef.get();
      return Wallet.fromDocument(docSnapshot);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await walletsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Wallet> get(String id) async {
    try {
      final doc = await walletsRef.doc(id).get();
      if (!doc.exists) return null;
      return Wallet.fromDocument(doc);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<List<Wallet>> getAll() async {
    try {
      final querySnapshot = await walletsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs.map((doc) => Wallet.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> walletData) async {
    try {
      await walletsRef.doc(id).update(walletData);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> checkDailyEarnings(String subscriberId) async {
    final DateTime currentDate = await NTP.now();

    final platinumDoc = await platinumsRef.doc(subscriberId).get();

    if (!platinumDoc.exists) return;

    final platinum = Platinum.fromDocument(platinumDoc);

    if (platinum.status != 'active') return;

    final walletDoc = await walletsRef.doc(subscriberId).get();

    if (!walletDoc.exists) return;

    final wallet = Wallet.fromDocument(walletDoc);

    final DateTime platinumStartDate = platinum.startDate.toDate();
    final daysSinceComplanStarted =
        currentDate.difference(platinumStartDate).inDays;

    final num monthlyInterest = platinum.capital * 0.12;
    final num dailyInterest = monthlyInterest / 30;

    final ewallet = wallet.electronic;

    final DateTime platinumExpiryDate = Jiffy([
      platinumStartDate.year,
      platinumStartDate.month,
      platinumStartDate.day
    ]).add(years: 3);

    if (platinumExpiryDate.difference(currentDate).inDays < 1) return;

    if (ewallet.lastRedeem == null) {
      try {
        await walletsRef.doc(subscriberId).update({
          'electronic.amount': daysSinceComplanStarted * dailyInterest,
          'electronic.lastUpdate': FieldValue.serverTimestamp(),
        });
        return;
      } catch (e) {
        print('error on updating platinum earning: ${e.toString()}');
      }
    } else {
      final eWallet = wallet.electronic;
      final eWalletLastRedeem = eWallet.lastRedeem.toDate();
      final daysSinceLastRedeem =
          currentDate.difference(eWalletLastRedeem).inDays;
      if (daysSinceLastRedeem > 0) {
        try {
          await walletsRef.doc(subscriberId).update({
            'electronic.amount': daysSinceLastRedeem * dailyInterest,
            'electronic.lastUpdate': FieldValue.serverTimestamp(),
          });
          return;
        } catch (e) {
          print('error on updating platinum earning: ${e.toString()}');
        }
      }
    }

    return;
  }

  @override
  Stream<Wallet> streamWallet(String id) {
    return walletsRef
        .doc(id)
        .snapshots()
        .transform(documentToWalletTransformer);
  }

  StreamTransformer documentToWalletTransformer =
      StreamTransformer<DocumentSnapshot, Wallet>.fromHandlers(
          handleData: (DocumentSnapshot snapshot, EventSink<Wallet> sink) {
    sink.add(snapshot.exists ? Wallet.fromDocument(snapshot) : null);
  });
}
