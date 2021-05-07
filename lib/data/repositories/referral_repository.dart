import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/referral.dart';
import 'subscriber_repository.dart';

final accountsRef = FirebaseFirestore.instance.collection('accounts');
SubscriberRepository subscriberRepository = SubscriberRepository();

abstract class IReferralRepository {
  Future<List<Map>> getAll(String subscriberId);
  Future<Referral> get(String referrerId, String subscriberId);
}

class ReferralRepository extends IReferralRepository {
  @override
  Future<List<Map>> getAll(String subscriberId) async {
    try {
      final querySnapshot =
          await accountsRef.doc(subscriberId).collection('referrals').get();
      if (querySnapshot.docs.isEmpty) return [];

      List<Map> referrals = [];

      for (var querySnapshotDoc in querySnapshot.docs) {
        final referral = Referral.fromDocument(querySnapshotDoc);
        final referredSubscriber =
            await subscriberRepository.get(referral.referredId);
        final referralInfo = {
          'referral': referral,
          'referredSubscriber': referredSubscriber,
        };

        referrals.add(referralInfo);
      }

      return referrals;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Referral> get(String referrerId, String subscriberId) async {
    try {
      final referralDoc = await accountsRef
          .doc(referrerId)
          .collection('referrals')
          .doc(subscriberId)
          .get();
      if (!referralDoc.exists) return null;
      return Referral.fromDocument(referralDoc);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
