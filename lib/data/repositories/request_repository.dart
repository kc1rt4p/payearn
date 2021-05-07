import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/image_upload.dart';
import '../models/cash_out.dart';
import '../models/request.dart';

final requestsRef = FirebaseFirestore.instance.collection('cashOuts');
final walletsRef = FirebaseFirestore.instance.collection('wallets');

abstract class IRequestRepository {
  Stream<List<Request>> getRequests(String subscriberId);
  Stream<List<CashOut>> getCashOuts();
  Future<void> addRequestDepositphoto(Request request, File photo);
  Future<Request> getRequestById(String cashOutId, String requestId);
  Future<void> deleteRequest(String subscriberId, String requestId);
  Future<void> updateRequestStatus(
      String cashOutId, Request request, String status);
}

class RequestRepository extends IRequestRepository {
  @override
  Stream<List<Request>> getRequests(String subscriberId) {
    return requestsRef
        .doc(subscriberId)
        .collection('requests')
        .orderBy('dateRequested', descending: true)
        .snapshots()
        .transform(documentToRequestListTransformer);
  }

  StreamTransformer documentToRequestListTransformer =
      StreamTransformer<QuerySnapshot, List<Request>>.fromHandlers(
          handleData: (QuerySnapshot snapshot, EventSink<List<Request>> sink) {
    sink.add(snapshot.docs.map((doc) => Request.fromDocument(doc)).toList());
  });

  @override
  Stream<List<CashOut>> getCashOuts() {
    return requestsRef
        .orderBy('lastRequestDate', descending: true)
        .snapshots()
        .transform(documentToCashOutsListTransformer);
  }

  StreamTransformer documentToCashOutsListTransformer =
      StreamTransformer<QuerySnapshot, List<CashOut>>.fromHandlers(
          handleData: (QuerySnapshot snapshot, EventSink<List<CashOut>> sink) {
    sink.add(snapshot.docs.map((doc) => CashOut.fromDocument(doc)).toList());
  });

  @override
  Future<Request> getRequestById(String cashOutId, String requestId) async {
    final requestDoc = await requestsRef
        .doc(cashOutId)
        .collection('requests')
        .doc(requestId)
        .get();

    final request = Request.fromDocument(requestDoc);

    return request;
  }

  @override
  Future<void> updateRequestStatus(
      String cashOutId, Request request, String status) async {
    Map<String, dynamic> statusData = {
      'status': status,
    };

    switch (status) {
      case 'claimed':
        statusData['dateClaimed'] = FieldValue.serverTimestamp();
        break;
      case 'approved':
        statusData['dateApproved'] = FieldValue.serverTimestamp();
        break;
      case 'rejected':
        statusData['dateRejected'] = FieldValue.serverTimestamp();
        break;
    }

    try {
      if (status == 'rejected') {
        await walletsRef.doc(cashOutId).update({
          '${request.wallet}.amount': FieldValue.increment(request.amount),
          '${request.wallet}.lastUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('error: ${e.toString()}');
    }

    await requestsRef
        .doc(request.subscriberId)
        .collection('requests')
        .doc(request.id)
        .update(statusData);
  }

  @override
  Future<void> deleteRequest(String subscriberId, String requestId) async {
    try {
      final requestDoc = await requestsRef
          .doc(subscriberId)
          .collection('requests')
          .doc(requestId)
          .get();
      final request = Request.fromDocument(requestDoc);

      await walletsRef.doc(subscriberId).update({
        '${request.wallet}.amount': FieldValue.increment(request.amount),
        '${request.wallet}.lastUpdate': FieldValue.serverTimestamp(),
      });

      if (request.depositPhotoUrl != null) {
        await FirebaseStorage.instance
            .refFromURL(request.depositPhotoUrl)
            .delete();
      }
      await requestsRef
          .doc(subscriberId)
          .collection('requests')
          .doc(requestId)
          .delete();
    } catch (e) {
      print('error deleting request: ${e.toString()}');
    }
  }

  @override
  Future<void> addRequestDepositphoto(Request request, File photo) async {
    try {
      if (request.depositPhotoUrl != null) {
        await FirebaseStorage.instance
            .refFromURL(request.depositPhotoUrl)
            .delete();
      }

      final newDepositPhotoUrl =
          await uploadImage(photo, 'deposit', request.subscriberId);

      await requestsRef
          .doc(request.subscriberId)
          .collection('requests')
          .doc(request.id)
          .update({
        'depositPhotoUrl': newDepositPhotoUrl,
      });
    } catch (e) {
      print('uploading deposit photo error: ${e.toSString()}');
    }
  }
}
