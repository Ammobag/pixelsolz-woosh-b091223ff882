import 'package:whoosh/core/BaseApi.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseResponse.dart';
import 'package:whoosh/core/entities/Notification.dart';

import '../SessionHelper.dart';

class NotificationDataAccess extends BaseApi {
  static Future<BaseResponse<Notification>> create(
      NotificationCreateRequestModel model) async {
    var token;
    var resModel = Notification();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Notification>(
        Method.POST, "notification/create", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<List<Notification>>> getAll(
      EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = Notification();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<List<Notification>>(
        Method.GET, "notification/all", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }
}

class NotificationCreateRequestModel extends BaseApiRequestModel {
  String? message;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "message": message ?? "",
    };
  }
}
