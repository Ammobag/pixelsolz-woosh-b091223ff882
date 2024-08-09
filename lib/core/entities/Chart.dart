class Chart {
  Chart({
    this.id,
    this.data,
  });

  String? id;
  List<Data>? data;
  Chart fromJson(Map<String, dynamic> json) => Chart(
        id: json["_id"] == null ? null : json["_id"],
        data: json["data"] == null
            ? null
            : json["data"].map<Data>((e) => Data().fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "data": data!.map((e) => e.toJson()).toList(),
      };
}

class Data {
  Data({
    this.date,
    this.currentPressure,
    this.temperature,
    this.humidity,
    this.baselinePressure,
    this.battery,
  });

  String? date;
  double? currentPressure;
  double? temperature;
  double? humidity;
  double? baselinePressure;
  int? battery;
  Data fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : json["date"],
        currentPressure: json["current_pressure"] == null
            ? null
            : json["current_pressure"].toDouble(),
        temperature:
            json["temperature"] == null ? null : json["temperature"].toDouble(),
        humidity: json["humidity"] == null ? null : json["humidity"].toDouble(),
        baselinePressure: json["baseline_pressure"] == null
            ? null
            : json["baseline_pressure"].toDouble(),
        battery: json["battery"] == null ? null : json["battery"],
      );

  Map<String, dynamic> toJson() => {
        "date": date == null ? null : date,
        "current_pressure": currentPressure == null ? null : currentPressure,
        "temperature": temperature == null ? null : temperature,
        "humidity": humidity == null ? null : humidity,
        "baseline_pressure": baselinePressure == null ? null : baselinePressure,
        "battery": battery == null ? null : battery,
      };
}
