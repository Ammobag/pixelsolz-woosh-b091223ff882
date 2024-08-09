import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/helper/geo_location_helper.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:whoosh/core/widgets/app_back_button.dart';

class Register extends BasePage {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends BaseState<Register> with MasterPage {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLocationFetching = false;
  bool _showPassword = false;
  Future<void> register() async {
    FocusScope.of(context).unfocus();
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Connection'),
        ),
      );
      return;
    }

    final rModel = UserSignUpRequestModel();
    rModel.name = _nameController.text;
    rModel.email = _emailController.text;
    rModel.password = _passwordController.text;
    rModel.zipcode = _zipcodeController.text;
    rModel.confirm_password = _confirmPasswordController.text;
    widget.showPageLoader(context, true);
    var res = await UserDataAccess.signUp(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);

    if (res.status == false) {
      return;
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeSignin, (route) => false);
//    ScaffoldMessenger.of(context).showSnackBar(
//      SnackBar(
//        content: Text(res.result!.status!),
//      ),
//    );
  }

  @override
  bool resizeToAvoidBottomInset() {
    return true;
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
        _zipcodeController.text = place.postalCode!;
        _isLocationFetching = false;
      });

  }

  @override
  Widget body() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              AppBackButton(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
              Text('Register', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Input.getTextFormField(
                      _nameController,
                      false,
                      "Name",
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.029,
                    ),
                    Input.getTextFormField(
                      _emailController,
                      false,
                      "Email",
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.029,
                    ),
                    Input.getTextFormField(
                      _zipcodeController,
                      false,
                      "Zipcode (Optional)",
                      null,
                      GestureDetector(
                        onTap: () => handleCurrentAddress(),
                        child: _isLocationFetching ? Transform.scale(
                          scale: 0.3,
                          child: CircularProgressIndicator(),
                        ) : Icon(Icons.send, color: Colors.black,),
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.029,
                    ),
                    Input.getTextFormField(
                      _passwordController,
                      !_showPassword,
                      "Password",
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      GestureDetector(
                        child: Icon( !_showPassword ? Icons.visibility : Icons.visibility_off),
                        onTap: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      )
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.029,
                    ),
                    Input.getTextFormField(
                      _confirmPasswordController,
                      true,
                      "Confirm Password",
                      (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.029,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false otherwise.
                        if (_formKey.currentState!.validate()) {
                          register();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
