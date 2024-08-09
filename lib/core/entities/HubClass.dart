import 'package:whoosh/core/BaseEntity.dart';

import 'Node.dart';

class HubClass extends BaseEntity<HubClass> {
  HubClass({
    this.active,
    this.connectedNodes,
    this.id,
    this.deviceId,
    this.manufacturedOn,
    this.updatedAt,
    this.v,
    this.activationDate,
    this.owner,
    this.passkey,
  });
  bool? active;
  List<Node>? connectedNodes;
  String? id;
  String? deviceId;
  String? manufacturedOn;
  String? updatedAt;
  int? v;
  String? activationDate;
  String? owner;
  String? passkey;
  HubClass fromJson(Map<String, dynamic> json) => HubClass(
        active: json["active"] == null ? null : json["active"],
        connectedNodes: json["connected_nodes"] == null
            ? null
            : json["connected_nodes"]!
                .map<Node>((e) => Node().fromJson(e))
                .toList(),
        id: json["_id"] == null ? null : json["_id"],
        deviceId: json["device_id"] == null ? null : json["device_id"],
        manufacturedOn:
            json["manufactured_on"] == null ? null : json["manufactured_on"],
        updatedAt: json["updatedAt"] == null ? null : json["updatedAt"],
        v: json["__v"] == null ? null : json["__v"],
        activationDate:
            json["activation_date"] == null ? null : json["activation_date"],
        owner: json["owner"] == null ? null : json["owner"],
        passkey: json["passkey"] == null ? null : json["passkey"],
      );

  Map<String, dynamic> toJson() => {
        "active": active == null ? null : active,
        "connected_nodes": connectedNodes == null
            ? null
            : connectedNodes!.map((e) => e.toJson()).toList(),
        "_id": id == null ? null : id,
        "device_id": deviceId == null ? null : deviceId,
        "manufactured_on": manufacturedOn == null ? null : manufacturedOn,
        "updatedAt": updatedAt == null ? null : updatedAt,
        "__v": v == null ? null : v,
        "activation_date": activationDate == null ? null : activationDate,
        "owner": owner == null ? null : owner,
        "passkey": passkey == null ? null : passkey,
      };
}
