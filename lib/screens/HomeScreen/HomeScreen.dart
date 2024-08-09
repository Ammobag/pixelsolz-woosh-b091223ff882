import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:whoosh/core/BaseApi.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';

import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/dataAccess/ForecastDataAccess.dart';
import 'package:whoosh/core/dataAccess/NotificationDataAccess.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/entities/Forecast.dart';
import 'package:whoosh/core/entities/Notification.dart';

import 'Dashboard.dart';
import 'Notifications.dart';
import 'Profile.dart';
import 'Settings.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends BasePage {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends BaseState<HomeScreen> with MasterPage {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _selectedIndex = 0;
  List<Forecast> outDoorForecast = [];
  List<Notification> notifications = [];
  initState() {
    super.initState();
    // makeNotificationInstance();
    Future.delayed(Duration(milliseconds: 100), () {
      listenForEvents();
      getZipcode();
      getAllNotifications();
    });
  }

  Future<void> listenForEvents() async {
    IO.Socket socket = IO.io(BaseApi.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    }).connect();
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
    });
    socket.on('NOTIFICATION_SEND', (data) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails('your_channel_id', 'your channel name',
              channelDescription: 'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'ticker');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      // await flutterLocalNotificationsPlugin.show(
      //     0, 'message', data['message'], platformChannelSpecifics,
      //     payload: 'item x');
      if (data != null) {
        print(data);
        getAllNotifications();
      }
    });
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  }

  Future<void> getZipcode() async {
    widget.showPageLoader(context, true);
    final rModel = EmptyBaseApiRequestModel();
    var user = await UserDataAccess.getUserDetails(rModel);

    //email =  user.result?.user?.email ?? "";
    var zipcode =  user.result?.user?.zipcode ?? "";
    print(zipcode);
    //var user = await SessionHelper.getSession();
    if (zipcode != "") {
      getForecast(zipcode);
    }
  }

  Future<void> getForecast(String zipcode) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res =
        await ForecastDataAccess.getForecast(rModel, zipcode, formattedDate);
    print("response");
    print(res.result);
    /* res.result!.forEach((element) { 
      print(element.toJson());
    }); */
    print("hello all1");
    if(mounted){
      widget.showPageLoader(context, false);
      widget.processResponseData(context, res);
    }
    
    
    if (res.status == false) {
      return;
    }
    if (res.result!.first.category!.number! > 2) {
      widget.addNotification(
          context, "Outdoor air aqi is at ${outDoorForecast.first.aqi}");
    }
    if(mounted){
      setState(() {
        outDoorForecast = res.result!;
      });
    }
    
  }

  Future<void> getAllNotifications() async {
    final rModel = EmptyBaseApiRequestModel();
    var res = await NotificationDataAccess.getAll(rModel);
    if (mounted) widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }
    if(mounted){
      setState(() {
        notifications = res.result!;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  makeNotificationInstance() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {});
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
      linux: initializationSettingsLinux,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });
  }

  @override
  Widget body() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: IndexedStack(
          children: [
            Dashboard(
              outdoorForecast: outDoorForecast,
            ),
            Notifications(
              notifications: notifications,
            ),
            Settings(),
            Profile(
              getForecast: getForecast,
            ),
          ],
          index: _selectedIndex,
        ));
  }

  @override
  appBarType appBarStyle() {
    return appBarType.full;
  }

  @override
  BottomNavigationBar? bottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 0,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_outlined),
          label: "",
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  @override
  bool vetoBack() {
    return true;
  }
}
