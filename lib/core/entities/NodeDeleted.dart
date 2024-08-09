import 'package:whoosh/core/BaseEntity.dart';

class NodeDeleted extends BaseEntity<NodeDeleted> {
  NodeDeleted({
    this.n,
    this.ok,
    this.deletedCount,
  });

  int? n;
  int? ok;
  int? deletedCount;

  NodeDeleted fromJson(Map<String, dynamic> json) => NodeDeleted(
        n: json["n"] == null ? null : json["n"],
        ok: json["ok"] == null ? null : json["ok"],
        deletedCount:
            json["deletedCount"] == null ? null : json["deletedCount"],
      );

  Map<String, dynamic> toJson() => {
        "n": n == null ? null : n,
        "ok": ok == null ? null : ok,
        "deletedCount": deletedCount == null ? null : deletedCount,
      };
}
