import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/api/GoogleSignInApi.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/entities/User.dart';
import 'package:whoosh/core/entities/UserSignInWithGoogle.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/CardX.dart';
import 'package:whoosh/core/widgets/app_back_button.dart';
import 'package:whoosh/screens/AccessDenied.dart';

class SetupPrimer extends BasePage {
  //bool hasChangeWifi = false;
  bool hasChangeWifi = false;
  SetupPrimer({Key? key,this.hasChangeWifi:false}) : super(key: key);

  @override
  _SetupPrimerState createState() => _SetupPrimerState();
}

class _SetupPrimerState extends BaseState<SetupPrimer> with MasterPage {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool showLocationStep = false;
  String email = "";
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      
      chechBluetoothPermission();
      checkCameraPermission();
      
      widget.hasAllPersmission(context);
      getUserZipcode();
      Future.delayed(Duration(milliseconds: 100), () {
        getUserDetails();
      });
      checkIsUserAssociatedWithAnyHub();
      //getCameraPermission();
    });
  }

  

  checkIsUserAssociatedWithAnyHub() async {
    try {
      final rModel = EmptyBaseApiRequestModel();
      widget.showPageLoader(context, true);
      var res = await HubDataAccess.isUserAssociatedWithAHub(rModel);
      //print(res.result!.hasHub);
      print("hub reset");
      widget.showPageLoader(context, false);
      widget.processResponseData(context, res);
      bool hasPermission = await widget.hasAllPersmission(context);
      if(!hasPermission){
        return;
      }
      if (res.status == false) {
        return;
      }
      if (res.result!.hasHub == true && widget.hasChangeWifi==false) {
        return Navigator.of(context)
            .pushNamedAndRemoveUntil(routeHome, (route) => false);
      }
    } catch (e) {}
  }

  chechBluetoothPermission() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool ispermitted = pref.getBool("is_permitted") ?? false;
    print(ispermitted);
    if (!ispermitted) {
      _showMyDialog();
    }
  }

  checkCameraPermission() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool ispermitted = pref.getBool("is_camera_permitted") ?? false;
    if (!ispermitted) {
      _showCameraDialouge();
    }
  }

  Future<void> _showCameraDialouge() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Requesting Camera'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Camera is required to proceed further in the setup'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool("is_camera_permitted", true);
                Navigator.of(context).pop();
                getCameraPermission();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Requesting Location'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Location is required to proceed further in the setup'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

                blueToothPermission();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> getCameraPermission() async {
    var status = await Permission.camera.status;
    // prints PermissionStatus.granted
    if (status.isGranted) return true;
    final result = await Permission.camera.request();
    // print(await Permission.camera.status);
    if (result.isGranted) return true;
    if (result.isDenied) {
      showalertDialouge('Allow Woosh to Access Your Camera?',
          'We require access to your camera to scan and add filter(s). To give access, please go to settings');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("is_denied", true);
      widget.hasAllPersmission(context);
    }
    return false;
  }

  blueToothPermission() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* if (await Permission.location.request().isGranted) {
      print("granted");
      // Either the permission was already granted before or the user just granted it.
    } */
    var status = await Permission.location.status;
    // prints PermissionStatus.granted
    if (status.isGranted) return true;
    final result = await Permission.location.request();
    // print(await Permission.camera.status);
    if (result.isGranted) {
      prefs.setBool("is_permitted", true);
      return true;
    } else if (result.isDenied) {
      showalertDialouge('Allow Woosh to Access Your Location',
          'We require access to your location to search and pair Hub. To give access, please go to settings');
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool("is_denied", true);
      widget.hasAllPersmission(context);
    } else if (result.isPermanentlyDenied) {
      // The user opted to never again see the permission request dialog for this
      // app. The only way to change the permission's status now is to let the
      // user manually enable it in the system settings.
      openAppSettings();
    }
  }

  showalertDialouge(String heading, String body) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(heading),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(body),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
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

  Future<void> getUserZipcode() async {
    var user = await SessionHelper.getSession();

    if ((user is! UserSignInWithGoogle) && (user.user.zipcode == null || user.user.zipcode == "")) {
      setState(() {
        showLocationStep = true;
      });
    } else
      setState(() {
        showLocationStep = false;
      });
  }

  void getUserDetails()async{
    widget.showPageLoader(context, true);
    final rModel = EmptyBaseApiRequestModel();
    var user = await UserDataAccess.getUserDetails(rModel);
    email =  user.result?.user?.email ?? "";
    // zipcode =  user.result?.user?.zipcode ?? "";
    // print(email);
    if(mounted){
      widget.showPageLoader(context, false);
      setState(() {});
    }
    // print(zipcode);
  }

  @override
  body() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
//              AppBackButton(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.041,
              ),
              Text(
                'Let\'s get your smart filter set up',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.041,
              ),
              CardX.getStepCard("1", "Plug in Woosh Hub"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.019,
              ),
              CardX.getStepCard("2", "Connect your device"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.019,
              ),
              CardX.getStepCard("3", "Add Woosh filter"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.019,
              ),
              CardX.getStepCard("4", "Set your location"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.019,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Text(
                  "You are currently logged in as $email. Would you like to proceed or log out?",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54
                  ),
                ),
              ),
              // CardX.getStepCard("Step 5", "",isCustom: true),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Color(0XFF3F3F2))),
                      onPressed: () async {
                        var user = await SessionHelper.getSession();
                        /**
                         * Checking for google authenticated user
                         * if yes then do the logout process
                         */
                        if (user is UserSignInWithGoogle) {
                          await GoogleSignInApi.logout();
                        }
                        await SessionHelper.deleteSession();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            routeSignin, (route) => false);
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            routeDeviceSetupStart,
                            arguments:
                            ScreenArguments(showLocationStep));
                      },
                      child: Text('Continue'),
                    ),
                  ),
                  /* SizedBox(width: 10,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.logout_outlined,size: 30,),
                ) */
                ],
              ),
            )
            ],
          ),
        ),
      ),
    );
  }

  appBarType appBarStyle() {
    return appBarType.none;
  }

  bool vetoBack() {
    return true;
  }
}
