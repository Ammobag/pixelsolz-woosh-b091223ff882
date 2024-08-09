import 'package:whoosh/core/BaseEntity.dart';
import 'package:whoosh/core/entities/Node.dart';

import 'Chart.dart';
import 'HubClass.dart';

class Hub extends BaseEntity<Hub> {
  Hub({
    this.hub,
    this.chart,
    this.nodes
  });

  HubClass? hub;
  List<Chart>? chart;
  List<Node>? nodes;

  Hub fromJson(Map<String, dynamic> json) => Hub(
        hub: json["hub"] == null ? null : HubClass().fromJson(json["hub"]),
        chart: json["chart"] == null
            ? null
            : List<Chart>.from(json["chart"].map((x) => Chart().fromJson(x))),
            nodes: json["nodes"] == null
            ? null
            : List<Node>.from(json["nodes"].map((x) => Node().fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "hub": hub == null ? null : hub!.toJson(),
        "chart": chart == null ? null : chart!.map((e) => e.toJson()).toList(),
        "nodes": nodes == null ? null : nodes!.map((e) => e.toJson()).toList(),
      };
}
