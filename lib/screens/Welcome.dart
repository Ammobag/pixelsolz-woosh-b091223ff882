import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseScreen.dart';
import 'package:whoosh/core/route/Routes.dart';

class Welcome extends BasePage {
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends BaseState<Welcome> with MasterPage {
  @override
  Widget body() {
    return Column(
      children: <Widget>[
        Flexible(
          flex: 2,
          child: Container(),
        ),
        Flexible(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset('assets/images/logo.png'),
                Text(
                  'Lorem ipsum dolor sit amet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                ),
                Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                  ),
                ),
                Column(
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            routeSignin, (route) => false);
                      },
                      child: Text('Get Started'),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.019,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            routeSignin, (route) => false);
                      },
                      child: Text('Sign In'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
