// To parse this JSON data, do
//
//     final forgetPass = forgetPassFromJson(jsonString);

import 'dart:convert';

import 'package:whoosh/core/BaseEntity.dart';

class ForgetPass extends BaseEntity<ForgetPass> {
    String? status;
    ForgetPass({
         this.status,
    });

    // String status;

    factory ForgetPass.fromRawJson(String str) => ForgetPass().fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    ForgetPass fromJson(Map<String, dynamic> json) => ForgetPass(
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
    };
}
