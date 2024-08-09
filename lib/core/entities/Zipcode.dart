import 'package:whoosh/core/BaseEntity.dart';

class Zipcode extends BaseEntity<Zipcode> {
  Zipcode({
    this.zipcode,
  });

  String? zipcode;

  Zipcode fromJson(Map<String, dynamic> json) => Zipcode(
        zipcode: json["zipcode"] == null ? null : json["zipcode"],
      );

  Map<String, dynamic> toJson() => {
        "zipcode": zipcode == null ? null : zipcode,
      };
}
