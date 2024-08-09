import 'package:whoosh/core/BaseEntity.dart';

class Node extends BaseEntity<Node> {
  Node({
    this.vanityName,
    this.id,
    this.deviceId,
    this.manufacturedOn,
  });

  String? vanityName;
  String? id;
  String? deviceId;
  DateTime? manufacturedOn;

  Node fromJson(Map<String, dynamic> json) {
    return Node(
      vanityName: json["vanity_name"] == null ? null : json["vanity_name"],
      id: json["_id"] == null ? null : json["_id"],
      deviceId: json["device_id"] == null ? null : json["device_id"],
      manufacturedOn: json["manufactured_on"] == null
          ? null
          : DateTime.parse(json["manufactured_on"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "vanity_name": vanityName == null ? null : vanityName,
        "_id": id == null ? null : id,
        "device_id": deviceId == null ? null : deviceId,
        "manufactured_on":
            manufacturedOn == null ? null : manufacturedOn!.toIso8601String(),
      };
  List<Node> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => Node().fromJson(json)).toList();
  }
}
