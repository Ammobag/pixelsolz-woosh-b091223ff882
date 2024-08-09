import 'package:whoosh/core/BaseEntity.dart';

class HasHub extends BaseEntity<HasHub> {
  HasHub({
    this.hasHub,
  });

  bool? hasHub;

  HasHub fromJson(Map<String, dynamic> json) => HasHub(
        hasHub: json["hasHub"] == null ? null : json["hasHub"],
      );

  Map<String, dynamic> toJson() => {
        "hasHub": hasHub == null ? null : hasHub,
      };
}
