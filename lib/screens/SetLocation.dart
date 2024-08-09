import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';
import 'package:whoosh/core/dataAccess/ForecastDataAccess.dart';
import 'package:whoosh/core/dataAccess/ZipcodeDataAccess.dart';
import 'package:whoosh/core/helper/geo_location_helper.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:whoosh/core/widgets/TextX.dart';

class SetLocation extends BaseDeviceSetupPage {
  final VoidCallback onSetLocation;

  const SetLocation({Key? key, required this.onSetLocation}) : super(key: key);

  @override
  _SetLocationState createState() => _SetLocationState();
}

class _SetLocationState extends BaseDeviceSetupState<SetLocation>
    with MainPage {
  final _zipCodeController = TextEditingController();
  bool _isLocationFetching = false;
  Future<void> checkZipCodeValidity() async {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await ForecastDataAccess.getForecast(
        rModel, _zipCodeController.text, formattedDate);
    widget.showPageLoader(context, false);
    print(res.status);
    if (res.status == false) {
      widget.processResponseData(context, res);
      return;
    }
    await setZipcode();
    widget.onSetLocation();
  }

  Future<void> setZipcode() async {
    final rModel = ZipcodeSetResponseModel();
    rModel.zipcode = _zipCodeController.text;
    widget.showPageLoader(context, true);
    var res = await ZipcodeDataAccess.setZipcode(rModel);
    if(mounted){
      widget.showPageLoader(context, false);
      widget.processResponseData(context, res);
    }
    
    if (res.status == false) {
      return;
    }
    widget.addNotification(context, "Zip Code Added");
  }

  Future<void> handleCurrentAddress() async{
    setState(() {
      _isLocationFetching = true;
    });
    Position position = await GeoLocationHelper.getGeoLocationPosition();
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

  @override
  body() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.053,
        vertical: MediaQuery.of(context).size.height * 0.04,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 80,
            child: Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
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
                          '4',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.024,
                    ),
                    TextX.heading("Set your location"),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.014,
                    ),
                    TextX.subHeading(
                        "Your location will be used to determine your local air quality index"),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.039,
                    ),
                    Input.getTextField(
                      _zipCodeController,
                      false,
                      "Enter ZIP Code",
                      GestureDetector(
                        onTap: () => handleCurrentAddress(),
                        child: _isLocationFetching ? Transform.scale(
                          scale: 0.3,
                          child: CircularProgressIndicator(),
                        ) : Icon(Icons.send, color: Colors.black,),
                      ),
                      TextInputType.number,
                    )
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            flex: 20,
            child: OutlinedButton(
              onPressed: checkZipCodeValidity,
              child: const Text('Submit'),
            ),
          )
        ],
      ),
    );
  }
}
