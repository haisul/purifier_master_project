import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:purmaster/main_models.dart';

class Wifi {
  late NetworkInfo networkInfo = NetworkInfo();

  final Map<String, dynamic> _wifiInfo = {
    'SSID': '',
    'BSSID': '',
    'IP': '',
    'IPv6': '',
    'Submask': '',
    'Broadcast': '',
    'Gateway': '',
  };

  Map<String, dynamic> get wifiInfo => _wifiInfo;

  Future<bool> updateWifiInfo() async {
    try {
      var wifiName = await networkInfo.getWifiName();
      var wifiBSSID = await networkInfo.getWifiBSSID();
      var wifiIP = await networkInfo.getWifiIP();
      var wifiIPv6 = await networkInfo.getWifiIPv6();
      var wifiSubmask = await networkInfo.getWifiSubmask();
      var wifiBroadcast = await networkInfo.getWifiBroadcast();
      var wifiGateway = await networkInfo.getWifiGatewayIP();

      _wifiInfo['SSID'] = wifiName!.replaceAll('"', '');
      _wifiInfo['BSSID'] = wifiBSSID!;
      _wifiInfo['IP'] = wifiIP!;
      _wifiInfo['IPv6'] = wifiIPv6!;
      _wifiInfo['Submask'] = wifiSubmask!;
      _wifiInfo['Broadcast'] = wifiBroadcast!;
      _wifiInfo['Gateway'] = wifiGateway!;

      logger.i(_wifiInfo);
      return true;
    } catch (e) {
      logger.e('Not connected to WiFi network:$e');
      return false;
    }
  }

  Map<String, dynamic> get info => _wifiInfo;
}
