import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseApiRequestModel.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/SessionHelper.dart';
import 'package:whoosh/core/api/GoogleSignInApi.dart';
import 'package:whoosh/core/dataAccess/HubDataAccess.dart';
import 'package:whoosh/core/dataAccess/UserDataAccess.dart';
import 'package:whoosh/core/route/Routes.dart';
import 'package:whoosh/core/widgets/Input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:whoosh/core/widgets/main_logo.dart';

class SignIn extends BasePage {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends BaseState<SignIn> with MasterPage {
  final String _googleSignInFailText = 'Sign in with Google failed';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> signIn() async {
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

    final rModel = UserSignInRequestModel();
    rModel.email = _emailController.text;
    rModel.password = _passwordController.text;
    widget.showPageLoader(context, true);
    var res = await UserDataAccess.signIn(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);

    if (res.status == false) {
      return;
    }
    await SessionHelper.setSession(res.result);
    await routingManager(res.result!.user!.name);
  }

  Future<void> signInWithGoogle() async {
    try{
      widget.showPageLoader(context, true);
      final user = await GoogleSignInApi.login();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_googleSignInFailText),
          ),
        );
        widget.showPageLoader(context, false);
        return;
      }
      final rModel = UserSignInWithGoogleRequestModel();
      rModel.email = user.email;
      rModel.name = user.displayName;
      var res = await UserDataAccess.signInWithGoogle(rModel);
      widget.showPageLoader(context, false);
      widget.processResponseData(context, res);
      if (res.status == false) {
        await GoogleSignInApi.logout();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_googleSignInFailText),
          ),
        );
        return;
      }
      await SessionHelper.setSession(res.result);
      await routingManager(res.result!.user!.name);
    }catch(e){
      widget.showPageLoader(context, false);
    }
  }

  Future<void> routingManager(String? name) async {
    final rModel = EmptyBaseApiRequestModel();
    widget.showPageLoader(context, true);
    var res = await HubDataAccess.isUserAssociatedWithAHub(rModel);
    widget.showPageLoader(context, false);
    widget.processResponseData(context, res);

    if (res.status == false) {
      return;
    }
    if (res.result!.hasHub!) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(routeHome, (route) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(routeSetupPrimer, (route) => false);
    }

//    ScaffoldMessenger.of(context).showSnackBar(
//      SnackBar(
//        content: Text("Welcome $name"),
//      ),
//    );
  }

  @override
  Widget body() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MainLogo(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
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
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.0197,
                  ),
                  Input.getTextFormField(
                    // The validator receives the text that the user has entered.
                    _passwordController,
                    true,
                    "Password",
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
                        signIn();
                      }
                    },
                    child: const Text('Sign in'),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.029,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Forgot your password? '),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(forgetPassword);
                  },
                  child: Text(
                    'Click here.',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.029,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account? '),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(routeRegister);
                  },
                  child: Text(
                    'Register.',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.029,
            ),
            Divider(
              thickness: 1,
              indent: 30,
              endIndent: 30,
              color: Color(0xffCECDCA),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.029,
            ),
            Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: MaterialButton(
                color: Colors.white,
                child: Row(
                  children: [
                    Container(
                      height: 50.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/google.png'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                    ),
                    Text('Sign in with Google '),
                  ],
                ),
                onPressed: signInWithGoogle,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.0197,
            ),
            Material(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: MaterialButton(
                color: Colors.white,
                child: Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 50.0,
                      width: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/facebook.png'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                    ),
                    Text("Sign In with Facebook")
                  ],
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  appBarType appBarStyle() {
    return appBarType.none;
  }

  @override
  bool vetoBack() {
    return true;
  }
}
