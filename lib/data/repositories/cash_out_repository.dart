import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cash_out.dart';
import '../models/subscriber.dart';

final cashOutsRef = FirebaseFirestore.instance.collection('cashOuts');
final subscribersRef = FirebaseFirestore.instance.collection('subscribers');
final walletsRef = FirebaseFirestore.instance.collection('wallets');

abstract class ICashOutRepository {
  Future<CashOut> get(String id);
  Future<List<CashOut>> getAll();
  Future<void> create(String subscriberId, Map cashOutData);
  Future<bool> update(String id, Map<String, dynamic> cashOutData);
  Future<bool> delete(String id);
}

class CashOutRepository extends ICashOutRepository {
  @override
  Future<void> create(String subscriberId, Map cashOutData) async {
    try {
      final cashOutDoc = await cashOutsRef.doc(subscriberId).get();

      if (!cashOutDoc.exists) {
        final subscriberDoc = await subscribersRef.doc(subscriberId).get();
        final subscriber = Subscriber.fromDocument(subscriberDoc);

        await cashOutsRef.doc(subscriberId).set({
          'requestor': '${subscriber.firstName} ${subscriber.lastName}',
          'lastRequestDate': FieldValue.serverTimestamp(),
        });
      }

      await cashOutsRef.doc(subscriberId).update({
        'lastRequestDate': FieldValue.serverTimestamp(),
      });

      await cashOutsRef
          .doc(subscriberId)
          .collection('requests')
          .add(cashOutData);

      await walletsRef.doc(subscriberId).update({
        '${cashOutData['wallet']}.amount':
            FieldValue.increment(-cashOutData['amount']),
        '${cashOutData['wallet']}.lastUpdate': FieldValue.serverTimestamp(),
        '${cashOutData['wallet']}.lastRedeem': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('creating cash out request error: ${e.toString()}');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await cashOutsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CashOut> get(String id) async {
    try {
      final doc = await cashOutsRef.doc(id).get();
      if (!doc.exists) return null;
      return CashOut.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CashOut>> getAll() async {
    try {
      final querySnapshot = await cashOutsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => CashOut.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> cashOutData) async {
    try {
      await cashOutsRef.doc(id).update(cashOutData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
