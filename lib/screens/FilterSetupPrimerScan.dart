import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/MessageType.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/dataAccess/NodeDataAccess.dart';
import 'package:whoosh/core/widgets/TextX.dart';
import 'package:whoosh/core/widgets/app_back_button.dart';

class FilterSetupPrimerScan extends BaseDeviceSetupPage {
  final Function(ScreenArguments) onFilterScanComplete;
  final VoidCallback onFilterScanSkip;
  const FilterSetupPrimerScan({Key? key, required this.onFilterScanComplete, required this.onFilterScanSkip})
      : super(key: key);

  @override
  _FilterSetupPrimerScanState createState() => _FilterSetupPrimerScanState();
}

class _FilterSetupPrimerScanState
    extends BaseDeviceSetupState<FilterSetupPrimerScan> with MainPage {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String currentQr = "";
  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkIfNodeIsAvailable() async {
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await NodeDataAccess.checkAvailable(rModel, result!.code!);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      controller!.resumeCamera();
      return;
    }

    widget.onFilterScanComplete(ScreenArguments(result!.code!));
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 45,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset("assets/images/QRcode_Woosh_Filter.png"),
                TextX.subHeading("Scan the QR code on the filter to connect"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 30),
                  child: OutlinedButton(
                    onPressed: (){
                      this.controller?.pauseCamera();
                      widget.onFilterScanSkip();
                    },
                    child: const Text('Skip'),
                  ),
                )
              ],
            ),
          ),
        ),
        Flexible(
          flex: 55,
          child: _buildQrView(context),
        )
      ],
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      print(scanData);
      setState(() {
        result = scanData;
      });
      if (result!.code != null) {
        if (result!.code!.length == 24) {
          _checkIfNodeIsAvailable();
          controller.pauseCamera();
        }
        else{
          print(result!.format.formatName);
          if(result!.code != currentQr &&  mounted){
            // widget.showSnakbar(context,400 , "Invalid QR of Length ${result!.code!.length} ${result!.format.formatName}", MessageType.Error);
            currentQr = result!.code!;
            widget.showalertDialouge(context, 400.toString(), "Invalid QR code");
          }
          
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
  
 

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
