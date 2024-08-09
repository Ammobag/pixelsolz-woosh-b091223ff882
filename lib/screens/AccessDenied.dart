import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class AccessDenied extends BaseDeviceSetupPage {
  @override
  _AccessDeniedState createState() => _AccessDeniedState();
}

class _AccessDeniedState extends BaseDeviceSetupState<AccessDenied> with MainPage {
  @override
  Widget body() {
    return WillPopScope(
        onWillPop: () async => false,
        child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.053,
        ),
        child: Column(
          children: [
            Flexible(
              flex: 53,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.04),
                    child: Image.asset("assets/images/splash.png"),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  
                  TextX.heading("Allow Woosh to Access Your Camera and Location?"),
                  TextX.subHeading(
                      "We require access to your camera to scan and add filter(s) and location to pair the Hub. To give access, please re-install the app and allow both accesses"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

