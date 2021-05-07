import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/account.dart';

final accountsRef = FirebaseFirestore.instance.collection('accounts');

abstract class IAccountRepository {
  Future<Account> get(String id);
  Future<List<Account>> getAll();
  Future<Account> create(Map account, String referralCode);
  Future<bool> update(String id, Map<String, dynamic> accountData);
  Future<bool> delete(String id);
  Future<String> verifyReferralCode(String code);
  Future<bool> login(String username, String password);
  Future<void> changePassword(String id, String newPassword);
}

class AccountRepository extends IAccountRepository {
  @override
  Future<Account> create(Map account, String referralCode) async {
    try {
      account['dateCreated'] = FieldValue.serverTimestamp();
      await accountsRef.doc(account['username']).set(account);

      final referrerAccDoc = await accountsRef
          .where('referralCode', isEqualTo: referralCode)
          .limit(1)
          .get();

      final referrerAcc = Account.fromDocument(referrerAccDoc.docs[0]);

      await accountsRef
          .doc(referrerAcc.id)
          .collection('referrals')
          .doc(account['username'])
          .set({
        'dateReferred': FieldValue.serverTimestamp(),
        'bonusGiven': false,
        'referrerId': referrerAcc.id,
        'referredId': account['username'],
        'referralCodeUsed': referralCode,
      });

      final docSnapshot = await accountsRef.doc(account['username']).get();
      return Account.fromDocument(docSnapshot);
    } catch (e) {
      print('creating acc error: ${e.toString()}');
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await accountsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Account> get(String id) async {
    try {
      final doc = await accountsRef.doc(id).get();
      if (!doc.exists) return null;
      return Account.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Account>> getAll() async {
    try {
      final querySnapshot = await accountsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => Account.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> accountData) async {
    try {
      await accountsRef.doc(id).update(accountData);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> login(String username, String password) async {
    try {
      final docSnapshot = await accountsRef.doc(username).get();
      if (!docSnapshot.exists) return false;
      final account = Account.fromDocument(docSnapshot);
      if (account.password != password) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> verifyReferralCode(String code) async {
    try {
      final querySnapshot =
          await accountsRef.where('referralCode', isEqualTo: code).get();

      if (querySnapshot.docs.isEmpty) return null;

      return querySnapshot.docs[0].id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> changePassword(String id, String newPassword) async {
    try {
      await accountsRef.doc(id).update({
        'password': newPassword,
      });
    } catch (e) {
      print('error changing password: ${e.toString()}');
    }
  }
}
