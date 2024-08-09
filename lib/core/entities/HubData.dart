import 'package:whoosh/core/BaseEntity.dart';

class HubData extends BaseEntity<HubData> {
  HubData({
    this.id,
    this.hubId,
    this.data,
    this.deviceTime,
    this.serverTime,
    this.updatedAt,
    this.v,
  });

  String? id;
  String? hubId;
  Data? data;
  String? deviceTime;
  String? serverTime;
  String? updatedAt;
  int? v;
  HubData fromJson(Map<String, dynamic> json) => HubData(
        id: json["_id"] == null ? null : json["_id"],
        hubId: json["hub_id"] == null ? null : json["hub_id"],
        data: json["data"] == null ? null : Data().fromJson(json["data"]),
        deviceTime: json["device_time"] == null ? null : json["device_time"],
        serverTime: json["server_time"] == null ? null : json["server_time"],
        updatedAt: json["updatedAt"] == null ? null : json["updatedAt"],
        v: json["__v"] == null ? null : json["__v"],
      );
  Map<String, dynamic> toJson() => {
        "_id": id == null ? null : id,
        "hub_id": hubId == null ? null : hubId,
        "data": data == null ? null : data!.toJson(),
        "device_time": deviceTime == null ? null : deviceTime,
        "server_time": serverTime == null ? null : serverTime,
        "updatedAt": updatedAt == null ? null : updatedAt,
        "__v": v == null ? null : v,
      };
}

class Data {
  Data({
    this.pm25,
    this.pm1,
    this.pm10,
    this.temp,
    this.hum,
    this.tvoc
  });

  String? pm25;
  String? pm1;
  String? pm10;
  String? temp;
  String? hum;
  String? tvoc;
  Data fromJson(Map<String, dynamic> json) => Data(
        pm25: json["pm25"] == null ? null : json["pm25"],
        pm1: json["pm1"] == null ? null : json["pm1"],
        pm10: json["pm10"] == null ? null : json["pm10"],
        temp: json["temp"] == null ? null : json["temp"],
        hum: json["hum"] == null ? null : json["hum"],
        tvoc: json["tvoc"] == null ? null : json["tvoc"],
      );

  Map<String, dynamic> toJson() => {
        "pm25": pm25 == null ? null : pm25,
        "pm1": pm1 == null ? null : pm1,
        "pm10": pm10 == null ? null : pm10,
        "temp": temp == null ? null : temp,
        "hum": hum == null ? null : hum,
        "tvoc": tvoc == null ? null : tvoc,
      };
}
