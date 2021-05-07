import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple),
        strokeWidth: 5.0,
      ));
}

Container linearProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}

showCircularProgress(String displayedText) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0))),
    backgroundColor: Colors.indigo[500],
    content: Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            child: Container(
              child: CircularProgressIndicator(strokeWidth: 3),
              width: 42,
              height: 42,
            ),
            padding: EdgeInsets.only(bottom: 26),
          ),
          Text(
            displayedText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
