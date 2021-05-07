import 'package:flutter/material.dart';

Future<DateTime> pickDate(BuildContext parentContext) async {
  final DateTime _initialDate =
      DateTime.now().subtract(Duration(days: 365 * 30));

  final DateTime picked = await showDatePicker(
      context: parentContext,
      initialDate: _initialDate,
      firstDate: DateTime(1940, 8),
      lastDate: DateTime(2022));

  if (picked != null && picked != _initialDate) {
    return picked;
  }

  return null;
}
