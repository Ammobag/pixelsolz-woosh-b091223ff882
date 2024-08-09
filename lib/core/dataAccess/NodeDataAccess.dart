// ignore_for_file: non_constant_identifier_names

import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/entities/Node.dart';
import 'package:whoosh/core/entities/NodeDeleted.dart';

import '../BaseApi.dart';
import '../BaseResponse.dart';

class NodeDataAccess extends BaseApi {
  static Future<BaseResponse<Node>> create(NodeCreateRequestModel model) async {
    var token;
    var resModel = Node();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Node>(Method.POST, "node/create", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<Node>> checkAvailable(
      EmptyBaseApiRequestModel model, String id) async {
    var token;
    var resModel = Node();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Node>(
        Method.GET, "node/available/$id", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<Node>> changeName(
      NodeChangeNameRequestModel model) async {
    var token;
    var resModel = Node();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Node>(
        Method.POST, "node/change-name", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<List<Node>>> getAll(
      EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = Node();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<List<Node>>(Method.GET, "node/all", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<NodeDeleted>> delete(
      EmptyBaseApiRequestModel model, String? id) async {
    var token;
    var resModel = NodeDeleted();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<NodeDeleted>(
        Method.GET, "node/delete/$id", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }
}

class NodeCreateRequestModel extends BaseApiRequestModel {
  String? device_id;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "device_id": device_id ?? "",
    };
  }
}

class NodeChangeNameRequestModel extends BaseApiRequestModel {
  String? node_id;
  String? name;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "node_id": node_id ?? "",
      "name": name ?? "",
    };
  }
}
