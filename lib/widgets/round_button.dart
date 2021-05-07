import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Color color;
  final Function onPressed;
  final String labelText;
  final Color labelColor;

  RoundButton({
    this.color,
    this.onPressed,
    this.labelText,
    this.labelColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color,
      disabledColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
      onPressed: onPressed,
      child: Text(
        labelText,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20.0,
          color: labelColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
