class WifiSignalHelper{
  int wifiSignalLevel = 4; //1 dot and 3 bar
    int strengthCount({required noOfWifi}){
    for (int n = 0; n < noOfWifi; n++) {
      if (n == 0) return wifiSignalLevel - n;
      else if (n > 1 && n < 5) return wifiSignalLevel - n + 1;
      else return 1;
    }
    return 0;
  }

  String wifiSignal({required noOfWifi}){
      int strength = strengthCount(noOfWifi: noOfWifi);
      return 'assets/images/Wifi-$strength.png';
  }
}