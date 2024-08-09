import 'package:flutter/cupertino.dart';

class AQI {
  static Color good = Color(0xFF00D800);
  static Color satisfactory = Color(0xFFffeb3b);
  static Color moderate = Color(0xFFFF9A00);
  static Color poor = Color(0xFFFF1800);
  static Color veryPoor = Color(0xFF8F82C7);
  static Color severe = Color(0xFF8D290C);
  static getColorCode(double aqi) {
    if (aqi <= 50) return good;
    if (aqi > 50 && aqi <= 100) return satisfactory;
    if (aqi > 100 && aqi <= 150) return moderate;
    if (aqi > 150 && aqi <= 200) return poor;
    if (aqi > 200 && aqi <= 300) return veryPoor;
    if (aqi > 300) return severe;
  }
}
