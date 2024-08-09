import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/constants/dialog_box_constant.dart';
import 'package:whoosh/core/widgets/LoaderW.dart';
import 'package:whoosh/screens/AccessDenied.dart';
import 'package:whoosh/screens/SetupPrimer.dart';
import 'BaseResponse.dart';
import 'MessageType.dart';
import 'dataAccess/NotificationDataAccess.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
mixin MainPage<Page extends BaseDeviceSetupPage> on BaseDeviceSetupState<Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: body(),
      ),
    );
  }

  Widget body();
  List<Widget> actions() {
    return [];
  }
}

abstract class BaseDeviceSetupState<Page extends BaseDeviceSetupPage>
    extends State<Page> {}

abstract class BaseDeviceSetupPage extends StatefulWidget {
  const BaseDeviceSetupPage({Key? key}) : super(key: key);

  static OverlayEntry? entry;
  void showPageLoader(BuildContext context, bool showProgress,{String text = ""}) {
    if (entry != null) {
      entry?.remove();
      entry = null;
    }
    if (!showProgress) {
      return;
    }

    var child = Center(child: 
          SpinKitFadingCircle(
              size: 50,
              color: Color(0xFF0D5C8E),
          )
      // CircularProgressIndicator()
    );
    if(text != ""){
      child = LoaderW.getLoaderDesign(text);
    }
    
    entry = OverlayEntry(builder: (context) => child);
    Overlay.of(context)?.insert(entry!);

    // remove the entry if not removed within 1 min
    if(text == "")
    {
      Future.delayed(const Duration(seconds: 60)).whenComplete(() {
      if (entry != null) {
          entry?.remove();
          entry = null;
        }
      });
    }
    if(text != "")
    {
      /* Future.delayed(const Duration(seconds: 180)).whenComplete(() {
        if (entry != null) {
          entry?.remove();
          entry = null;
        }
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text('We are stuck'),
                actions: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TextButton(
                            child: Text('OK'),
                            onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SetupPrimer()),
                                );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ]);
          },
        );
      }); */
    }
  }

  void showPageLoaderWithLogo(BuildContext context, bool showProgress,{String text = ""}) {
    print(text);
    print("hello");
    if (entry != null) {
      entry?.remove();
      entry = null;
    }
    if (!showProgress) {
      return;
    }

    var child = Center(child: Column(
      children: [
        // Image.asset('assets/images/logo.png'),
        // CircularProgressIndicator()
        SpinKitFadingCircle(
              size: 50,
              color: Color(0xFF0D5C8E),
        )
      ],
    ));
    if(text != ""){
      child = LoaderW.getLoaderDesignWithBackGround(text,context);
    }
    
    entry = OverlayEntry(builder: (context) => child);
    Overlay.of(context)?.insert(entry!);

    // remove the entry if not removed within 1 min
    if(text == "")
    {
      Future.delayed(const Duration(seconds: 60)).whenComplete(() {
      if (entry != null) {
          entry?.remove();
          entry = null;
        }
      });
    }
    
  }

  void processResponseData(BuildContext context, BaseResponse resModel,
      [bool showIsSucessMessage = true]) {
    String? tempMessage;
    var tempMesageType;
    int? tempCode;
    if (resModel.status != null) {
      if (resModel.status == true) return;
      tempMessage = resModel.message;
      tempMesageType = MessageType.Error;
      tempCode = resModel.code;
    }

    // showSnakbar(context, tempCode, tempMessage, tempMesageType);
    showalertDialouge(context,tempCode.toString(),tempMessage ?? "");
  }

  void showSnakbar(
      BuildContext context, int? code, String? message, MessageType type,
      [int durationInSecond = 3]) {
    var backGroundColor = Colors.red;

    switch (type) {
      case MessageType.Success:
        backGroundColor = Colors.green;
        break;
      case MessageType.Error:
      default:
        backGroundColor = Colors.red;
        break;
    }
    final snackBar = SnackBar(
      content: Text('${code.toString()} , $message'),
      duration: Duration(seconds: durationInSecond),
      backgroundColor: backGroundColor,
      behavior: SnackBarBehavior.fixed,
    );
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showalertDialouge(BuildContext context,String heading,String body){
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title:  Text(body, style: kDBTitleStyle, textAlign: TextAlign.center,),
            insetPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            content: Builder(
              builder: (BuildContext context) {
                double width = MediaQuery.of(context).size.width;
                return Container(
                  height: 30,
                  width: width - 14,
                  child: Text('Please try again', textAlign: TextAlign.center,),
                );
              },
            ),
            actions: <Widget>[
              Center(
                child: SizedBox(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    onPressed: () async{
                      Navigator.of(context).pop();
                    },
                    child: const Text('OK', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                  ),
                ),
              ),
              SizedBox(height: 16,),
            ],
          );
        },
      );
  }

  hasAllPersmission(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDenied = pref.getBool("is_denied") ?? false;
    if (isDenied) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccessDenied()),
      );
      print("permission denied");
    }
  }

  void addNotification(
    BuildContext context,
    String message,
  ) async {
    final rModel = NotificationCreateRequestModel();
    rModel.message = message;
    var res = await NotificationDataAccess.create(rModel);
    processResponseData(context, res);
    if (res.status == false) {
      return;
    }
  }
}
