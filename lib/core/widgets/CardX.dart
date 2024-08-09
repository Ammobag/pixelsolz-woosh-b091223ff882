import 'package:flutter/material.dart';

class CardX {
  String title = "";
  String subtitle = "";
  static Widget getStepCard(String title, String subtitle) {
    return Container(
      height: 80,
      padding: EdgeInsets.only(left: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'STEP $title',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  static Widget getNotificationCard(String title, String subtitle) {
    return Container(
      padding: EdgeInsets.only(left: 12, top: 10, bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
