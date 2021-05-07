import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cash_out_request.dart';

final cashOutRequestsRef = FirebaseFirestore.instance.collection('accounts');

abstract class ICashOutRequestRepository {
  Future<CashOutRequest> get(String id);
  Future<List<CashOutRequest>> getAll();
  Future<CashOutRequest> create(CashOutRequest cashOutRequest);
  Future<bool> update(String id, Map<String, dynamic> cashOutRequestData);
  Future<bool> delete(String id);
}

class CashOutRequestRepository extends ICashOutRequestRepository {
  @override
  Future<CashOutRequest> create(CashOutRequest cashOutRequest) async {
    try {
      final docRef = await cashOutRequestsRef.add(cashOutRequest.toMap());
      final docSnapshot = await docRef.get();
      return CashOutRequest.fromDocument(docSnapshot);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await cashOutRequestsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CashOutRequest> get(String id) async {
    try {
      final doc = await cashOutRequestsRef.doc(id).get();
      if (!doc.exists) return null;
      return CashOutRequest.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CashOutRequest>> getAll() async {
    try {
      final querySnapshot = await cashOutRequestsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => CashOutRequest.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(
      String id, Map<String, dynamic> cashOutRequestData) async {
    try {
      await cashOutRequestsRef.doc(id).update(cashOutRequestData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
