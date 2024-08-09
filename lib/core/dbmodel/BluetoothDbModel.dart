// To parse this JSON data, do
//
//     final bluetoothDbModel = bluetoothDbModelFromJson(jsonString);

import 'dart:convert';

class BluetoothDbModel {
    BluetoothDbModel({
        this.id,
        required this.deviceId,
        required this.name,
        this.type,
    });

    int? id;
    String deviceId;
    String name;
    String? type;

    factory BluetoothDbModel.fromRawJson(String str) => BluetoothDbModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory BluetoothDbModel.fromJson(Map<String, dynamic> json) => BluetoothDbModel(
        id: json["id"],
        deviceId: json["device_id"],
        name: json["name"],
        type: json["type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "device_id": deviceId,
        "name": name,
        "type": type,
    };
}
