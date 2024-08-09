// ignore_for_file: non_constant_identifier_names

import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseResponse.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/entities/ForgetPass.dart';
import 'package:whoosh/core/entities/UserSignIn.dart';
import 'package:whoosh/core/entities/UserSignUp.dart';
import 'package:whoosh/core/entities/UserSignInWithGoogle.dart';
import '../BaseApi.dart';

class UserDataAccess extends BaseApi {
  static Future<BaseResponse<UserSignIn>> signIn(
      UserSignInRequestModel model) async {
    var resModel = UserSignIn();
    return BaseApi.call<UserSignIn>(Method.POST, "user/login", resModel, model);
  }

  static Future<BaseResponse<UserSignInWithGoogle>> signInWithGoogle(
      UserSignInWithGoogleRequestModel model) async {
    var resModel = UserSignInWithGoogle();
    return BaseApi.call<UserSignInWithGoogle>(
        Method.POST, "user/google-login", resModel, model);
  }

  static Future<BaseResponse<UserSignUp>> signUp(
      UserSignUpRequestModel model) async {
    var resModel = UserSignUp();
    return BaseApi.call<UserSignUp>(
        Method.POST, "user/register", resModel, model);
  }

  static Future<BaseResponse<UserSignUp>> getUserDetails(
    EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = UserSignUp();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<UserSignUp>(
        Method.GET, "user/userdetails", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<ForgetPass>> forgetPassword(
      UserForgetPasswordRequestModel model) async {
    var resModel = ForgetPass();
    return BaseApi.call<ForgetPass>(Method.POST, "user/forgot-password", resModel, model);
  }

}

class UserSignInRequestModel extends BaseApiRequestModel {
  String? email;
  String? password;

  @override
  Map<String, dynamic> prepareJson() {
    return {
      "email": email ?? "",
      "password": password ?? "",
    };
  }
}

class UserForgetPasswordRequestModel extends BaseApiRequestModel {
  String? email;

  @override
  Map<String, dynamic> prepareJson() {
    return {
      "email": email ?? ""
    };
  }
}

class UserSignInWithGoogleRequestModel extends BaseApiRequestModel {
  String? email;
  String? name;

  @override
  Map<String, dynamic> prepareJson() {
    return {
      "email": email ?? "",
      "name": name ?? "",
    };
  }
}

class UserSignUpRequestModel extends BaseApiRequestModel {
  String? name;
  String? email;
  String? zipcode;
  String? password;
  String? confirm_password;

  @override
  Map<String, dynamic> prepareJson() {
    return {
      "name": name ?? "",
      "email": email ?? "",
      "zipcode": zipcode ?? "",
      "password": password ?? "",
      "confirm_password": confirm_password ?? "",
    };
  }
}
