import 'package:flutter/material.dart';

import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/widgets/TextX.dart';

enum Status {
  discovering,
  found,
  notFound,
}

class HubDiscovery extends BaseDeviceSetupPage {
  final VoidCallback onWaitComplete;

  const HubDiscovery({Key? key, required this.onWaitComplete})
      : super(key: key);

  @override
  _HubDiscoveryState createState() => _HubDiscoveryState();
}

class _HubDiscoveryState extends BaseDeviceSetupState<HubDiscovery>
    with MainPage {
  Status status = Status.discovering;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
      ),
      child: Column(
        children: [
          Flexible(
            flex: 58,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.01),
                  child: Image.asset("assets/images/Woosh_AQM.png"),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      '1',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                TextX.heading("Plug in your Woosh hub"),
                TextX.subHeading(
                    "Plug in your Woosh hub into any outlet and look for the green power indicator"),
              ],
            ),
          ),
          Flexible(
            flex: 17,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 42),
                  child: OutlinedButton(
                    onPressed: widget.onWaitComplete,
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
