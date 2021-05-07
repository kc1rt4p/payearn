import 'package:flutter/material.dart';

class RoundTextField extends StatelessWidget {
  final String hint;
  final String label;
  final TextEditingController controller;
  final Function validator;
  final bool isPassword;
  final TextInputType textInputType;
  final int maxLines;
  final Function onChanged;
  final bool isReadOnly;
  final Function onTap;
  final Function onEditingComplete;

  const RoundTextField({
    this.hint,
    this.label,
    this.controller,
    this.validator,
    this.isPassword = false,
    this.textInputType,
    this.maxLines = 1,
    this.onChanged,
    this.isReadOnly = false,
    this.onTap,
    this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 6.0,
              top: 6.0,
            ),
            child: TextFormField(
              onEditingComplete: onEditingComplete,
              onTap: onTap,
              controller: controller,
              keyboardType: textInputType,
              readOnly: isReadOnly,
              maxLines: maxLines,
              obscureText: isPassword ? isPassword : false,
              autovalidateMode:
                  validator != null ? AutovalidateMode.onUserInteraction : null,
              validator: validator != null ? validator : null,
              onChanged: onChanged != null ? onChanged : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: hint,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColorDark,
                    width: 3.0,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide(
                    color: Colors.red[600],
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32.0),
                  borderSide: BorderSide(
                    color: Colors.red[600],
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
