import 'package:whoosh/core/BaseEntity.dart';

class HubPasskey extends BaseEntity<HubPasskey> {
  HubPasskey({this.passKey});

  String? passKey;

  HubPasskey fromJson(Map<String, dynamic> json) {
    return HubPasskey(
        passKey: json["passkey"] == null ? null : json["passkey"]);
  }

  Map<String, dynamic> toJson(HubPasskey node) =>
      {"passkey": node.passKey == null ? null : node.passKey};
  List<HubPasskey> fromJsonToList(List<dynamic> jsonList) {
    return jsonList.map((json) => HubPasskey().fromJson(json)).toList();
  }
}
