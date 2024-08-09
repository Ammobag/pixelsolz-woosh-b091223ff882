import 'package:whoosh/core/BaseEntity.dart';

class HubAqi extends BaseEntity<HubAqi> {
  String? sId;
  String? hubId;
  Data? data;
  String? deviceTime;
  String? serverTime;
  String? updatedAt;
  int? iV;

  HubAqi(
      {this.sId,
      this.hubId,
      this.data,
      this.deviceTime,
      this.serverTime,
      this.updatedAt,
      this.iV});

  HubAqi.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    hubId = json['hub_id'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    deviceTime = json['device_time'];
    serverTime = json['server_time'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['hub_id'] = this.hubId;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['device_time'] = this.deviceTime;
    data['server_time'] = this.serverTime;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }

  @override
  HubAqi fromJson(Map<String, dynamic> json) =>HubAqi.fromJson(json);

  List<HubAqi> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => HubAqi().fromJson(json)).toList();
  }
}

class Data {
  String? pm25;
  String? pm1;
  String? pm10;
  String? temp;
  String? hum;
  String? tvoc;

  Data({this.pm25, this.pm1, this.pm10, this.temp, this.hum, this.tvoc});

  Data.fromJson(Map<String, dynamic> json) {
    pm25 = json['pm25'];
    pm1 = json['pm1'];
    pm10 = json['pm10'];
    temp = json['temp'];
    hum = json['hum'];
    tvoc = json['tvoc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pm25'] = this.pm25;
    data['pm1'] = this.pm1;
    data['pm10'] = this.pm10;
    data['temp'] = this.temp;
    data['hum'] = this.hum;
    data['tvoc'] = this.tvoc;
    return data;
  }
}
