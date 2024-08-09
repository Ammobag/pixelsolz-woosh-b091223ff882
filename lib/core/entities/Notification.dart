import 'package:whoosh/core/BaseEntity.dart';

class Notification extends BaseEntity<Notification> {
  Notification({
    this.type,
    this.read,
    this.time,
    this.id,
    this.user,
    this.message,
    this.v,
  });

  String? type;
  bool? read;
  DateTime? time;
  String? id;
  String? user;
  String? message;
  int? v;

  Notification fromJson(Map<String, dynamic> json) => Notification(
        type: json["type"] == null ? null : json["type"],
        read: json["read"] == null ? null : json["read"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        id: json["_id"] == null ? null : json["_id"],
        user: json["user"] == null ? null : json["user"],
        message: json["message"] == null ? null : json["message"],
        v: json["__v"] == null ? null : json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "read": read == null ? null : read,
        "time": time == null ? null : time!.toIso8601String(),
        "_id": id == null ? null : id,
        "user": user == null ? null : user,
        "message": message == null ? null : message,
        "__v": v == null ? null : v,
      };
  List<Notification> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => Notification().fromJson(json)).toList();
  }
}
