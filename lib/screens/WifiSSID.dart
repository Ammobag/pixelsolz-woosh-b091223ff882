import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:whoosh/constants/dialog_box_constant.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:whoosh/core/widgets/TextX.dart';
import 'package:whoosh/helper/wifi_signal_helper.dart';
import 'package:whoosh/screens/HubWifi.dart';
import 'package:wifi_iot/wifi_iot.dart';

enum WifiStatus {
  initial,
  connected,
  disconnected,
  connecting,
  nointernet,
  mqttnotconnected
}

class WiFiSSID extends BaseDeviceSetupPage {
  final Function(bool) setLoader;
  final Function() onWifiConnected;

  final BluetoothDevice bluetoothService;
  WiFiSSID(
      {Key? key,
      required this.onWifiConnected,
      String? password,
      required this.bluetoothService,required this.setLoader})
      : super(key: key);

  @override
  _WiFiSSIDState createState() => _WiFiSSIDState();
}

class _WiFiSSIDState extends BaseDeviceSetupState<WiFiSSID> with MainPage {
  WifiStatus _wifiStatus = WifiStatus.initial;
  String _wifistatusMessage = "";
  //WifiStatus.disconnected;
  //List<WifiNetwork> wifis = [];
  List<Map<String, String>> wifis = [];
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _ssidFieldController = TextEditingController();
  bool _passwordObsecure = true;
  late StateSetter _setState;
  // ignore: non_constant_identifier_names
  final String BLE_SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";

  final String BLE_CHARACTERISTIC_ACK_UUID =
      "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String BLE_CHARACTERISTIC_WRITE_UUID =
      "6e400003-b5a3-f393-e0a9-e50e24dcca9e";
  // ignore: non_constant_identifier_names
  final String BLE_CHARACTERISTIC_READ_UUID =
      "6e400004-b5a3-f393-e0a9-e50e24dcca9e";
  final HubDataAccess hubDataAccess = HubDataAccess();
  bool isclickable = true;
  int counter = 0;
  bool _isObscure = true;
  BluetoothCharacteristic? currentBluetoothCharacteristic;
  @override
  void initState() {
    super.initState();
    getAllWifiNetworks();
  }

  autoRefreshWifi() async{
    
    Timer.periodic(new Duration(seconds: 15), (timer) async{
      // print("inside");
      if(isclickable && mounted){
        // print("mounted");
        // print(mounted);
        // print("isClickable");
        
        //print("await");
        if(currentBluetoothCharacteristic !=null ){
          //print("done");
          //print(currentBluetoothCharacteristic);
          try{
            List<int> ssidBuffers = await currentBluetoothCharacteristic!.read();
            List<String> ssids = utf8.decode(ssidBuffers).split(',');
            print("hello");
            print(ssids);
            print("hello");
            wifis = [];
            for (int i = 0; i < ssids.length; i++){
              if (ssids[i].length > 0) {
                bool isExist = wifis.any((item) => item["ssid"] == ssids[i]);
                if(!isExist){
                  wifis.add({"ssid": ssids[i]});
                }
              }
            }
            if(mounted){
              setState(() {
                
              });
            }
            
          }
          catch(e){

          }
          
        }
        
      }
      if(!mounted){
        timer.cancel();
      }
    }); 
    // print("hello");
    //await Future.delayed(const Duration(milliseconds: 15000), () {});
    
    //autoRefreshWifi();
    
  }

  Future<void> scanForWIFI() async {
    try{
      List<BluetoothService> services =
          await widget.bluetoothService.discoverServices();
      //print(services.length);
      wifis = [];
      for(var v=0; v<services.length; v++){
        
        BluetoothService service = services[v];
        if (service.uuid.toString() == BLE_SERVICE_UUID) {
          //print(service.characteristics);
          service.characteristics.forEach((characteristic) async {
            if (characteristic.properties.read &&
                characteristic.uuid.toString() == BLE_CHARACTERISTIC_READ_UUID) {
              try{
                currentBluetoothCharacteristic = characteristic;
                // print(characteristic);
                List<int> ssidBuffers = await characteristic.read();
                List<String> ssids = utf8.decode(ssidBuffers).split(',');
                print("hello");
                print(ssids);
                print("hello");
                for (int i = 0; i < ssids.length; i++){
                  if (ssids[i].length > 0) {
                    bool isExist = wifis.any((item) => item["ssid"] == ssids[i]);
                    if(!isExist){
                      wifis.add({"ssid": ssids[i]});
                    }
                  }
                }
              }
              catch(e){
                scanForWIFI();
              }
            }
          });
        }
      }
    }catch(e){
      print(e.toString());
    }
  }
  
  getAllWifiNetworks() async {
    
    Future.delayed(Duration.zero, () async {
      isclickable = false;
      widget.setLoader(true);
      
      /* widget.showPageLoader(context, true,text: "Fetching Available Wi-Fi List from the Hub. Won't Be Long!"); */
      widget.showPageLoaderWithLogo(context, true,text:"Connected to hub\n Fetching Available Wi-Fi list");
    });
    
    scanForWIFI();
    await Future.delayed(const Duration(milliseconds: 2000), () {});
    autoRefreshWifi();
    if(wifis.length == 0){
      counter = counter + 1;
      // print(wifis);
      // print("abc");
      if(counter>4){
        showWifiErrorMessage();
        widget.showPageLoader(context, false);
        isclickable = true;
        widget.setLoader(false);
      }
      else
      {
        getAllWifiNetworks();
      }
    }
    else{
      widget.showPageLoader(context, false);
      isclickable = true;
      widget.setLoader(false);
      setState(() {});
    }
    
  }

  connectWifi(ssid, password) async {
    widget.setLoader(true);
    widget.showPageLoaderWithLogo(context, true,text: "Connecting Hub to Internet.");
    if (mounted) {
      setState(() {
        _wifiStatus = WifiStatus.connecting;
        isclickable = false;
      });
    }
    await widget.bluetoothService.disconnect();
    await widget.bluetoothService.connect(autoConnect: false);
    var data =
        await HubDataAccess.linkUser(widget.bluetoothService.name.toString());
    // print(widget.bluetoothService.name);
    List<BluetoothService> services =
        await widget.bluetoothService.discoverServices();

    try {
      services.forEach((service) {
        if (service.uuid.toString() == BLE_SERVICE_UUID) {
          service.characteristics.forEach((characteristic) async {
            if (characteristic.properties.write &&
                characteristic.uuid.toString() ==
                    BLE_CHARACTERISTIC_WRITE_UUID) {
              String passkey = "12345";
              if (data.result != null) {
                passkey = data.result!.passKey ?? "23";
              }

              String dataString =
                  '{"ssid": "$ssid", "password": "$password", "passkey":"$passkey","uuid":"6e400003-b5a3-f393-e0a9-e50e24dcca9e"}';
              // print(passkey);
              try {
                await characteristic.write(utf8.encode(dataString));
              } catch (e) {
                print(e.toString());
              }
            }

            if (characteristic.uuid.toString() == BLE_CHARACTERISTIC_ACK_UUID &&
                characteristic.properties.notify) {
              try {
                await Future.delayed(new Duration(seconds: 5), () async {});
                await characteristic.setNotifyValue(true);
                characteristic.value.listen((value) {
                  print(value);
                  if (value.length > 0) {
                    if (value[0] == 2) {
                      //widget.bluetoothService.disconnect();
                      _wifiStatus = WifiStatus.disconnected;
                      widget.setLoader(false);
                      widget.showPageLoader(context, false);
                      isclickable = true;
                      _wifistatusMessage = "Unable to connect to Wi-Fi,\nPlease check your credentials";
                      if(mounted){
                        setState(() {});
                      }
                      
                    } else if (value[0] == 4) {
                      _wifiStatus = WifiStatus.nointernet;
                      _wifistatusMessage = "Wi-Fi connected but no internet";
                      widget.setLoader(false);
                      widget.showPageLoader(context, false);
                      isclickable = true;
                      if(mounted){
                        setState(() {});
                      }
                    } else if (value[0] == 8) {
                      _wifiStatus = WifiStatus.mqttnotconnected;
                      _wifistatusMessage = "There was a problem communicating with the server";
                      widget.setLoader(false);
                      widget.showPageLoader(context, false);
                      isclickable = true;
                      if(mounted){
                        setState(() {});
                      }
                    } else if (value[0] == 128) {
                      _wifiStatus = WifiStatus.initial;
                      widget.setLoader(false);
                      widget.showPageLoader(context, false);
                      isclickable = true;
                      setState(() {
                      });
                      widget.onWifiConnected();
                    }

                    if(mounted){
                      if(value[0] == 2 || value[0] == 4 || value[0] == 8 || value[0] == 128)
                      {
                       /*  widget.setLoader(false);
                        widget.showPageLoader(context, false);
                        isclickable = true;
                        setState(() {}); */
                      }

                    }
                  }
                });
              } catch (e) {
                print(e.toString());
                await widget.bluetoothService.disconnect();
                isclickable = true;
                setState(() {});
              }
            }
          });
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget body() {
    return 
    _wifiStatus != WifiStatus.initial ? HubWifi((){
        print("hello");
        _wifiStatus = WifiStatus.initial;
        setState(() {});
      }, "Unable to connect your wifi, please check your credentials")
    : Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
      ),
      child: Column(
        children: <Widget>[
          Flexible(
            flex: 83,
            child: Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.049,
                    ),
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
                          '2',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.024,
                    ),
                    TextX.heading("Connect to Wi-Fi"),
                    /* SizedBox(
                      height: MediaQuery.of(context).size.height * 0.014,
                    ), */
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextX.subHeading(
                            "Select a wi-fi network to connect to"),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.039,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.white,
                        ),
                        //color: Colors.red,
                        child: Scrollbar(
                              isAlwaysShown: true,
                              child: ListView.builder(
                              itemCount: wifis.length,
                              itemBuilder: (context, i) {
                                return getWifiList(wifis[i], wifis.length);
                              }),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.009,
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            getAllWifiNetworks();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 0),
                            child: Text(
                              'Refresh',
                              style: TextStyle(color: Color(0XFF66ACA3), fontSize: 15),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.019,
                        ),
                        OutlinedButton(
                            onPressed: () async {
                              return customSsid();
                            },
                            child: Text('Manually Add', style: TextStyle(color: Color(0XFF54524E)),),
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0XFFF3F3F2)
                            ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          // Flexible(flex: 17, child: getWifiStatusView())
        ],
      ),
    );
  }

  bool showDefaultAppBar() {
    return false;
  }

  customSsid() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Enter network SSID', textAlign: TextAlign.center, style: kDBTitleStyle,),
            insetPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                _setState = stateSetter;
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Input.getTextField(
                      _ssidFieldController, _isObscure, "Password", getSecureIconButton()),
                );
              },
            ),
            actions: <Widget>[
              Container(
                //height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('Cancel', style: TextStyle(fontWeight: kDBButtonFontWeight, color: Colors.black),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                            backgroundColor: kDBButtonSecondaryColor
                        ),
                      ),
                    ),
                    SizedBox(width: 18,),
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('Submit', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                        onPressed: () {
                          // print("object");
                          if (_ssidFieldController.text != "") {
                            Navigator.pop(context);
                            _getWiFiPassword(
                                {"ssid": _ssidFieldController.text});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18,),
            ]);
      },
    );
  }

  showWifiErrorMessage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('No Wi-Fi Found', style: kDBTitleStyle,),
            insetPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                _setState = stateSetter;
                return Container(child: Text("Manually add your wifi or restart the app"),);
              },
            ),
            actions: <Widget>[
              Container(
                //height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('CANCEL', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('OK', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: kDBButtonSecondaryColor
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18,),
            ]);
      },
    );
  }



  getWifiStatusView() {
    if (_wifiStatus == WifiStatus.connecting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitRipple(
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              );
            },
          ),
          /* Text(
            'Connecting to Wi-Fi network...',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ) */
        ],
      );
    } else if (_wifiStatus == WifiStatus.connected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check_circle_outlined,
            color: Colors.green,
            size: 40,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            'Wi-Fi connection successful',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          )
        ],
      );
    } else if (_wifiStatus == WifiStatus.disconnected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            FontAwesomeIcons.crosshairs,
            color: Colors.red,
            size: 40,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            'Please give correct wifi credentials',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          )
        ],
      );
    } else if (_wifiStatus == WifiStatus.nointernet) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            FontAwesomeIcons.crosshairs,
            color: Colors.red,
            size: 40,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            'Connected but no internet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          )
        ],
      );
    } else if (_wifiStatus == WifiStatus.mqttnotconnected) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            FontAwesomeIcons.crosshairs,
            color: Colors.red,
            size: 40,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Text(
            'Sorry Mqtt connection failed',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          )
        ],
      );
    }
    return SizedBox.shrink();
  }

  getWifiList(Map<String, String> wifiNetwork, wifiCount) {
    return GestureDetector(
      onTap: () async {
        if(isclickable){
           _getWiFiPassword(wifiNetwork);
         }
        // _getWiFiPassword(wifiNetwork);
      },
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.062,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(wifiNetwork["ssid"]!),
                  Row(
                    children: <Widget>[
                      Image.asset(WifiSignalHelper().wifiSignal(noOfWifi: wifiCount), width: 16, height: 15.30,),
                      Icon(
                        Icons.chevron_right,
                        color: Color(0XFF3C3C43),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Divider(thickness: 1,)
        ],
      ),
    );
  }

  IconButton getPasswordIconButton() {
    return IconButton(
      icon: Icon(
        !_passwordObsecure ? Icons.visibility : Icons.visibility_off,
        color: Colors.black,
      ),
      onPressed: () {
        _setState(() {
          _passwordObsecure = !_passwordObsecure;
        });
      },
    );
  }

  GestureDetector getSecureIconButton() {
    return GestureDetector(
      child: Icon(
        !_isObscure ? Icons.visibility : Icons.visibility_off,
        color: Colors.black,
      ),
      onTap: () {
        _setState(() {
          _isObscure = !_isObscure;
        });
      },
    );
  }

  _getWiFiPassword(Map<String, String> wifiNetwork) {
    setState(() {
      //isclickable = false;
    });
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: Text('Enter password for\n ${wifiNetwork['ssid']}', textAlign: TextAlign.center, style: kDBTitleStyle,),
            insetPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
                _setState = stateSetter;
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Input.getTextField(_textFieldController,
                      _passwordObsecure, "password", getPasswordIconButton()),
                );
              },
            ),
            actions: <Widget>[
              Container(
                //height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: kDBButtonFontWeight),),
                        style: OutlinedButton.styleFrom(backgroundColor: kDBButtonSecondaryColor),
                        onPressed: () {
                          print("cancel");
                          Navigator.pop(context);
                          /* setState(() {
                            isclickable = true;
                          }); */
                        },
                      ),
                    ),
                    SizedBox(width: 18,),
                    SizedBox(
                      width: kDBButtonWidth,
                      height: kDBButtonHeight,
                      child: OutlinedButton(
                        child: Text('Submit', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                        onPressed: () {
                          if (_textFieldController.text != "") {
                            connectWifi(wifiNetwork["ssid"]!,
                                _textFieldController.text);
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18,),
            ]);
      },
    );
  }
}
