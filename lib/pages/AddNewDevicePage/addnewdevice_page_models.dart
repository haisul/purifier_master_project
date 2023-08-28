import 'package:flutter/material.dart';
import 'package:purmaster/library/wifi.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:purmaster/main_models.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:purmaster/widget/custom_widget.dart';

class AddNewDevicePageControll with ChangeNotifier {
  AddNewDevicePageControll() {
    mqttClient.serialNum = '';
    mqttClient.isConnected = false;
    wifiCheckSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      logger.i(result);
      if (result != ConnectivityResult.wifi) {
        wifiState = false;
      } else {
        wifiState = true;
        getWifiInfo();
      }
    });
  }

  late StreamSubscription<ConnectivityResult> wifiCheckSubscription;

  Wifi myWifi = Wifi();
  String wifiName = '', wifiBssid = '', wifiPass = '';
  bool wifiState = false;
  final Map<String, dynamic> _newDeviceMap = {};

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
    Map<String, dynamic>? wifiInfo = await myWifi.updateWifiInfo();
    if (wifiInfo != null) {
      wifiName = wifiInfo['SSID'];
      wifiBssid = wifiInfo['BSSID'];
      notifyListeners();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      await getWifiInfo();
    }
  }

  final espTouch = Provisioner.espTouch();
  Future<bool> pairing(BuildContext context) async {
    Completer<bool> completer = Completer<bool>();
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

      initialConnection(wifiName).then((value) {
        if (value) {
          completer.complete(true);
          List<String> wifiSSID = [wifiName];
          _newDeviceMap['wifiSSID'] = wifiSSID;
          CustomSnackBar.show(context, '配對成功', level: 0, time: 2);
        } else {
          completer.complete(false);
          CustomSnackBar.show(context, '配對失敗', level: 2, time: 2);
        }
        espTouch.stop();
      });
    } catch (e) {
      completer.complete(false);
      CustomSnackBar.show(context, '配對失敗', level: 2, time: 2);
    }
    notifyListeners();
    return completer.future;
  }

  StreamSubscription<bool>? connectSubscription;
  Future<bool> initialConnection(String topic) async {
    Completer<bool> completer = Completer<bool>();

    mqttClient.subscribe(topic, 0);

    Stream<bool> stream = Stream<bool>.periodic(
            const Duration(milliseconds: 500), (_) => mqttClient.isConnected)
        .take(120); //1min

    connectSubscription = stream.listen((isConnected) {
      if (isConnected) {
        completer.complete(true);
        connectSubscription!.cancel();
      }
    }, onDone: () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      mqttClient.unSubscribe(topic);
    });
    return completer.future;
  }

  @override
  void dispose() {
    super.dispose();
    wifiCheckSubscription.cancel();
    connectSubscription?.cancel();
    espTouch.stop();
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
