import 'dart:async';
import 'package:purmaster/pages/IepPage/iep_page_models.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:flutter/material.dart';
import 'package:purmaster/pages/IepPage/iep_page.dart';
import 'package:purmaster/library/weather.dart' hide logger;
import 'package:purmaster/main_models.dart';

class HomePageControll with ChangeNotifier {
  BuildContext? homeContext;
  HomePageControll({
    required this.homeContext,
  }) {
    try {
      _getMapFromFirestore();
    } catch (e) {
      logger.e(e);
    }
    mqttClient.mqttMsgNotifier.addListener(mqttMsgProcess);
  }
  String userId = userInfo.email;
  List<IntoDeviceButton> deviceBtnList = [];

  Future<void> _getMapFromFirestore() async {
    List<Map<String, dynamic>> dataList = userInfo.deviceList;
    for (int i = 0; i < dataList.length; i++) {
      _convertJsonToBtn(dataList[i]);
    }
  }

  void _convertJsonToBtn(dataList) {
    List<String> wifiSSID = List<String>.from(dataList['wifiSSID']);
    if (dataList['device']['type'] == 'DeviceIEP') {
      IepPageControll deviceIEP =
          IepPageControll(serialNum: dataList['serialNum']);
      mqttClient.addNewDeviceTopic(
          dataList['device']['owner'], dataList['serialNum']);
      mqttClient.sendMessage('$userId/${dataList['serialNum']}/app', 'onApp');
      deviceBtnList.add(
        IntoDeviceButton(
          name: dataList['deviceName'],
          serialNum: dataList['serialNum'],
          wifiList: wifiSSID,
          device: deviceIEP,
          owner: dataList['device']['owner'],
          img: dataList['img'],
          onPressed: (val) async {
            if (!val) {
              CustomSnackBar.show(homeContext!, '設備未連線');
            }
            await Navigator.push(
              homeContext!,
              MaterialPageRoute(
                builder: (context) => IepPage(
                  title: dataList['deviceName'],
                  serialNum: dataList['serialNum'],
                  iepPageControll: deviceIEP,
                  userId: dataList['device']['owner'],
                ),
              ),
            ).then(
              (msg) {
                if (msg != null) {
                  if (msg == 'remove') {
                    removeBtn(dataList['serialNum']);
                    mqttClient.sendMessage(
                        '$userId/${dataList['serialNum']}/app', 'delete');
                  } else if (msg.startsWith('reName:')) {
                    String name = msg.replaceAll('reName:', '');
                    reNamedBtn(dataList['serialNum'], name);
                  } else if (msg == 'shutDown') {
                    LoadingDialog.show(homeContext!, '設備關閉中');
                    deviceIEP.updateMainPower(false);
                    mqttClient.sendMessage(
                        '$userId/${dataList['serialNum']}/app', 'shutDown');
                    Timer(const Duration(seconds: 3), () {
                      LoadingDialog.hide(homeContext!);
                    });
                  }
                }
              },
            );
          },
        ),
      );
    }
    notifyListeners();
  }

  void addBtn(Map<String, dynamic> newDeviceInfo) {
    List<String> wifiSSID = List<String>.from(newDeviceInfo['wifiSSID']);
    IepPageControll deviceIEP =
        IepPageControll(serialNum: newDeviceInfo['serialNum']);
    mqttClient.addNewDeviceTopic(userId, newDeviceInfo['serialNum']);
    mqttClient.sendMessage(
        '$userId/${newDeviceInfo['serialNum']}/app', 'onApp');
    deviceBtnList.add(
      IntoDeviceButton(
        name: newDeviceInfo['deviceName'],
        serialNum: newDeviceInfo['serialNum'],
        wifiList: wifiSSID,
        device: deviceIEP,
        owner: userId,
        img: 'assets/deviceImg/IEP1.png',
        onPressed: (val) async {
          if (!val) {
            CustomSnackBar.show(homeContext!, '設備未連線');
          }
          await Navigator.push(
            homeContext!,
            MaterialPageRoute(
              builder: (context) => IepPage(
                title: newDeviceInfo['deviceName'],
                serialNum: newDeviceInfo['serialNum'],
                iepPageControll: deviceIEP,
                userId: userId,
              ),
            ),
          ).then(
            (msg) {
              if (msg != null) {
                if (msg == 'remove') {
                  removeBtn(newDeviceInfo['serialNum']);
                  mqttClient.sendMessage(
                      '$userId/${newDeviceInfo['serialNum']}/app', 'delete');
                } else if (msg.startsWith('reName:')) {
                  String name = msg.replaceAll('reName:', '');
                  reNamedBtn(newDeviceInfo['serialNum'], name);
                } else if (msg == 'shutDown') {
                  deviceIEP.updateMainPower(false);
                  mqttClient.sendMessage(
                      '$userId/${newDeviceInfo['serialNum']}/app', 'shutDown');
                }
              }
            },
          );
        },
      ),
    );

    notifyListeners();
    _saveAndUpload();
  }

  void _saveAndUpload() {
    List<Map<String, dynamic>> deviceBtnListMap =
        deviceBtnList.map((e) => _toMap(e)).toList();
    userInfo.uploadFirebase(deviceBtnListMap, userId);
  }

  void removeBtn(String serialNum) {
    for (int i = 0; i < deviceBtnList.length; i++) {
      if (serialNum == deviceBtnList[i].serialNum) {
        deviceBtnList.removeAt(i);
      }
    }
    mqttClient.removeDeviceTopic(serialNum);
    notifyListeners();
    _saveAndUpload();
  }

  void reNamedBtn(String serialNum, String name) {
    for (int i = 0; i < deviceBtnList.length; i++) {
      if (serialNum == deviceBtnList[i].serialNum) {
        deviceBtnList[i].reNamed(name);
        break;
      }
    }
    notifyListeners();
    _saveAndUpload();
  }

  void mqttMsgProcess() {
    Map<String, dynamic> mqttMap = mqttClient.mqttMsgNotifier.value;
    if (mqttMap['topic'] != '' && mqttMap['msg'] != '') {
      for (int i = 0; i < deviceBtnList.length; i++) {
        logger.w(
            '$userId/${deviceBtnList[i].serialNum}/esp\nTopic:${mqttMap['topic']}\nMsg:${mqttMap['msg']}');

        if (mqttMap['topic'] == '$userId/${deviceBtnList[i].serialNum}/esp') {
          switch (mqttMap['msg']) {
            case '#onEsp':
              deviceBtnList[i].updateOnline(true);
              break;
            case '#disEsp':
              deviceBtnList[i].updateOnline(false);
              break;
            case '#powerOn':
              deviceBtnList[i].device.updateMainPower(true);
              break;
            case '#powerOff':
              deviceBtnList[i].device.updateMainPower(false);
              break;
            default:
              deviceBtnList[i].device.functionJsonConvert(mqttMap['msg']);
              break;
          }
        } else if (mqttMap['topic'] ==
            '$userId/${deviceBtnList[i].serialNum}/pms') {
          deviceBtnList[i].device.pmsJsonConvert(mqttMap['msg']);
          break;
        } else if (mqttMap['topic'] ==
            '$userId/${deviceBtnList[i].serialNum}/timer') {
          deviceBtnList[i].device.countTimeJsonConvert(mqttMap['msg']);
          break;
        }
      }
    }
  }

  Map<String, dynamic> _toMap(IntoDeviceButton widget) {
    Map<String, dynamic> data = <String, dynamic>{};
    data['deviceName'] = widget.name;
    data['serialNum'] = widget.serialNum;
    data['device'] = widget.device.toJson();
    data['device']['owner'] = widget.owner;
    data['img'] = widget.img;
    data['wifiSSID'] = widget.wifiList;
    return data;
  }
}

class WeatherControll with ChangeNotifier {
  WeatherControll() {
    myWeather = MyWeather();
    myWeather.weatherNotifier.addListener(updateWeatherInfo);
  }

  late final MyWeather myWeather;
  int temp = 0;
  double humd = 0, wdsd = 0;
  String weatherState = '-';
  String city = '-', town = '-', obsTime = '-';
  IconData weatherIconData = Icons.wb_sunny_outlined;

  void getWeatherInfo() {
    myWeather.updateWeatherInfo();
  }

  void updateWeatherInfo() {
    temp = myWeather.info['temp'];
    humd = myWeather.info['humd'];
    wdsd = myWeather.info['wdsd'];
    weatherState = myWeather.info['weatherState'];
    city = myWeather.info['city'];
    town = myWeather.info['town'];
    obsTime = myWeather.info['obsTime'];
    weatherIconData = myWeather.iconData;
    notifyListeners();
  }
}
