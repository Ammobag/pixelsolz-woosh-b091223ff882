import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/route/SlideLeftRoute.dart';
import 'package:whoosh/screens/AdditionalFilterSetupPrimer.dart';
import 'package:whoosh/screens/FilterName.dart';
import 'package:whoosh/screens/FilterSetupPrimer.dart';
import 'package:whoosh/screens/FilterSetupPrimerScan.dart';
import 'package:whoosh/screens/HubDiscovery.dart';
import 'package:whoosh/screens/HubFound_new_changes.dart';
import 'package:whoosh/screens/WifiCredentials.dart';
import 'package:whoosh/screens/WifiSSID.dart';

import 'SetLocation.dart';

class SetupFlow extends BasePage {
  final bool showLocationStep;

  static _SetupFlowState of(BuildContext context) {
    return context.findAncestorStateOfType<_SetupFlowState>()!;
  }

  const SetupFlow({
    Key? key,
    required this.setupPageRoute,
    required this.showLocationStep,
  }) : super(key: key);

  final String setupPageRoute;

  @override
  _SetupFlowState createState() => _SetupFlowState();
}

class _SetupFlowState extends BaseState<SetupFlow> with MasterPage {
  final _navigatorKey = GlobalKey<NavigatorState>();
  int step = 1;
  bool hasLoaded = false;
  bool _isFilterScan = false;
  ScreenArguments newArgs = new ScreenArguments(null);
  @override
  void initState() {
    super.initState();
  }

  void updateCurrentStep(int newStep) {
    if (!mounted) {
      return;
    }
    setState(() {
      step = newStep;
    });
  }

  void _onDiscoveryComplete() {
    // _navigatorKey.currentState!
    //     .pushNamed(routeDeviceSetupFilterSetupPrimerPage);
    updateCurrentStep(2);
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupHubFoundPage, arguments: null);
  }

  void _onDeviceSelected(ScreenArguments args) {
    newArgs = args;
    updateCurrentStep(3);
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupWifiSsidPage, arguments: args);
    //TODO: Add wifi credentials page
    //_navigatorKey.currentState!
    //  .pushNamed(routeDeviceSetupFilterSetupPrimerPage,arguments: bluetoothDevice);
  }

  void _onWifiSelected() {
    _navigatorKey.currentState!.pushNamed(routeDeviceSetupWifiCredentialsPage);
  }

  void _onWifiConnected() {
    //widget.addNotification(context, "Hub Connected to Wifi");
    updateCurrentStep(4);
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupFilterSetupPrimerPage);
  }

  void _onPasswordGiven(ScreenArguments args) {
    _navigatorKey.currentState!.pushReplacementNamed(
      routeDeviceSetupWifiSsidPage,
      arguments: args,
    );
  }

  void _onFilterScan() {
    setState(() {
      _isFilterScan = true;
    });
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupFilterSetupPrimerScanPage);
  }

  void _onFilterScanSkip() {
    _navigatorKey.currentState!.pushNamed(routeDeviceSetupSetLocationPage);
    updateCurrentStep(4);
  }

  void _onFilterScanComplete(ScreenArguments args) {
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupFilterNamePage, arguments: args);
  }

  void _onFilterSetUp() {
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupAdditionalFilterSetupPrimerPage);
  }

  void _onAdditionalFilterSetUp() {
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupFilterSetupPrimerPage);
  }

  void _onAdditionalFilterSetUpDone() {
    if (widget.showLocationStep) {
      _navigatorKey.currentState!.pushNamed(routeDeviceSetupSetLocationPage);
    } else {
      _exitSetup();
      return;
    }
    updateCurrentStep(4);
  }

  void _exitSetup() {
    Navigator.of(context).pushNamedAndRemoveUntil(routeHome, (route) => false);
  }

  Future<bool> checkBack() async{
    print(step);
    return false;
  }

  @override
  Widget body() {
    return WillPopScope(
      onWillPop:  checkBack,
      //() async => false,
      child: Scaffold(
        appBar: AppBar(
          //step != 4
          //step > 2 &&
          leading: (step != 4 && !hasLoaded) || _isFilterScan ? IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: _onExitPressed,
          ) : SizedBox.shrink(),
          backgroundColor: Colors.white.withOpacity(0),
          elevation: 0.0,
          bottom: PreferredSize(
            preferredSize: Size(1, 2),
            child: step != 4 ? StepProgressIndicator(
              padding: 10,
              totalSteps: widget.showLocationStep == true ? 4 : 3,
              currentStep: step,
              selectedColor: Color(0xff3DCB1F),
            ) : SizedBox.shrink(),
          ),
        ),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: widget.setupPageRoute,
          onGenerateRoute: _onGenerateRoute,
        ),
        
        /* Navigator(
          key: _navigatorKey,
          initialRoute: widget.setupPageRoute,
          onGenerateRoute: _onGenerateRoute,
        ), */
      ),
    );
  }

  Future<void> _onExitPressed() async {
    if(step == 2){
      _isLeaveApp();
      return;
    }
    if ( _isFilterScan ) {

      setState(() {
        _isFilterScan = false;
      });
      _navigatorKey.currentState!
          .pushNamed(routeDeviceSetupFilterSetupPrimerPage);
      return;
    }
    print("current step");
    print(step);
    print("current step");
    widget.showPageLoader(context, true);
    setLoader(true);
    if (newArgs.payload != null) {
      // print(newArgs.payload);
      
      newArgs.payload.disconnect().then((data) async{
        final isConfirmed = await _isExitDesired();

        updateCurrentStep(step - 1);
        widget.showPageLoader(context, false);
        setLoader(false);
        if (isConfirmed && mounted) {
          Navigator.of(context).pop();
        }
      });
      newArgs = ScreenArguments(null);
      //print(d);
      
    }
    else{
      final isConfirmed = await _isExitDesired();
      widget.showPageLoader(context, false);
      setLoader(false);
      updateCurrentStep(step - 1);
      if (isConfirmed && mounted) {
        Navigator.of(context).pop();
      }
    }

    
    

    /* if(step==2){
      _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupHubFoundPage, arguments: null);
    } */
    //_onDiscoveryComplete

    
  }

    Future<bool> _isLeaveApp() async    {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: const Text('Are you sure you want to exit?', textAlign: TextAlign.center,),
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
                        width: 120,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('No'),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Container(
                        width: 120,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Color(0XFFF3F3F2),
                          ),
                          onPressed: () {
                            if (Platform.isAndroid) {
                              SystemNavigator.pop();
                              // exit(0);
                            } else if (Platform.isIOS) {
                              exit(0);
                            }
                          },
                          child: const Text('Yes', style: TextStyle(color: Colors.black),),
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

  Future<bool> _isExitDesired() async {
    await Future.delayed(const Duration(milliseconds: 1000), () {});
    if (_navigatorKey.currentState!.canPop()) {
      _navigatorKey.currentState!.pop();

      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  setLoader(bool loaded){
    hasLoaded = loaded;
    if(mounted){
      setState(() {});
    }
  }

  Route _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as ScreenArguments?;
    late Widget page;
    switch (settings.name) {
      case routeDeviceSetupStartPage:
        page = HubDiscovery(
          onWaitComplete: _onDiscoveryComplete,
        );
        break;
      case routeDeviceSetupHubFoundPage:
        page = HubFound(
          onDeviceSelected: _onDeviceSelected,
          setLoader:setLoader
        );
        break;
      case routeDeviceSetupWifiSsidPage:
        print("object");
        page = WiFiSSID(
            onWifiConnected: _onWifiConnected, bluetoothService: args!.payload,
            setLoader:setLoader
            );
        break;
      case routeDeviceSetupWifiCredentialsPage:
        page = WifiCredentials(
          onPasswordGiven: _onPasswordGiven,
        );
        break;
      case routeDeviceSetupFilterSetupPrimerPage:
        page = FilterSetupPrimer(
          onFilterScan: _onFilterScan,
          onFilterScanSkip: _onFilterScanSkip,
        );
        break;
      case routeDeviceSetupFilterSetupPrimerScanPage:
        page = FilterSetupPrimerScan(
          onFilterScanComplete: _onFilterScanComplete,
          onFilterScanSkip: _onFilterScanSkip,
        );
        break;
      case routeDeviceSetupFilterNamePage:
        page = FilterName(
          onFilterSetUp: _onFilterSetUp,
          deviceId: args!.payload as String,
        );
        break;
      case routeDeviceSetupAdditionalFilterSetupPrimerPage:
        page = AdditionalFilterSetupPrimer(
          onAdditionalFilterSetUp: _onAdditionalFilterSetUp,
          onAdditionalFilterSetUpDone: _onAdditionalFilterSetUpDone,
        );
        break;
      case routeDeviceSetupSetLocationPage:
        page = SetLocation(
          onSetLocation: _exitSetup,
        );
        break;
    }

    return SlideLeftRoute(page: page, settings: settings);
  }
}
