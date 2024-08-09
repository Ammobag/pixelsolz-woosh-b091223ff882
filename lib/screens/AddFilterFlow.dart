import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/ScreenArguments.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/route/SlideLeftRoute.dart';
import 'FilterName.dart';
import 'FilterSetupPrimerScan.dart';

class AddFilterFlow extends BasePage {
  static _AddFilterFlowState of(BuildContext context) {
    return context.findAncestorStateOfType<_AddFilterFlowState>()!;
  }

  final String addFilterRoute;

  const AddFilterFlow({Key? key, required this.addFilterRoute})
      : super(key: key);

  @override
  _AddFilterFlowState createState() => _AddFilterFlowState();
}

class _AddFilterFlowState extends BaseState<AddFilterFlow> with MasterPage {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _onFilterScanComplete(ScreenArguments args) {
    _navigatorKey.currentState!
        .pushNamed(routeDeviceSetupFilterNamePage, arguments: args);
  }

  void _onFilterSetUp() {
    Navigator.of(context).pushNamedAndRemoveUntil(routeHome, (route) => false);
  }

  void _onFilterScanSkip() {
    Navigator.pop(context);
    //_navigatorKey.currentState!.pushNamed(routeDeviceSetupSetLocationPage);
  }

  @override
  Widget body() {
    return WillPopScope(
      onWillPop: _isExitDesired,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
            onPressed: _onExitPressed,
          ),
          backgroundColor: Colors.white.withOpacity(0),
          elevation: 0.0,
        ),
        body: Navigator(
          key: _navigatorKey,
          initialRoute: widget.addFilterRoute,
          onGenerateRoute: _onGenerateRoute,
        ),
      ),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as ScreenArguments?;
    late Widget page;
    switch (settings.name) {
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
    }

    return SlideLeftRoute(page: page, settings: settings);
  }

  Future<void> _onExitPressed() async {
    final isConfirmed = await _isExitDesired();

    if (isConfirmed && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _isExitDesired() async {
    if (_navigatorKey.currentState!.canPop()) {
      _navigatorKey.currentState!.pop();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
