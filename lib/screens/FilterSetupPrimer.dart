import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class FilterSetupPrimer extends BaseDeviceSetupPage {
  final VoidCallback onFilterScan;
  final VoidCallback onFilterScanSkip;
  const FilterSetupPrimer(
      {Key? key, required this.onFilterScan, required this.onFilterScanSkip})
      : super(key: key);

  @override
  _FilterSetupPrimerState createState() => _FilterSetupPrimerState();
}

class _FilterSetupPrimerState extends BaseDeviceSetupState<FilterSetupPrimer>
    with MainPage {
  Future<bool> getCameraPermission() async {
    var status = await Permission.camera.status;
    print(await Permission.camera.status); // prints PermissionStatus.granted
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    print(await Permission.camera.status);
    if (result.isGranted) return true;
    return false;
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
        vertical: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Column(
        children: [
          Flexible(
            flex: 45,
            child: Column(
              children: <Widget>[
                Image.asset("assets/images/QRcode_Woosh_Filter.png", fit: BoxFit.contain, height: 230,),
              ],
            ),
          ),
          Flexible(
            flex: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                TextX.heading("Set up your filter"),
                TextX.subHeading("Scan the QR code on the filter to connect"),
              ],
            ),
          ),
          Flexible(
            flex: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    bool isCameraPermissionGiven = await getCameraPermission();
                    if (isCameraPermissionGiven) {
                      widget.onFilterScan();
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Camera required to scan QR code'),
                      ),
                    );
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool("is_denied", true);
                    widget.hasAllPersmission(context);
                    return;
                  },
                  child: const Text('Scan'),
                ),
                OutlinedButton(
                  onPressed: widget.onFilterScanSkip,
                  child: const Text('Skip', style: TextStyle(color: Color(0XFF54524E), fontSize: 17),),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0XFFF3F3F2)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
