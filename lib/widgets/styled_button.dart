import 'package:flutter/material.dart';

class StyledButton extends StatelessWidget {
  final String labelText;
  final Function onPressed;
  final Color color;

  const StyledButton(
      {@required this.labelText,
      @required this.onPressed,
      this.color = Colors.white})
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 25.0,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey;
            }
            return color;
          }),
        ),
        onPressed: onPressed,
        child: Text(
          labelText,
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
            fontSize: 12.0,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }
}
