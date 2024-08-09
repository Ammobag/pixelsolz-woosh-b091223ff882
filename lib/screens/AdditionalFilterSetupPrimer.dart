import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/entities/Node.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class AdditionalFilterSetupPrimer extends BaseDeviceSetupPage {
  final VoidCallback onAdditionalFilterSetUp;

  final VoidCallback onAdditionalFilterSetUpDone;

  const AdditionalFilterSetupPrimer(
      {Key? key,
      required this.onAdditionalFilterSetUp,
      required this.onAdditionalFilterSetUpDone})
      : super(key: key);

  @override
  _AdditionalFilterSetupPrimerState createState() =>
      _AdditionalFilterSetupPrimerState();
}

class _AdditionalFilterSetupPrimerState
    extends BaseDeviceSetupState<AdditionalFilterSetupPrimer> with MainPage {
  List<Node> _nodes = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      getAllNodes();
    });
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
      _nodes = res.result!.hub!.connectedNodes!;
    });
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

  @override
  body() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
        vertical: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            flex: 30,
            child: Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Color(0xffEBEBEA),
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '3',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    TextX.heading("Set up additional filters"),
                    TextX.subHeading(
                        "Scan the QR code on the filter to connect"),
                    const Text(
                      'Your filters',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 50,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: EdgeInsets.only(left: 10),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(_nodes[index].vanityName!),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            unLinkNode(_nodes[index].id);
                          },
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
            ),
          ),
          Flexible(
            flex: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                OutlinedButton(
                  onPressed: widget.onAdditionalFilterSetUp,
                  child: const Text('Scan'),
                ),
                TextButton(
                  onPressed: widget.onAdditionalFilterSetUpDone,
                  child: const Text('Done'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
