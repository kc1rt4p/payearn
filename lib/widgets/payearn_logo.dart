import 'package:flutter/material.dart';

class PayEarnLogo extends StatelessWidget {
  final double size;
  final bool withBackground;

  const PayEarnLogo({@required this.size, this.withBackground = false});

  @override
  Widget build(BuildContext context) {
    if (withBackground) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                height: size,
                child: Image.asset('assets/images/payearn_logo.png'),
              ),
              SizedBox(width: 5.0),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'PayEarn',
                  style: TextStyle(
                    fontFamily: 'Signatra',
                    color: Colors.white,
                    fontSize: size,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            height: size,
            child: Image.asset('assets/images/payearn_logo.png'),
          ),
          SizedBox(width: 5.0),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              'PayEarn',
              style: TextStyle(
                fontFamily: 'Signatra',
                color: Colors.white,
                fontSize: size,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      );
    }
  }
}
