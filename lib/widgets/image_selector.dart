import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelect {
  final picker = ImagePicker();
  final String titleText;
  File image;

  ImageSelect({
    this.titleText,
  });

  selectImage(parentContext) async {
    await showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(titleText),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Photo with Camera"),
              onPressed: () => handleTakePhoto(context),
            ),
            SimpleDialogOption(
              child: Text("Image from Gallery"),
              onPressed: () => handleChooseFromGallery(context),
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
    return image;
  }

  handleTakePhoto(BuildContext currentContext) async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      image = File(pickedFile?.path);
    }
    Navigator.pop(currentContext);
  }

  handleChooseFromGallery(BuildContext currentContext) async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile?.path);
    }
    Navigator.pop(currentContext);
  }
}
