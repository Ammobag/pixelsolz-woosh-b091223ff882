import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/constants/dialog_box_constant.dart';
import 'package:whoosh/core/widgets/LoaderW.dart';
import 'package:whoosh/core/widgets/small_logo.dart';
import 'package:whoosh/screens/AccessDenied.dart';
import 'package:whoosh/screens/SetupPrimer.dart';
import 'BaseResponse.dart';
import 'MessageType.dart';
import 'dataAccess/NotificationDataAccess.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
enum appBarType {
  none,
  minimal,
  full,
}

mixin MasterPage<Page extends BasePage> on BaseState<Page> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: vetoBack() ? _isExitDesired : null,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset(),
        appBar: appBarStyle() == appBarType.minimal
            ? AppBar(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
                  onPressed: _onExitPressed,
                ),
                backgroundColor: Colors.white.withOpacity(0),
                elevation: 0.0,
              )
            : appBarStyle() == appBarType.full
                ? AppBar(
                    backgroundColor: Colors.white.withOpacity(0),
                    elevation: 0.0,
                    title: SmallLogo(),
                    centerTitle: true,
                  )
                : null,
        body: body(),
        bottomNavigationBar: bottomNavigationBar() ?? null,
      ),
    );
  }

  Widget body();
  List<Widget> actions() {
    return [];
  }

  appBarType appBarStyle() {
    return appBarType.none;
  }

  bool vetoBack() {
    return false;
  }

  bool resizeToAvoidBottomInset() {
    return false;
  }

  BottomNavigationBar? bottomNavigationBar() {
    return null;
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();

    if (isConfirmed && mounted) {
      _exitSetup();
    }
  }

  Future<bool> _isExitDesired() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                insetPadding: const EdgeInsets.all(15),
                title: const Text('Are you sure you want to exit?', textAlign: TextAlign.center, style: kDBTitleStyle,),
                titlePadding: const EdgeInsets.fromLTRB(30, 35, 30, 5),
                content: Builder(
                  builder: (context) {
                    double width = MediaQuery.of(context).size.width;

                    return Container(
                      height: 1,
                      width: width,
                    );
                  },
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Container(
                        width: kDBButtonWidth,
                        height: kDBButtonHeight,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No', style: TextStyle(fontWeight: kDBButtonFontWeight),),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        width: kDBButtonWidth,
                        height: kDBButtonHeight,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0XFFF3F3F2),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Yes', style: TextStyle(color: Colors.black, fontWeight: kDBButtonFontWeight),),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                ],
              );
            }) ??
        false;
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }
}

abstract class BaseState<Page extends BasePage> extends State<Page> {}

abstract class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  static OverlayEntry? entry;
  void showPageLoader(BuildContext context, bool showProgress,
      {String text = ""}) {
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
    if (text != "") {
      child = LoaderW.getLoaderDesign(text);
    }
    entry = OverlayEntry(builder: (context) => child);
    Overlay.of(context)?.insert(entry!);

    // remove the entry if not removed within 1 min
    if (text == "") {
      Future.delayed(const Duration(seconds: 60)).whenComplete(() {
        if (entry != null) {
          entry?.remove();
          entry = null;
        }
      });
    }

    if (text != "") {
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

  void processResponseData(BuildContext context, BaseResponse resModel,
      [bool showIsSucessMessage = true,Function? callback]) {
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
    showalertDialouge(context, tempCode.toString(), tempMessage??"",callBack: callback);
  }

  void showSuccessMessage(BuildContext context, String? tempMessage,{Function? callBack}) {
    // String? tempMessage;
    

    // showSnakbar(context, tempCode, tempMessage, tempMesageType);
    showalertDialouge(context, "Success", tempMessage ?? "",callBack:callBack );
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

  showalertDialouge(BuildContext context,String heading,String body,{Function? callBack}){
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title:  Text(body, style: kDBTitleStyle, textAlign: TextAlign.center,),
            content: Builder(
              builder: (BuildContext context) {
                double width = MediaQuery.of(context).size.width;
                return Container(
                  height: 30,
                  width: width + 100,
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

  Future<bool> hasAllPersmission(BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool isDenied = pref.getBool("is_denied") ?? false;
    if (isDenied) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccessDenied()),
      );
      print("permission denied");
      return false;
    }else{
      return true;
    }
  }


}
