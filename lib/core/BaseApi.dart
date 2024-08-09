// ignore_for_file: avoid_init_to_null

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'BaseApiRequestModel.dart';
import 'BaseEntity.dart';
import 'BaseResponse.dart';

enum Method { GET, POST }

class BaseApi {
    static final String baseUrl = 'http://3.17.139.144:2883/'; // Server dev
   // static final String baseUrl = 'http://3.17.139.144:3000/'; // Server production
  // static final String baseUrl = 'http://192.168.43.197:2883/';
  // static final String baseUrl = 'http://192.168.0.9:2883/'; // local
  //static final String baseUrl = 'http://192.168.0.104:2883/'; // local
  //static final String baseUrl = 'http://192.168.133.83:2883/'; // my local

  static Future<BaseResponse<T>> call<T>(Method method, String url,
      BaseEntity resModel, BaseApiRequestModel reqModel,
      [Map<String, String>? requestHeaders = null]) async {
    Uri finalUrl = Uri.parse(BaseApi.baseUrl + url);

    var rModel = BaseResponse<T>();
    var response;
    String responseString = "";
    var strRequestData = "";
    var requestData = reqModel.toJson();
    strRequestData = json.encode(requestData);
    requestHeaders = requestHeaders ??
        {
          'Content-type': 'application/json',
          'Accept': 'application/json',
        };
    if (method == Method.GET) {
      try {
        response = await http.get(finalUrl, headers: requestHeaders);
        print(finalUrl);
        print(response);
      } catch (e) {
        print(e);
      }
    } else if (method == Method.POST) {
      try {
        response = await http.post(finalUrl,
            body: strRequestData, headers: requestHeaders);
      } catch (e) {
        print(e);
      }
    }
    print(responseString);

    responseString = response.body;
    print(responseString);
    var formattedData = json.decode(responseString);
    rModel.code = formattedData['code'];
    rModel.message = formattedData['message'];
    rModel.status = formattedData["status"] ?? formattedData["status"] ?? false;
    rModel.type = formattedData['type'];
    var decodeData = formattedData["result"];
    if (decodeData.length == 0 || decodeData == null) {
      rModel.result = null;
      return Future.value(rModel);
    }
    if (decodeData is Map<String, dynamic>) {
      rModel.result = resModel.fromJson(decodeData);
    } else if (decodeData is List) {
      rModel.result = resModel.fromJsonToList(decodeData) as T?;
    }
    return Future.value(rModel);
  }
}
