import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'dart:io' show Platform;

const String STA_DEFAULT_SSID = "STA_SSID";
const String STA_DEFAULT_PASSWORD = "STA_PASSWORD";
const NetworkSecurity STA_DEFAULT_SECURITY = NetworkSecurity.WPA;

const String AP_DEFAULT_SSID = "AP_SSID";
const String AP_DEFAULT_PASSWORD = "AP_PASSWORD";

void main() => runApp(FlutterWifiIoT());

class FlutterWifiIoT extends StatefulWidget {
  @override
  _FlutterWifiIoTState createState() => _FlutterWifiIoTState();
}

class _FlutterWifiIoTState extends State<FlutterWifiIoT> {
  String? _sPreviousAPSSID = "";
  String? _sPreviousPreSharedKey = "";

  List<WifiNetwork?>? _htResultNetwork;
  Map<String, bool>? _htIsNetworkRegistered = Map();

  bool _isEnabled = false;
  bool _isConnected = false;
  bool _isWiFiAPEnabled = false;
  bool _isWiFiAPSSIDHidden = false;
  bool _isWifiAPSupported = true;
  bool _isWifiEnableOpenSettings = false;
  bool _isWifiDisableOpenSettings = false;

  final TextStyle textStyle = TextStyle(color: Colors.white);

  @override
  initState() {
    
    super.initState();
    checkWifi();
    
  }
  checkWifi() async{
    final wifis = await WiFiForIoTPlugin.loadWifiList();
    connectWifi();
    /* print(wifis);
    for(var wifi in wifis){
      print(wifi.ssid);
    } */
  }

  connectWifi() async{
    final ssid = "Galaxy M210912";
    final res = await WiFiForIoTPlugin.connect(
            ssid,
            password: "Imparvin95#",
            security: NetworkSecurity.WPA,
            withInternet: false,
          );
    if (res)
      print("connected");
  }


  @override
  Widget build(BuildContext poContext) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          body: Container(
            child: Text("Test"),
          ),
        ),
    );
  }
}

class PopupCommand {
  String command;
  String argument;

  PopupCommand(this.command, this.argument);
}