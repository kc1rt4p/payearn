import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final Widget icon;
  final String text;

  const IconText({Key key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: Colors.red,
        ),
        children: [
          WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: icon,
            ),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}
