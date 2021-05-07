import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Subscriber extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final Timestamp birthDate;
  final String email;
  final String mobile;
  final String address;
  final String photoUrl;
  final String work;
  final String workAddress;
  final String idUrl;
  final bool hasPlatinum;
  final bool isVerified;
  final Timestamp dateVerified;

  Subscriber({
    this.id,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.email,
    this.mobile,
    this.address,
    this.photoUrl,
    this.work,
    this.workAddress,
    this.idUrl,
    this.hasPlatinum,
    this.isVerified,
    this.dateVerified,
  });

  @override
  List<Object> get props => [
        id,
        firstName,
        lastName,
        birthDate,
        email,
        mobile,
        address,
        photoUrl,
        work,
        workAddress,
        idUrl,
        hasPlatinum,
        isVerified,
        dateVerified,
      ];

  factory Subscriber.fromDocument(DocumentSnapshot docSnapshot) {
    Map docData = docSnapshot.data();
    return Subscriber(
      id: docSnapshot.id,
      firstName: docData['firstName'],
      lastName: docData['lastName'],
      birthDate: docData['birthDate'],
      email: docData['email'],
      mobile: docData['mobile'],
      address: docData['address'],
      photoUrl: docData['photoUrl'],
      work: docData['work'],
      workAddress: docData['workAddress'],
      idUrl: docData['idUrl'],
      hasPlatinum: docData['hasPlatinum'],
      isVerified: docData['isVerified'],
      dateVerified: docData['dateVerified'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'email': email,
      'mobile': mobile,
      'address': address,
      'photoUrl': photoUrl,
      'work': work,
      'workAddress': workAddress,
      'idUrl': idUrl,
      'hasPlatinum': false,
      'isVerified': false,
    };
  }
}
