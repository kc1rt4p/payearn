import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Im;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

Future<File> compressImage(File file, String accountId) async {
  final tempDir = await getTemporaryDirectory();
  final path = tempDir.path;
  Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
  final compressedImageFile = File('$path/img_$accountId.jpg')
    ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 70));
  return compressedImageFile;
}

Future<String> uploadImage(
    File imageFile, String type, String accountId) async {
  File file = await compressImage(imageFile, accountId);
  Reference storageRef = type == 'deposit'
      ? FirebaseStorage.instance.ref().child(
          'uploads/$accountId/$type/${DateFormat('MMddyyyy').format(DateTime.now())}.jpg')
      : FirebaseStorage.instance.ref().child('uploads/$accountId/$type.jpg');
  UploadTask uploadTask = storageRef.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask;
  var downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl.toString();
}
