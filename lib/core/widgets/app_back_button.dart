import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Ink(
      width: 30,
      child: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        iconSize: 18,
        splashRadius: 20,
        onPressed: () => Navigator.of(context).pop(),
      ),
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: CircleBorder()
      ),
    );
  }
}
