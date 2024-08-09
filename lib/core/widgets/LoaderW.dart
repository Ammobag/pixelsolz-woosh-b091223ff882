import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class LoaderW{
  static getLoaderDesign(text){
    return Center(child: Container(
        color: Colors.grey[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // CircularProgressIndicator(),
            SpinKitFadingCircle(
              size: 50,
              color: Color(0xFF0D5C8E),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: text == "" ? SizedBox.shrink() : Text(text,style: TextStyle(
                
              ),textAlign: TextAlign.center,) ,
            )
            
            
          ],
        ),
      ));
  }

  static getLoaderDesignWithBackGround(text,context){
    return Center(child: Container(
        color: Colors.grey[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            Container(
              //color: Colors.red,
              width: MediaQuery.of(context).size.width-50,child: Image.asset('assets/images/Woosh_AQM.png'),),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 0,vertical: 20),
              child: text == "" ? SizedBox.shrink() : Text(text,style: TextStyle(
                
              ),textAlign: TextAlign.center,) ,
            ),
            // CircularProgressIndicator(),
            SpinKitFadingCircle(
              size: 50,
              color: Color(0xFF0D5C8E),
            )
            
          ],
        ),
      ));
  }
}