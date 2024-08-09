import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/core/entities/UserSignInWithGoogle.dart';
import 'dart:convert';
import 'entities/UserSignIn.dart';

class SessionHelper {
  static const String _userToken = "User";
  static Future<void> setSession(var user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = user == null ? "" : json.encode(user.toJson());
    await prefs.setString(_userToken, userData);
  }

  static Future<dynamic> getSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var item = prefs.getString(_userToken);
    if (item == null) {
      return null;
    }
    Map<String, dynamic> decodedData = json.decode(item);
    if (decodedData["user"]["type"] == "email")
      return UserSignIn().fromJson(json.decode(item));
    else
      return UserSignInWithGoogle().fromJson(json.decode(item));
  }

  static Future<void> deleteSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('User');
  }

  static Future<void> updateSession(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var item = prefs.getString(_userToken);
    if (item == null) {
      return null;
    }
    var userData;
    Map<String, dynamic> decodedData = json.decode(item);
    decodedData["user"][key] = value;
    if (decodedData["user"]["type"] == "email")
      userData = json.encode(decodedData);
    else
      userData = json.encode(decodedData);
    await prefs.setString(_userToken, userData);
  }
}
