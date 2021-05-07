import 'package:flutter/material.dart';

class ProfileTextField extends StatelessWidget {
  final String labelText;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool readOnly;
  final Function onTap;
  final TextAlign textAlign;
  final Function validator;

  const ProfileTextField({
    this.labelText,
    this.keyboardType,
    this.controller,
    this.readOnly = false,
    this.onTap,
    this.textAlign = TextAlign.left,
    this.validator,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        validator: validator,
        maxLines: null,
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        textAlign: textAlign,
        decoration: InputDecoration(
          labelText: labelText,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}
