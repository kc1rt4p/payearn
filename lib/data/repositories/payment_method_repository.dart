import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/payment_method.dart';

final paymentMethodsRef =
    FirebaseFirestore.instance.collection('paymentMethods');

abstract class IPaymentMethodRepository {
  Future<PaymentMethod> get(String id);
  Future<List<PaymentMethod>> getAll();
  Future<PaymentMethod> create(PaymentMethod paymentMethod);
  Future<bool> update(String id, Map<String, dynamic> paymentMethodData);
  Future<bool> delete(String id);
}

class PaymentMethodRepository extends IPaymentMethodRepository {
  @override
  Future<PaymentMethod> create(PaymentMethod paymentMethod) async {
    try {
      final docRef = await paymentMethodsRef.add(paymentMethod.toMap());
      final docSnapshot = await docRef.get();
      return PaymentMethod.fromDocument(docSnapshot);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await paymentMethodsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<PaymentMethod> get(String id) async {
    try {
      final doc = await paymentMethodsRef.doc(id).get();
      if (!doc.exists) return null;
      return PaymentMethod.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PaymentMethod>> getAll() async {
    try {
      final querySnapshot = await paymentMethodsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => PaymentMethod.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> paymentMethodData) async {
    try {
      await paymentMethodsRef.doc(id).update(paymentMethodData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
