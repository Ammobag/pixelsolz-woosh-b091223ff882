import 'package:flutter/material.dart';

class MainLogo extends StatelessWidget {
  final double height;
  final double width;
  MainLogo({this.height = 184, this.width = 128});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset('assets/images/logo_m.png', fit: BoxFit.contain),
      height: height,
      width: width,
    );
  }
}
