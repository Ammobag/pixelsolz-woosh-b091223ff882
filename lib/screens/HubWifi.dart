import 'package:flutter/material.dart';
import 'package:whoosh/core/BaseDeviceSetupPage.dart';

class HubWifi extends BaseDeviceSetupPage {
  
  final Function() fn;
  final String txt;
  HubWifi(this.fn, this.txt);
  @override
  _HubWifiState createState() => _HubWifiState();
}

class _HubWifiState extends BaseDeviceSetupState<HubWifi> with MainPage {
  

  @override
  Widget body() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 35,),
          Center(
            child: Container(
              // color: Colors.red,
              height: MediaQuery.of(context).size.height / 2.5,
              child: Image.asset('assets/images/Woosh_AQM.png'),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(widget.txt,style: TextStyle(
            fontSize: 18
          ),textAlign: TextAlign.center,),),
          SizedBox(height: 15,),
          GestureDetector(
              onTap: (){
                widget.fn();
              },
              child: Text("Try again",style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).primaryColor
            ),textAlign: TextAlign.center,),
          )
          ]
      )
    );
  }
}