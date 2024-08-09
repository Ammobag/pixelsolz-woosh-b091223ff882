import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseResponse.dart';
import 'package:whoosh/core/api/ForecastApi.dart';
import 'package:whoosh/core/entities/Forecast.dart';

class ForecastDataAccess extends ForecastApi {
  static Future<BaseResponse<List<Forecast>>> getForecast(
      EmptyBaseApiRequestModel reqModel, String zipCode, String date) async {
    var resModel = Forecast();
    var url =
        'format=application/json&zipCode=$zipCode&date=$date&distance=25&API_KEY=${ForecastApi.apiKey}';
    return ForecastApi.call(url, resModel, reqModel);
  }
}
