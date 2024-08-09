import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseEntity.dart';
import 'package:whoosh/core/BaseResponse.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:whoosh/core/entities/Forecast.dart';

class ForecastApi {
  static final String apiKey = 'E492E2A0-C13C-4E2D-9743-ECAFCDEED6C0';
  static final String baseUrl =
      'https://www.airnowapi.org/aq/forecast/zipCode/?';
  static Future<BaseResponse<T>> call<T>(
      String url, BaseEntity resModel, BaseApiRequestModel reqModel) async {
    Uri finalUrl = Uri.parse(ForecastApi.baseUrl + url);

    var rModel = BaseResponse<T>();

    var response;

    String responseString = "";

    var requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    response = await http.get(finalUrl, headers: requestHeaders);

    responseString = response.body;

    var formattedData = json.decode(responseString);
    List<Forecast> emptyList = [];
    if (formattedData.length == 0) {
      rModel.code = 400;
      rModel.message = "Invalid zip code";
      rModel.status = false;
      rModel.type = "failure";
      rModel.result = emptyList as T?;
      return Future.value(rModel);
    }
    rModel.code = 200;
    rModel.message = "success";
    rModel.status = true;
    rModel.result = resModel.fromJsonToList(formattedData) as T?;
    rModel.type = "success";
    return Future.value(rModel);
  }
}
