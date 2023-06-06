import 'package:flutter/material.dart';
import 'package:purmaster/library/wifi.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:purmaster/main_models.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class AddNewDevicePageControll with ChangeNotifier {
  AddNewDevicePageControll() {
    startListening();
  }

  Wifi wifi = Wifi();
  String connectMsg = '設備連線中...';
  String wifiName = '', wifiBssid = '', wifiPass = '';
  bool wifiState = false;
  final Map<String, dynamic> _newDeviceMap = {};

  late StreamSubscription<ConnectivityResult> subscription;

  void startListening() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.wifi) {
        wifiState = false;
      } else {
        wifiState = true;
        getWifiInfo();
      }
      logger.i(result);
    });
  }

  void stopListening() {
    subscription.cancel();
  }

  void saveName(String name) {
    _newDeviceMap['deviceName'] = name;
  }

  void saveSerialNum(String serialNum) {
    _newDeviceMap['serialNum'] = serialNum;
  }

  void saveDevice(String device) {
    _newDeviceMap['deviceType'] = device;
  }

  void savePassword(String password) {
    wifiPass = password;
  }

  Map<String, dynamic> get getNewDeviceInfo => _newDeviceMap;

  Future<void> getWifiInfo() async {
    await wifi.updateWifiInfo();
    wifiName = wifi.info['SSID'];
    wifiBssid = wifi.info['BSSID'];

    notifyListeners();
  }

  Future<bool> pairing(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();
    final espTouch = Provisioner.espTouch();
    mqttClient.onMqttCallBack();
    espTouch.listen((response) {
      logger.i("Device ($response) is connected to WiFi!");
    });
    try {
      await espTouch.start(ProvisioningRequest.fromStrings(
        ssid: wifiName,
        bssid: wifiBssid,
        password: wifiPass,
      ));
      logger
          .i('wifiName:$wifiName wifiBssid:$wifiBssid wifiPassword:$wifiPass');

      mqttClient.initialConnection(wifiName).then((value) {
        if (value) {
          completer.complete(true);
          connectMsg = '連線成功';
          List<String> wifiSSID = [wifiName];
          _newDeviceMap['wifiSSID'] = wifiSSID;
        } else {
          completer.complete(false);
          connectMsg = '連線失敗';
        }
        espTouch.stop();
      });
    } catch (e) {
      completer.complete(false);
      connectMsg = '連線錯誤\n請檢查SSID及密碼';
    }
    notifyListeners();
    return completer.future;
  }

  Future<void> wifiCheck() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.wifi) {
      wifiState = false;
    } else {
      wifiState = true;
    }
  }
}

class InnerPageControll with ChangeNotifier {
  final List<Widget> curPageList;
  InnerPageControll({required this.curPageList}) {
    curPage = curPageList[0];
  }

  late Widget curPage;
  late String deviceName;
  int _index = 0;

  void intoPage(int index, {String name = ''}) {
    _index = index;
    curPage = curPageList[index];
    deviceName = name;
    notifyListeners();
  }

  int get index => _index;
}
