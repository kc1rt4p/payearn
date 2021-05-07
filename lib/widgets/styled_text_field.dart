import 'package:flutter/material.dart';

class StyledTextField extends StatelessWidget {
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

  const StyledTextField({
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
                fillColor: Colors.white,
                hintText: hint,
                labelText: label,
                isDense: true,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColorDark,
                    width: 2.0,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight,
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
