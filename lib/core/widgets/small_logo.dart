import 'package:flutter/material.dart';

class SmallLogo extends StatelessWidget {
  final double height;
  final double width;
  SmallLogo({this.height = 23.35, this.width = 96});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/logo_transparent.png', fit: BoxFit.contain),
      height: height,
      width: width,
    );
  }
}
