import 'package:whoosh/core/BaseEntity.dart';

class Forecast extends BaseEntity<Forecast> {
  Forecast({
    this.dateIssue,
    this.dateForecast,
    this.reportingArea,
    this.stateCode,
    this.latitude,
    this.longitude,
    this.parameterName,
    this.aqi,
    this.category,
    this.actionDay,
  });

  String? dateIssue;
  String? dateForecast;
  String? reportingArea;
  String? stateCode;
  double? latitude;
  double? longitude;
  String? parameterName;
  int? aqi;
  Category? category;
  bool? actionDay;

  Forecast fromJson(Map<String, dynamic> json) => Forecast(
        dateIssue: json["DateIssue"] == null ? null : json["DateIssue"],
        dateForecast:
            json["DateForecast"] == null ? null : json["DateForecast"],
        reportingArea:
            json["ReportingArea"] == null ? null : json["ReportingArea"],
        stateCode: json["StateCode"] == null ? null : json["StateCode"],
        latitude: json["Latitude"] == null ? null : json["Latitude"].toDouble(),
        longitude:
            json["Longitude"] == null ? null : json["Longitude"].toDouble(),
        parameterName:
            json["ParameterName"] == null ? null : json["ParameterName"],
        aqi: json["AQI"] == null ? null : json["AQI"],
        category: json["Category"] == null
            ? null
            : Category().fromJson(json["Category"]),
        actionDay: json["ActionDay"] == null ? null : json["ActionDay"],
      );

  Map<String, dynamic> toJson() => {
        "DateIssue": dateIssue == null ? null : dateIssue,
        "DateForecast": dateForecast == null ? null : dateForecast,
        "ReportingArea": reportingArea == null ? null : reportingArea,
        "StateCode": stateCode == null ? null : stateCode,
        "Latitude": latitude == null ? null : latitude,
        "Longitude": longitude == null ? null : longitude,
        "ParameterName": parameterName == null ? null : parameterName,
        "AQI": aqi == null ? null : aqi,
        "Category": category == null ? null : category!.toJson(),
        "ActionDay": actionDay == null ? null : actionDay,
      };
  List<Forecast> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => Forecast().fromJson(json)).toList();
  }
}

class Category {
  Category({
    this.number,
    this.name,
  });

  int? number;
  String? name;

  Category fromJson(Map<String, dynamic> json) => Category(
        number: json["Number"] == null ? null : json["Number"],
        name: json["Name"] == null ? null : json["Name"],
      );

  Map<String, dynamic> toJson() => {
        "Number": number,
        "Name": name,
      };
}
