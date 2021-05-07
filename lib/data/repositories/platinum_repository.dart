import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/platinum.dart';

final platinumsRef = FirebaseFirestore.instance.collection('platinums');

abstract class IPlatinumRepository {
  Future<Platinum> get(String id);
  Stream<Platinum> streamPlatinum(String id);
  Future<List<Platinum>> getAll();
  Future<Platinum> create(Platinum platinum);
  Future<bool> update(String id, Map<String, dynamic> platinumData);
  Future<bool> delete(String id);
}

class PlatinumRepository extends IPlatinumRepository {
  @override
  Future<Platinum> create(Platinum platinum) async {
    try {
      final docRef = await platinumsRef.add(platinum.toMap());
      final docSnapshot = await docRef.get();
      return Platinum.fromDocument(docSnapshot);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await platinumsRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Platinum> get(String id) async {
    try {
      final doc = await platinumsRef.doc(id).get();
      if (!doc.exists) return null;
      return Platinum.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Platinum>> getAll() async {
    try {
      final querySnapshot = await platinumsRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs
          .map((doc) => Platinum.fromDocument(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> update(String id, Map<String, dynamic> platinumData) async {
    try {
      await platinumsRef.doc(id).update(platinumData);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<Platinum> streamPlatinum(String id) {
    return platinumsRef
        .doc(id)
        .snapshots()
        .transform(documentToPlatinumTransformer);
  }

  StreamTransformer documentToPlatinumTransformer =
      StreamTransformer<DocumentSnapshot, Platinum>.fromHandlers(
          handleData: (DocumentSnapshot snapshot, EventSink<Platinum> sink) {
    sink.add(snapshot.exists ? Platinum.fromDocument(snapshot) : null);
  });
}
