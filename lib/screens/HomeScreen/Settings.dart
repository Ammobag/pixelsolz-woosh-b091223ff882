// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:whoosh/constants/dialog_box_constant.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseScreen.dart';

import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/dataAccess/NodeDataAccess.dart';
import 'package:whoosh/core/entities/Node.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/TextX.dart';
import 'package:whoosh/screens/SetupPrimer.dart';

class Settings extends BasePage {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends BaseState<Settings> with MasterPage {
  List<Node> _nodes = [];
  final _filterNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      getAllNodes();
    });
  }

  void dispose() {
    _filterNameController.dispose();
    super.dispose();
  }

  Future<void> unLinkNode(String? id) async {
    final rModel = NodeUnLinkRequestModel();
    rModel.node_id = id;
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.unLinkNode(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    await getAllNodes();
  }

  Future<void> getAllNodes() async {
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.getHub(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    setState(() {
      if (res.result != null) {
        _nodes = res.result!.hub!.connectedNodes!;
      }
    });
  }

  Future<void> changeNodeName(String? node_id, String? name) async {
    final rModel = NodeChangeNameRequestModel();
    rModel.name = _filterNameController.text;
    rModel.node_id = node_id;
    widget.showPageLoader(context, true);
    var res = await NodeDataAccess.changeName(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    widget.addNotification(context,
        "Filter name changed from $name to ${_filterNameController.text}");
    await getAllNodes();
    _filterNameController.clear();
  }

  Future<void> _changeWifiNetwork() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Wi-Fi network', textAlign: TextAlign.center, style: kDBTitleStyle,),
          insetPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to? You will have to manually reset the Hub to reconnect', textAlign: TextAlign.center, style: kDBContentStyle,),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    onPressed: ()  {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kDBButtonSecondaryColor,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetupPrimer(hasChangeWifi: true,)),
                      );
                    },
                    child: const Text('Yes', style: TextStyle(color: Colors.black),),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset connection to Hub?', style: kDBTitleStyle, textAlign: TextAlign.center,),
          insetPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'This will remove all associated filters from your account', style: kDBContentStyle,),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    onPressed: ()  {
                      Navigator.of(context).pop();
                    },
                    child: const Text('No'),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kDBButtonSecondaryColor,
                    ),
                    onPressed: unlinkUser,
                    child: const Text('Yes', style: TextStyle(color: Colors.black),),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
          ],
        );
      },
    );
  }

  Future<void> unlinkUser([bool isFullReset = true]) async {
    final rModel = UnLinkUserRequestModel();
    rModel.full_reset = isFullReset;
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.unlinkUser(rModel);
    print(res.result);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    widget.addNotification(context, "Unlinked User from Hub");
    Navigator.of(context).pop();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeSetupPrimer, (route) => false);
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, String? node_id, String? name) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change filter name', style: kDBTitleStyle,),
          content: TextField(
            onChanged: (value) {},
            controller: _filterNameController,
            decoration: InputDecoration(
                hintText: "Bedroom Filter", labelText: "Filter Name"),
          ),
          actions: [
            SizedBox(
              width: kDBButtonWidth,
              height: kDBButtonHeight,
              child: OutlinedButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: kDBButtonSecondaryColor
                ),
              ),
            ),
            SizedBox(
              width: kDBButtonWidth,
              height: kDBButtonHeight,
              child: OutlinedButton(
                child: Text('OK'),
                onPressed: () {
                  changeNodeName(node_id, name);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextX.heading("Settings"),
        Flexible(
          flex: 43,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Text(
                'Hub',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    HubSettingTile(
                      content: "Change Wi-Fi network",
                      icon: Icon(
                        Icons.wifi,
                      ),
                      onTap: () {
                        _changeWifiNetwork();
                      },
                    ),
                    /* HubSettingTile(
                      content: "Change Wi-Fi password",
                      icon: Icon(
                        Icons.password,
                      ),
                      onTap: () {
                        _changeWifiNetwork();
                      },
                    ), */
                    HubSettingTile(
                      content: "Reset Hub connection",
                      icon: Icon(
                        Icons.refresh_outlined,
                      ),
                      onTap: _showMyDialog,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        Flexible(
          flex: 57,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Text(
                'Your filters',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10),
                height: MediaQuery.of(context).size.height * 0.0615,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Add Filter"),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(routeAddFilterStartPage);
                      },
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.only(left: 10),
                      height: MediaQuery.of(context).size.height * 0.0615,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey.shade300,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_nodes[index].vanityName!),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _displayTextInputDialog(
                                    context,
                                    _nodes[index].id,
                                    _nodes[index].vanityName,
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  unLinkNode(
                                    _nodes[index].id,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: 10,
                    );
                  },
                  itemCount: _nodes.length,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class HubSettingTile extends StatelessWidget {
  final String content;
  final Icon icon;
  final void Function()? onTap;
  HubSettingTile({
    required this.content,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: MediaQuery.of(context).size.height * 0.0615,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.grey.shade300,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(content),
            icon,
          ],
        ),
      ),
    );
  }
}
