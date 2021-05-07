import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';

import '../../services/image_upload.dart';
import '../models/account.dart';
import '../models/platinum_deposit.dart';
import '../models/subscriber.dart';

final subscribersRef = FirebaseFirestore.instance.collection('subscribers');
final platinumsRef = FirebaseFirestore.instance.collection('platinums');
final accountsRef = FirebaseFirestore.instance.collection('accounts');
final walletsRef = FirebaseFirestore.instance.collection('wallets');

abstract class ISubscriberRepository {
  Future<Subscriber> get(String id);
  Future<List<Subscriber>> getAll();
  Future<Subscriber> create(
      String id, Map subscriber, File idPhoto, File profilePhoto);
  Future<bool> update(String id, Map<String, dynamic> subscriberData);
  Future<bool> delete(String id);
  Future<List<Subscriber>> searchSubscribers(String filter);
  Stream<List<Subscriber>> getSubscribers();
  Future<void> verifySubscriber(String subscriberId);
}

class SubscriberRepository extends ISubscriberRepository {
  @override
  Stream<List<Subscriber>> getSubscribers() {
    return subscribersRef
        .snapshots()
        .transform(documentToSubscribertListTransformer);
  }

  StreamTransformer documentToSubscribertListTransformer =
      StreamTransformer<QuerySnapshot, List<Subscriber>>.fromHandlers(
          handleData:
              (QuerySnapshot snapshot, EventSink<List<Subscriber>> sink) {
    sink.add(snapshot.docs.map((doc) => Subscriber.fromDocument(doc)).toList());
  });

  @override
  Future<Subscriber> create(
      String id, Map subscriber, File idPhoto, File profilePhoto) async {
    try {
      subscriber['idUrl'] =
          idPhoto == null ? null : await uploadImage(idPhoto, 'id', id);
      subscriber['photoUrl'] = profilePhoto == null
          ? null
          : await uploadImage(profilePhoto, 'profile', id);

      subscriber['hasPlatinum'] = false;
      subscriber['isVerified'] = false;
      subscriber['dateVerified'] = null;

      await subscribersRef.doc(id).set(subscriber);
      final docSnapshot = await subscribersRef.doc(id).get();
      return Subscriber.fromDocument(docSnapshot);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final subscriberDoc = await subscribersRef.doc(id).get();
      if (!subscriberDoc.exists) return false;

      final subscriber = Subscriber.fromDocument(subscriberDoc);

      final accountDoc = await accountsRef.doc(subscriber.id).get();

      final account = Account.fromDocument(accountDoc);

      if (subscriber.hasPlatinum) {
        final depositsSnapshot =
            await platinumsRef.doc(subscriber.id).collection('deposits').get();
        if (depositsSnapshot.docs.isNotEmpty) {
          for (var depositDoc in depositsSnapshot.docs) {
            final deposit = PlatinumDeposit.fromDocument(depositDoc);
            await FirebaseStorage.instance
                .refFromURL(deposit.depositPhotoUrl)
                .delete();
            await platinumsRef
                .doc(subscriber.id)
                .collection('deposits')
                .doc(deposit.id)
                .delete();
          }
        }

        await platinumsRef.doc(subscriber.id).delete();
      }

      if (subscriber.isVerified) {
        await accountsRef
            .doc(account.referrerId)
            .collection('referrals')
            .doc(account.id)
            .delete();

        await walletsRef.doc(account.referrerId).update({
          'referral.amount': FieldValue.increment(-200),
        });

        await walletsRef.doc(account.id).delete();
      }

      // if (subscriber.idUrl != null) {
      //   print('trying to delete: ${subscriber.idUrl}');
      //   await FirebaseStorage.instance.refFromURL(subscriber.idUrl).delete();
      // }

      // if (subscriber.photoUrl != null) {
      //   print('trying to delete: ${subscriber.photoUrl}');
      //   await FirebaseStorage.instance.refFromURL(subscriber.photoUrl).delete();
      // }

      await subscribersRef.doc(id).delete();
      await accountsRef.doc(id).delete();

      return true;
    } catch (e) {
      print('error deleting subscriber: ${e.toString()}');
      return false;
    }
  }

  Future<List<Subscriber>> searchSubscribers(String filter) async {
    try {
      final querySnapshots = await subscribersRef.get();
      if (querySnapshots.docs.isEmpty) {
        return [];
      }

      final subscriberList = querySnapshots.docs
          .map((doc) => Subscriber.fromDocument(doc))
          .toList();

      if (filter.isEmpty) {
        return subscriberList;
      } else {
        subscriberList.removeWhere((subscriber) =>
            (subscriber.firstName + subscriber.lastName)
                .toLowerCase()
                .contains(filter.toLowerCase()));
        return subscriberList;
      }
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Subscriber> get(String id) async {
    try {
      final doc = await subscribersRef.doc(id).get();
      if (!doc.exists) return null;
      return Subscriber.fromDocument(doc);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<List<Subscriber>> getAll() async {
    try {
      final querySnapshot = await subscribersRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => Subscriber.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> subscriberData) async {
    try {
      await subscribersRef.doc(id).update(subscriberData);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> verifySubscriber(String subscriberId) async {
    String referralCode;

    while (referralCode == null) {
      String generatedCode = randomAlphaNumeric(8);
      QuerySnapshot doc = await accountsRef
          .where('referralCode', isEqualTo: generatedCode)
          .get();
      if (doc.docs.isEmpty) {
        referralCode = generatedCode;
      }
    }

    final accountDoc = await accountsRef.doc(subscriberId).get();
    final account = Account.fromDocument(accountDoc);

    await subscribersRef.doc(subscriberId).update({
      'isVerified': true,
      'dateVerified': FieldValue.serverTimestamp(),
    });

    await accountsRef.doc(subscriberId).update({
      'referralCode': referralCode,
    });

    await accountsRef
        .doc(account.referrerId)
        .collection('referrals')
        .doc(subscriberId)
        .update({
      'bonusGiven': true,
    });

    await walletsRef.doc(account.referrerId).update({
      'referral.amount': FieldValue.increment(1),
    });

    await walletsRef.doc(subscriberId).set({
      'accumulated': {
        'amount': 0,
        'lastUpdate': FieldValue.serverTimestamp(),
      },
      'electronic': {
        'amount': 0,
        'lastUpdate': FieldValue.serverTimestamp(),
      },
      'loyalty': {
        'amount': 0,
        'lastUpdate': FieldValue.serverTimestamp(),
      },
      'referral': {
        'amount': 0,
        'lastUpdate': FieldValue.serverTimestamp(),
      },
    });
  }
}
