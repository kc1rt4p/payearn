import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quote.dart';

final quotesRef = FirebaseFirestore.instance.collection('quotes');

abstract class IQuoteRepository {
  Future<List<Quote>> getAll();

  Future<String> add(Map quote);

  Future<bool> delete(String id);
}

class QuoteRepository extends IQuoteRepository {
  @override
  Future<List<Quote>> getAll() async {
    try {
      final querySnapshot = await quotesRef.get();
      if (querySnapshot.docs.isEmpty) return [];
      return querySnapshot.docs.map((doc) => Quote.fromDocument(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> add(Map quote) async {
    try {
      final result = await quotesRef.add({
        'quote': quote['quote'],
        'author': quote['author'],
        'dateAdded': FieldValue.serverTimestamp(),
      });
      return result.id;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      await quotesRef.doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
