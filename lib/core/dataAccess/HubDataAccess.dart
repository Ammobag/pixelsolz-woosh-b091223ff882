// ignore_for_file: non_constant_identifier_names

import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/entities/EmptyEntity.dart';
import 'package:whoosh/core/entities/HasHub.dart';
import 'package:whoosh/core/entities/Hub.dart';
import 'package:whoosh/core/entities/HubAqi.dart';
import 'package:whoosh/core/entities/HubClass.dart';
import 'package:whoosh/core/entities/HubData.dart';
import 'package:whoosh/core/entities/HubPasskey.dart';
import 'package:whoosh/core/entities/Node.dart';
import '../BaseApi.dart';
import '../BaseResponse.dart';

class HubDataAccess extends BaseApi {
  static Future<BaseResponse<Hub>> getHub(
      EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = Hub();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Hub>(Method.GET, "hub", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<HasHub>> isUserAssociatedWithAHub(
      EmptyBaseApiRequestModel model) async {
    var token;
    var resModel = HasHub();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<HasHub>(
        Method.GET, "hub/chech-user-hub", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<List<HubData>>> getHubData(
      GetHubDataRequestModel model) async {
    var token;
    var resModel = HubData();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<List<HubData>>(
        Method.POST, "util/get-aqi-logs", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<HubPasskey>> linkUser(String device_id) async {
    LinkHub model = LinkHub();
    model.device_id = device_id;
    var resModel = HubPasskey();
    var token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<HubPasskey>(
        Method.POST, "hub/link-user", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<EmptyEntity>> unlinkUser(
      UnLinkUserRequestModel model) async {
    var resModel = EmptyEntity();
    var token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<EmptyEntity>(
        Method.POST, "hub/unlink-user", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<Node>> linkNode(NodeLinkRequestModel model) async {
    var token;
    var resModel = Node();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<Node>(Method.POST, "hub/link-node", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  static Future<BaseResponse<HubClass>> unLinkNode(
      NodeUnLinkRequestModel model) async {
    var token;
    var resModel = HubClass();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<HubClass>(
        Method.POST, "hub/unlink-node", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }

  /* static Future<BaseResponse<List<HubAqi>>> getHubAqiData(
      EmptyBaseApiRequestModel model, String? id) async {
    var token;
    var resModel = HubAqi();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<List<HubAqi>>(
        Method.GET, "util/get-hub-aqi/$id", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  } */

  static Future<BaseResponse<HubAqi>> getHubAqiData(
    
      EmptyBaseApiRequestModel model, String? id) async {
    var token;
    var resModel = HubAqi();
    token = await SessionHelper.getSession().then((value) => value!.token);
    return BaseApi.call<HubAqi>(
        Method.GET, "util/get-hub-aqi/$id", resModel, model, {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      "Authorization": 'Bearer $token'
    });
  }
}

class LinkHub extends BaseApiRequestModel {
  String? device_id;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "device_id": device_id ?? "",
    };
  }
}

class UnLinkUserRequestModel extends BaseApiRequestModel {
  bool? full_reset;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "full_reset": full_reset ?? false,
    };
  }
}

class GetHubDataRequestModel extends BaseApiRequestModel {
  String? hub_id;
  String? device_time;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "hub_id": hub_id ?? "",
      "device_time": device_time ?? "",
    };
  }
}

class NodeLinkRequestModel extends BaseApiRequestModel {
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

class NodeUnLinkRequestModel extends BaseApiRequestModel {
  String? node_id;
  @override
  Map<String, dynamic> prepareJson() {
    return {
      "node_id": node_id ?? "",
    };
  }
}
