import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/Input.dart';

class ForgetPassword extends BasePage {
  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends BaseState<ForgetPassword> with MasterPage {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> submitForgetPass() async {
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

    final rModel = UserForgetPasswordRequestModel();
    rModel.email = _emailController.text;
    // rModel.password = _passwordController.text;
    widget.showPageLoader(context, true);
    var res = await UserDataAccess.forgetPassword(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res,true,(){
      // Navigator.of(context)
      //     .pushNamedAndRemoveUntil(routeSignin, (route) => false);
    });
    
    if (res.status == false) {
      return;
    }else{
      widget.showSuccessMessage(context, res.result?.status,callBack: (){
        Navigator.of(context)
          .pushNamedAndRemoveUntil(routeSignin, (route) => false);
      });
      
      // print(res.result?.status);
    }
    
  }

  @override
  Widget body() {
    // return Container();
    return Column(
      children: [
        Flexible(flex: 1, child: Container()),
        Flexible(
          flex: 6,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MediaQuery.of(context).size.height * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Input.getTextFormField(
                        // The validator receives the text that the user has entered.
                        _emailController,
                        false,
                        "Email",
                        (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email id';
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
                            // signIn();
                            submitForgetPass();
                          }
                        },
                        child: const Text('Submit'),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.029,
                      ),
                    ],
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ],
    );
  }

}