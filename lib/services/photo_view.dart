import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/progress.dart';

viewPhoto(BuildContext context, String url) {
  showDialog(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.grey[600],
                    child: PhotoView(
                      imageProvider: NetworkImage(url),
                      loadingBuilder: (context, event) {
                        return circularProgress();
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -20,
                    child: RawMaterialButton(
                      onPressed: () => Navigator.pop(context),
                      elevation: 2.0,
                      fillColor: Colors.white,
                      child: Icon(Icons.close),
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
