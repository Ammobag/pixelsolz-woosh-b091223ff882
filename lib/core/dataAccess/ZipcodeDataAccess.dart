import 'package:whoosh/core/BaseApi.dart';
import 'package:whoosh/core/entities/EmptyEntity.dart';
import 'package:whoosh/core/entities/Zipcode.dart';

import '../BaseApiRequestModel.dart';
import '../BaseResponse.dart';
import '../SessionHelper.dart';

class ZipcodeDataAccess extends BaseApi {
  static Future<BaseResponse<Zipcode>> getZipcode(
      EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = Zipcode();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Zipcode>(Method.GET, "user/zipcode", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<EmptyEntity>> setZipcode(
      ZipcodeSetResponseModel model) async {
    var token;
    var resModel = EmptyEntity();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<EmptyEntity>(
        Method.POST, "user/zipcode", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }
}

class ZipcodeSetResponseModel extends BaseApiRequestModel {
  String? zipcode;

  @override
  Map<String, dynamic> prepareJson() {
    return {
      "zipcode": zipcode ?? "",
    };
  }
}
