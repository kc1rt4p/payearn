import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/image_upload.dart';
import '../models/platinum.dart';
import '../models/platinum_deposit.dart';

final platinumsRef = FirebaseFirestore.instance.collection('platinums');
final subscribersRef = FirebaseFirestore.instance.collection('subscribers');

abstract class IPlatinumDepositRepository {
  Future<PlatinumDeposit> get(String id);
  Stream<List<PlatinumDeposit>> getSubscriberPlatinumDeposits(
      String subscriberId);
  Future<void> create(
      String subscriberId, Map platinumDeposit, File depositPhoto);
  Future<bool> update(String id, Map<String, dynamic> platinumDepositData);
  Future<bool> delete(String subscriberId, PlatinumDeposit deposit);
  Future<void> verify(String subscriberId, PlatinumDeposit deposit);
}

class PlatinumDepositRepository extends IPlatinumDepositRepository {
  @override
  Future<void> create(
      String subscriberId, Map platinumDepositData, File depositPhoto) async {
    try {
      final platinumDoc = await platinumsRef.doc(subscriberId).get();

      if (!platinumDoc.exists) {
        await platinumsRef.doc(subscriberId).set({
          'startDate': null,
          'capital': 0,
          'status': 'pending',
          'lastDepositDate': FieldValue.serverTimestamp(),
          'endDate': null,
        });
      } else {
        await platinumsRef.doc(subscriberId).update({
          'lastDepositDate': FieldValue.serverTimestamp(),
        });
      }

      final newDepositPhotoUrl =
          await uploadImage(depositPhoto, 'deposit', subscriberId);

      platinumDepositData['depositPhotoUrl'] = newDepositPhotoUrl;
      platinumDepositData['depositDate'] = FieldValue.serverTimestamp();

      await platinumsRef
          .doc(subscriberId)
          .collection('deposits')
          .add(platinumDepositData);
    } catch (e) {
      print('error adding platinum deposit: ${e.toString()}');
    }
  }

  @override
  Future<bool> delete(
      String subscriberId, PlatinumDeposit platinumDeposit) async {
    try {
      if (platinumDeposit.isVerified) return false;

      await FirebaseStorage.instance
          .refFromURL(platinumDeposit.depositPhotoUrl)
          .delete();

      await platinumsRef
          .doc(subscriberId)
          .collection('deposits')
          .doc(platinumDeposit.id)
          .delete();

      final depositListDoc =
          await platinumsRef.doc(subscriberId).collection('deposits').get();

      if (depositListDoc.docs.isEmpty) {
        await platinumsRef.doc(subscriberId).delete();
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<PlatinumDeposit> get(String id) async {
    try {
      final doc = await platinumsRef.doc(id).get();
      if (!doc.exists) return null;
      return PlatinumDeposit.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<List<PlatinumDeposit>> getSubscriberPlatinumDeposits(
      String subscriberId) {
    return platinumsRef
        .doc(subscriberId)
        .collection('deposits')
        .snapshots()
        .transform(documentToPlatinumDepositListTransformer);
  }

  StreamTransformer documentToPlatinumDepositListTransformer =
      StreamTransformer<QuerySnapshot, List<PlatinumDeposit>>.fromHandlers(
          handleData:
              (QuerySnapshot snapshot, EventSink<List<PlatinumDeposit>> sink) {
    sink.add(
        snapshot.docs.map((doc) => PlatinumDeposit.fromDocument(doc)).toList());
  });

  @override
  Future<bool> update(
      String id, Map<String, dynamic> platinumDepositData) async {
    try {
      await platinumsRef.doc(id).update(platinumDepositData);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> verify(String subscriberId, PlatinumDeposit deposit) async {
    final platinumDoc = await platinumsRef.doc(subscriberId).get();

    try {
      if (platinumDoc.exists) {
        final platinum = Platinum.fromDocument(platinumDoc);

        await platinumsRef.doc(subscriberId).update({
          'status': 'active',
          'startDate': platinum.startDate != null
              ? platinum.startDate
              : FieldValue.serverTimestamp(),
          'capital': FieldValue.increment(deposit.amount),
        });
      }

      await platinumsRef
          .doc(subscriberId)
          .collection('deposits')
          .doc(deposit.id)
          .update({
        'isVerified': true,
        'dateVerified': FieldValue.serverTimestamp(),
      });

      await subscribersRef.doc(subscriberId).update({
        'hasPlatinum': true,
      });
    } catch (e) {
      print('error verifying platinum deposit: ${e.toString()}');
    }
  }
}
