import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue/gen/flutterblue.pbenum.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/Db.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/dbmodel/BluetoothDbModel.dart';
import 'package:whoosh/screens/WifiSSID.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HubFound extends BaseDeviceSetupPage {
  final Function(ScreenArguments) onDeviceSelected;
  final Function(bool) setLoader;
  const HubFound(
      {Key? key, required this.onDeviceSelected, required this.setLoader})
      : super(key: key);
  @override
  _HubFoundState createState() => _HubFoundState();
}

class _HubFoundState extends BaseDeviceSetupState<HubFound> with MainPage {
  
  List<BluetoothDevice> devicesList = [];
  List<Map<String, Object?>> pairedDevices = [];
  late DbLite dbLite = DbLite();
  var _connectedDevice;
  int _selectedIndex = 0;
  bool isHubConnected = false;
  bool isclickable = false;
  int refreshcount = 0;
  bool rerender = false;
  String hubConfigMessage =
      "Hub Configuration Under Process. Do not click 'Back'. Stay Put for Couple of Minutes.";
  @override
  void initState() {
    super.initState();
    shouldShowDialouge();
  }

  refreshUntillData() async {
    widget.showPageLoader(context, true, text: hubConfigMessage);
    widget.setLoader(true);
    if (devicesList.length == 0 && refreshcount < 6) {
      refreshDevice();
      // print("force refresh");
      await Future.delayed(const Duration(milliseconds: 2000), () {});
      refreshcount = refreshcount + 1;
      refreshUntillData();
    } else {
      widget.showPageLoader(context, false);
      widget.setLoader(false);
      //_showMyDialog(title: "Not found",text: " Sorry no device found ");
    }
  }

  shouldShowDialouge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!(await Permission.location.request().isGranted)) {
      // print("not granted");
      
      widget.setLoader(true);
      prefs.setBool("is_denied", true);
      widget.hasAllPersmission(context);
      //_showMyDialog();
      return;
      // Either the permission was already granted before or the user just granted it.
    }
    else{
      await prefs.setBool("is_permitted",true);
    }
    bool ispermitted = prefs.getBool("is_permitted") ?? false;
    widget.showPageLoader(context, true, text: hubConfigMessage);
    widget.setLoader(true);
    if (ispermitted) {
      widget.showPageLoader(context, true, text: hubConfigMessage);
      refreshDevice();
      widget.showPageLoader(context, true, text: hubConfigMessage);
      await Future.delayed(const Duration(milliseconds: 2000), () {});

      //refreshDevice();
      setState(() {
        isclickable = true;
      });
      
      // refreshUntillData();
    } else {
      Future.delayed(Duration(milliseconds: 100), () {
        _showMyDialog();
      });
    }
  }

  Future<void> _showMyDialog(
      {String title: 'Allow Woosh to Access Your Location',
      String text:
          "We require access to your location to search and pair Hub. To give access, please go to settings"}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: const Text('Ok'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void refreshDevice({bool is_manual_refresh = false}) async {
    final FlutterBlue flutterBlue = FlutterBlue.instance;
    // print(_connectedDevice);
     print("isrefresh");
    if (_connectedDevice != null) {
      print("disconnected");
      await _connectedDevice.disconnect();
      _connectedDevice = null;
      isHubConnected = false;
    }
    // print(is_manual_refresh);
    // print("is_manual_refresh");
    bool isOn = await flutterBlue.isOn;
    if (isOn) {
      devicesList = [];
      //widget.showPageLoader(context, true);
      // flutterBlue.stopScan();
      var scanStatus = await Permission.bluetoothScan.request().isGranted;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.request().isGranted;
      if (scanStatus && bluetoothConnectStatus) {
        flutterBlue.startScan();
        flutterBlue.scanResults.listen((List<ScanResult> results) {
          // print(results);
          for (ScanResult result in results) {
            // _addDeviceTolist(result.device);
            if (!devicesList.contains(result.device)) {
              if (checkIsAlreadyAvailable(result.device)) {
                if (result.device.name.startsWith("WOOSH")) {
                  //await device.disconnect();
                  print(result.device);
                  devicesList.add(result.device);
                  if (mounted) {
                    setState(() {});
                  }
                }

                // }
              }
            }
          }
        }, onError: (err) {
          print(err.toString());
          print("error");
        });
        flutterBlue.stopScan();
      }
      if (mounted) {
        if (is_manual_refresh) {
          widget.showPageLoader(context, false);
          widget.setLoader(false);
        }

        setState(() {});
      }
      if(!is_manual_refresh && rerender == false){
        await Future.delayed(const Duration(milliseconds: 3000), () {});
        print("in_data");
        rerender = true;
        //refreshDevice();
      }
      //await Future.delayed(const Duration(milliseconds: 2000), () {});
      widget.showPageLoader(context, false);
      widget.setLoader(false);
    } else {
      AlertDialog alert = AlertDialog(
        content: Container(
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Your bluetooth is not active",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Text("Please active your bluetooth")
            ],
          ),
        ),
        actions: [],
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop(true);
          });
          return alert;
        },
      );
    }
    // blueToothCheckAndShowDevices(is_manual_refresh);
  }

/*   setupSocket(){
    
    IO.Socket socket = IO.io('http://3.17.139.144:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    }).connect();
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('NOTIFICATION_SEND', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  } */

  void getAllBlueToothDevices() async {
    await dbLite.initDatabase();
    pairedDevices = await dbLite.getAllBlueToothDevices();
    setState(() {});
  }

  void _addDeviceTolist(final BluetoothDevice device) async {
    //if(device.disconnect())
    if (!devicesList.contains(device)) {
      if (checkIsAlreadyAvailable(device)) {
        if (device.name.startsWith("WOOSH")) {
          //await device.disconnect();
          devicesList.add(device);
        }

        // }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  Container _buildListViewOfDevices(devicesList) {
    List<Widget> containers = [];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Column(
          children: [
            Container(
              child: GestureDetector(
                  onTap: () async{
                    try {
                        if (!isclickable) {
                          return;
                        }
                        if (!mounted) {
                          return;
                        }
                        setState(() {
                          isHubConnected = true;
                        });
                        widget.setLoader(true);
                        widget.showPageLoader(context, true,
                            text:
                                "Pairing the Hub with Your App. Hub Configuration Started. Yay!");
                        await Future.delayed(
                            const Duration(milliseconds: 1000), () {});
                        await device.disconnect();
                        await Future.delayed(
                            const Duration(milliseconds: 1000), () {});
                        Timer(Duration(microseconds: 100), () {
                          // print(" This line is execute after 5 seconds");
                        });
                        await device.connect(autoConnect: false);
                        widget.setLoader(false);
                        widget.showPageLoader(context, false);
                       
                        if (mounted) {
                          setState(() {
                            isHubConnected = false;
                          });
                        }

                        widget.onDeviceSelected(ScreenArguments(device));
                       
                      } catch (e) {
                      } finally {}
                      if (mounted) {
                        _connectedDevice = device;
                        setState(() {
                          // getAllBlueToothDevices();
                        });
                      }
                  },
                  child: Container(
                  padding:
                      EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 15),
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(device.name == ''
                              ? '(unknown device)'
                              : device.name),
                          _connectedDevice != null && device == _connectedDevice
                              ? SizedBox(
                                  height: 2,
                                )
                              : SizedBox.shrink(),
                          //_connectedDevice!=null && device == _connectedDevice ? Text("Connected") : SizedBox.shrink()
                        ],
                      ),
                      ImageIcon(AssetImage('assets/images/arrow.png'),
                          size: 20,
                          color: device == _connectedDevice
                              ? Colors.black
                              : Colors.grey)
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            ),
          ],
        ),
      );
    }
    return Container(
      child: ListView(
        children: <Widget>[
          ...containers,
        ],
      ),
    );
  }

  _buildPairedDevices() {
    List<Widget> containers = [];
    for (var device in pairedDevices) {
      containers.add(
        Column(
          children: [
            Container(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                    color: device == _connectedDevice
                        ? Colors.grey[100]
                        : Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(device["name"].toString()),
                        _connectedDevice != null &&
                                device["name"] == _connectedDevice.name
                            ? SizedBox(
                                height: 2,
                              )
                            : SizedBox.shrink(),
                        _connectedDevice != null &&
                                device["name"] == _connectedDevice.name
                            ? Text("Connected")
                            : SizedBox.shrink()
                      ],
                    ),
                    ImageIcon(AssetImage('assets/images/arrow.png'),
                        size: 20,
                        color: _connectedDevice != null &&
                                device["name"] == _connectedDevice.name
                            ? Colors.black
                            : Colors.grey)
                  ],
                ),
              ),
            ),
            Container(
              height: 1,
              color: Colors.black12,
            )
          ],
        ),
      );
    }
    return Container(
      child: ListView(
        children: <Widget>[
          ...containers,
        ],
      ),
    );
  }

  blueToothCheckAndShowDevices(bool is_manual_refresh) async {
    
  }

  bool checkIsAlreadyAvailable(BluetoothDevice bluetoothDevice) {
    for (var device in devicesList) {
      if (device.name == bluetoothDevice.name) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 4,
          ),
          GestureDetector(
            //onTap: widget.onDeviceSelected,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Color(0xffEBEBEA), shape: BoxShape.circle),
              child: Center(
                  child: Text(
                "1",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
            ),
          ),
          ExpansionPanelList(
            elevation: 0.0,
            expansionCallback: (int index, bool status) {
              setState(() {
                if (!status) {
                  _selectedIndex = index;
                } else {
                  _selectedIndex = -1;
                }
              });
            },
            children: [
              ExpansionPanel(
                backgroundColor: Color.fromRGBO(243, 244, 239, 1),
                isExpanded: _selectedIndex == 0 ? true : false,
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Available Hub",
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        _selectedIndex == 0
                            ? SizedBox(
                                height: 5,
                              )
                            : SizedBox.shrink(),
                        _selectedIndex == 0
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Look for Available Hub",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                      onTap: () async {
                                        // print("hghghghghg");
                                        widget.showPageLoader(context, true,
                                            text: hubConfigMessage);
                                        widget.setLoader(true);
                                        await Future.delayed(
                                            const Duration(milliseconds: 2000),
                                            () {});
                                        refreshDevice(is_manual_refresh: true);
                                      },
                                      child: Icon(
                                        Icons.refresh,
                                        color: Theme.of(context).primaryColor,
                                      )),
                                ],
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  );
                },
                body: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getParentContainer(_buildListViewOfDevices(devicesList))
                    ],
                  ),
                ),
              ),
              /* ExpansionPanel(
                backgroundColor: Color.fromRGBO(243, 244, 239, 1),
                isExpanded: _selectedIndex == 1 ? true : false,
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Paired Devices",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: getParentContainer(_buildPairedDevices()),
              ), */
            ],
          ),
          isHubConnected
              ? Column(
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
                    Text(
                      'Connect to Hub...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    )
                  ],
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  getParentContainer(Container child) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
                minHeight: 100,
                maxHeight: (MediaQuery.of(context).size.height / 4)),
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: child,
          )
        ],
      ),
    );
  }
}