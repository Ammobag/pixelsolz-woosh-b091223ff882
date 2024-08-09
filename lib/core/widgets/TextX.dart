import 'package:flutter/material.dart';

class TextX {
  static String content = "";
  static Widget heading(content) {
    return Text(
      content,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    );
  }

  static Widget subHeading(content) {
    return Text(
      content,
      style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 17,
      ),
    );
  }
}
