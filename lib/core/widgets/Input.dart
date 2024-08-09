import 'package:flutter/material.dart';

class Input {
  static Widget getTextField(TextEditingController controller, bool isObscure,
      String labelText, Widget? icon,
      [TextInputType? inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        floatingLabelBehavior: FloatingLabelBehavior.never,
        fillColor: Color(0xff21211F0A),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        labelText: labelText,
        suffixIcon: icon,
      ),
    );
  }

  static Widget getTextFormField(TextEditingController controller,
      bool isObscure,
      String labelText,
      String? Function(String?)? validator,
      [Widget? suffix]) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        fillColor: Color(0xff21211F0A),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        labelText: labelText,
        suffixIcon: suffix,
      ),
      validator: validator,
    );
  }
}
