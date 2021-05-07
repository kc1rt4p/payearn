import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

buildHeartbeatLoading() {
  return Center(
    child: HeartbeatProgressIndicator(
      child: SizedBox(
        height: 80.0,
        child: Image.asset(
          'assets/images/payearn_logo.png',
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}
