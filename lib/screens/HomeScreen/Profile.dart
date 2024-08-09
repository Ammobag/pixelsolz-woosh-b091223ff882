import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as P;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whoosh/constants/dialog_box_constant.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/dataAccess/ForecastDataAccess.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/dataAccess/ZipcodeDataAccess.dart';
import 'package:whoosh/core/helper/geo_location_helper.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/TextX.dart';

import 'package:flutter/material.dart';

class Profile extends BasePage {
  final Future<void> Function(String) getForecast;

  Profile({Key? key, required this.getForecast}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends BaseState<Profile> with MasterPage {
  String email = "";
  String zipcode = "";
  bool _isLocationFetching = false;
  TextEditingController _zipCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      getUserDetails();
      //getUserEmail();
      //getZipcode();
    });
  }

  void getUserEmail() async {
    var user = await SessionHelper.getSession();
    setState(() {
      email = user!.user!.email!;
    });
  }

  void getUserDetails() async {
    final rModel = EmptyBaseApiRequestModel();
    var user = await UserDataAccess.getUserDetails(rModel);
    email = user.result?.user?.email ?? "";
    zipcode = user.result?.user?.zipcode ?? "";
    print(email);
    print(zipcode);
  }

  Future<void> getZipcode() async {
    var user = await SessionHelper.getSession();
    setState(() {
      zipcode = user!.user!.zipcode!;
    });
  }

  Future<bool> _isZipCodeValid(BuildContext con) async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await ForecastDataAccess.getForecast(
        rModel, _zipCodeController.text, formattedDate);
    widget.showPageLoader(context, false);

    if (res.status == false) {
      //Navigator.of(con).pop();
      Timer(Duration(microseconds: 100), () {
        widget.processResponseData(context, res);
      });

      return false;
    }
    return true;
  }

  Future<void> setZipcode() async {
    final rModel = ZipcodeSetResponseModel();
    rModel.zipcode = _zipCodeController.text;
    widget.showPageLoader(context, true);
    var res = await ZipcodeDataAccess.setZipcode(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);
    if (res.status == false) {
      return;
    }

    widget.addNotification(context, "Zip Code modified");
    SessionHelper.updateSession("zipcode", _zipCodeController.text);
    widget.getForecast(_zipCodeController.text);
  }

  Future<void> handleCurrentAddress() async{
    setState(() {
      _isLocationFetching = true;
    });
    P.Position position = await GeoLocationHelper.getGeoLocationPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    /*
      * Here from place we can get
      * street, subLocality, locality, postalCode, country
       */
    setState(() {
      _zipCodeController.text = place.postalCode!;
      _isLocationFetching = false;
    });

  }

  Future<void> logout() async {
    await SessionHelper.deleteSession();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeSignin, (route) => false);
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change your location', textAlign: TextAlign.center, style: kDBTitleStyle,),
          insetPadding: const EdgeInsets.all(15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: Builder(
            builder: (context) {
              double width = MediaQuery.of(context).size.width;
              return Container(
                height: 90,
                width: width,
                child:
                TextFormField(
                  controller: _zipCodeController,
                  decoration: InputDecoration(
                    fillColor: Color(0xff21211F0A),
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    label: const Text('Enter Zip Code'),
                    hintText: "91403",
                    suffixIcon: GestureDetector(
                        onTap: () => handleCurrentAddress(),
                        child: _isLocationFetching ? Transform.scale(
                          scale: 0.3,
                          child: CircularProgressIndicator(),
                        ) : Icon(Icons.send, color: Colors.black,)),
                  ),

                ),
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
                    style: OutlinedButton.styleFrom(
                      backgroundColor: kDBButtonSecondaryColor,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel', style: TextStyle(color: Colors.black),),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                  width: kDBButtonWidth,
                  height: kDBButtonHeight,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      bool isZipCodeValid = await _isZipCodeValid(context);
                      if (isZipCodeValid) {
                        await setZipcode();
                        getZipcode();
                      } else {
                        Navigator.of(context).pop();
                        _zipCodeController.clear();
                        return;
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
          ],
        );
      },
    );
  }

  @override
  body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextX.heading("Profile"),
        SizedBox(height: MediaQuery.of(context).size.height * 0.048),
        Flexible(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Email address',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Color(0xffEBEBEA),
                title: Text(email),
              ),
              Text(
                'Your location (ZIP Code)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextX.subHeading(
                "Your location will be used to determine your local air quality index",
              ),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                tileColor: Color(0xffEBEBEA),
                title: zipcode == "" ? Text("Add zipcode") : Text(zipcode),
                trailing: IconButton(
                  icon: Icon(Icons.edit_sharp),
                  onPressed: () {
                    _displayTextInputDialog(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 17),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xffEBEBEA),
                  ),
                  onPressed: logout,
                  child: const Text('Logout'),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
