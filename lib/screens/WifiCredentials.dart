import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class WifiCredentials extends BaseDeviceSetupPage {
  final Function(ScreenArguments) onPasswordGiven;

  const WifiCredentials({
    Key? key,
    required this.onPasswordGiven,
  }) : super(key: key);

  @override
  _WifiCredentialsState createState() => _WifiCredentialsState();
}

class _WifiCredentialsState extends BaseDeviceSetupState<WifiCredentials>
    with MainPage {
  final _passwordController = TextEditingController();
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
                TextX.heading("Enter the password for:"),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.014,
                ),
                TextX.subHeading("Mint 5G"),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.029,
                ),
                Input.getTextField(_passwordController, true, "Password", null),
              ],
            ),
          ),
          Flexible(
            flex: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    widget.onPasswordGiven(ScreenArguments(
                      _passwordController.text,
                    ));
                  },
                  child: const Text('Submit'),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
