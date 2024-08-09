import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class FilterName extends BaseDeviceSetupPage {
  final VoidCallback onFilterSetUp;
  final String? deviceId;
  const FilterName({
    Key? key,
    required this.onFilterSetUp,
    required this.deviceId,
  }) : super(key: key);

  @override
  _FilterNameState createState() => _FilterNameState();
}

class _FilterNameState extends BaseDeviceSetupState<FilterName> with MainPage {
  final _filterNameController = TextEditingController();

  Future<void> _linkNode() async {
    if (_filterNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter a filter name"),
        ),
      );
      return;
    }
    final rModel = NodeLinkRequestModel();
    rModel.node_id = widget.deviceId;
    rModel.name = _filterNameController.text;
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.linkNode(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    widget.addNotification(
      context,
      "Filter ${_filterNameController.text} linked successfully",
    );
    _filterNameController.clear();
    widget.onFilterSetUp();
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextX.heading("Enter a name for your filter :"),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.030,
                ),
                Input.getTextField(
                  _filterNameController,
                  false,
                  "Filter Name",
                  null,
                ),
              ],
            ),
          ),
          Flexible(
              flex: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  OutlinedButton(
                    onPressed: _linkNode,
                    child: const Text('Submit'),
                  )
                ],
              ))
        ],
      ),
    );
  }
}
