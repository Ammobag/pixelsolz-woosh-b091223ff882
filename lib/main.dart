import 'package:flutter/material.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/route/SlideLeftRoute.dart';
import 'package:whoosh/screens/ForgetPassword.dart';
import 'package:whoosh/screens/HomeScreen/HomeScreen.dart';
import 'package:whoosh/screens/HubWifi.dart';
import 'package:whoosh/screens/Register.dart';
import 'package:whoosh/screens/SetupFlow.dart';
import 'package:whoosh/screens/SetupPrimer.dart';
import 'package:whoosh/screens/SignIn.dart';
import 'package:whoosh/screens/Welcome.dart';
import 'package:flutter/services.dart';
import 'core/ScreenArguments.dart';
import 'core/route/Routes.dart';
import 'screens/AddFilterFlow.dart';

void main() async{
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isUserAssociatedWithHub = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () async {
      getSession();
    });
  }

  getSession() async {
    var user = await SessionHelper.getSession();
    if (user != null) {
      setState(() {
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  Widget routingManager() {
    if (isLoggedIn) {
      return SetupPrimer();
    } else
      return SignIn();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Woosh',
      theme: ThemeData(
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            primary: Color(0xFFFFFFFF),
            backgroundColor: Color(0xFF0D5C8E),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            primary: Color(0xFF54524E),
            backgroundColor: Color(0xFFFFFFFF),
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        scaffoldBackgroundColor: Color(0xFFf3f3f2),
        primarySwatch: Colors.teal,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black
          )
        ),
      ),
      home:routingManager(),
      onGenerateRoute: (settings) {
        final args = settings.arguments as ScreenArguments?;
        late Widget page;
        if (settings.name == routeWelcome) {
          page = const Welcome();
        } else if (settings.name == routeSignin) {
          page = const SignIn();
        } else if (settings.name == forgetPassword) {
          page = ForgetPassword();
        } else if (settings.name == routeRegister) {
          page = const Register();
        } else if (settings.name == routeSetupPrimer) {
          page = SetupPrimer();
        } else if (settings.name == routeHome) {
          page = const HomeScreen();
        } else if (settings.name!.startsWith(routePrefixDeviceSetup)) {
          final subRoute =
              settings.name!.substring(routePrefixDeviceSetup.length);
          page = SetupFlow(
            setupPageRoute: subRoute,
            showLocationStep: args!.payload as bool,
          );
        } else if (settings.name!.startsWith(routePrefixAddFilter)) {
          final subRoute =
              settings.name!.substring(routePrefixAddFilter.length);
          page = AddFilterFlow(addFilterRoute: subRoute);
        } else {
          throw Exception('Unknown route: ${settings.name}');
        }

        return SlideLeftRoute(page: page, settings: settings);
      },
      debugShowCheckedModeBanner: true,
    );
  }
}
