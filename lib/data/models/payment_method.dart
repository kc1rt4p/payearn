import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String name;
  final List<String> options;
  final List<String> requirements;

  PaymentMethod({
    this.id,
    this.name,
    this.options,
    this.requirements,
  });

  factory PaymentMethod.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return PaymentMethod(
      id: docSnapshot.id,
      name: docData['name'],
      options: List.from(docData['options']),
      requirements: List.from(docData['requirements']),
    );
  }

  @override
  List<Object> get props => [
        id,
        name,
        options,
        requirements,
      ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'options': options,
      'requirements': requirements,
    };
  }
}
