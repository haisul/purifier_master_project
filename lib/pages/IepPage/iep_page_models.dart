import 'package:flutter/material.dart';
import 'package:purmaster/library/function_status.dart';
import 'dart:convert';
import 'dart:async';

class IepPageControll with ChangeNotifier {
  bool mainPower = false;
  bool isConnected = false;

  String serialNum;
  late Map<String, double> pms;
  late List<FunctionStatus> functionList;

  FunctionStatus all = FunctionStatus(name: 'all');
  PurFunctionStatus pur = PurFunctionStatus(name: 'pur');
  FunctionStatus fog = FunctionStatus(name: 'fog');
  FunctionStatus uvc = FunctionStatus(name: 'uvc');

  IepPageControll({required this.serialNum}) {
    functionList = [all, pur, fog, uvc];
    pms = {'pm25': 0, 'temp': 0, 'rhum': 0};
  }

  void updateMainPower(bool val) {
    mainPower = val;
    notifyListeners();
  }

  void updateOnline(bool val) {
    isConnected = val;
    notifyListeners();
  }

  void functionJsonConvert(String msg) {
    final Map<String, dynamic> funcMap = json.decode(msg);
    for (int i = 0; i < 4; i++) {
      var func = functionList[i];
      func.state = funcMap[func.name]['state'];
      func.countState = funcMap[func.name]['countState'];
      func.time = funcMap[func.name]['time'];
      func.countTime = funcMap[func.name]['time'];
      _timerStart(func.name);
      if (func is PurFunctionStatus) {
        PurFunctionStatus purFunc = func;
        purFunc.changeMode(funcMap[purFunc.name]['mode']);
        purFunc.fanSpeed = funcMap[purFunc.name]['speed'];
      }
    }
    notifyListeners();
  }

  void pmsJsonConvert(msg) {
    final Map<String, dynamic> pmsMap = json.decode(msg);
    pms['pm25'] = double.parse(pmsMap['pm25']);
    pms['temp'] = double.parse(pmsMap['temp']);
    pms['rhum'] = double.parse(pmsMap['rhum']);

    notifyListeners();
  }

  void countTimeJsonConvert(msg) {
    final Map<String, dynamic> countTimeMap = json.decode(msg);
    for (int i = 0; i < 4; i++) {
      var func = functionList[i];
      func.countTime = countTimeMap['${func.name}CountTime'];
    }
    notifyListeners();
  }

  void setState(String funcName, bool val) {
    getFunc(funcName).state = val;
    _timerStart(funcName);
    notifyListeners();
  }

  void setCountState(String funcName, bool val) {
    getFunc(funcName).countState = val;
    _timerStart(funcName);
    notifyListeners();
  }

  void setTime(String funcName, int val) {
    getFunc(funcName).time = val;
    getFunc(funcName).countTime = val;
    notifyListeners();
  }

  void setPurMode(int mode) {
    pur.changeMode(mode);
    notifyListeners();
  }

  void setPurSpeed(double val) {
    val < 10 ? val = 10.0 : val = val;
    pur.fanSpeed = val.toInt();
    notifyListeners();
  }

  void allOn(bool val) {
    if (val) {
      for (int i = 1; i < 4; i++) {
        functionList[i].state = false;
        _timerStart(functionList[i].name);
      }
      notifyListeners();
    }
  }

  void _timerStart(String funcName) {
    var func = getFunc(funcName);
    if (func.state && func.countState) {
      func.timer?.cancel();
      func.timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        func.countTime--;
        if (func.countTime <= 0) {
          func.state = false;
          func.countTime = func.time;
          timer.cancel();
        }
        notifyListeners();
      });
    } else if (func.timer != null) {
      if (!func.state || !func.countState) {
        func.timer?.cancel();
        func.countTime = func.time;
        notifyListeners();
      }
    }
  }

  FunctionStatus getFunc(String funcName) {
    Map<String, int> funcNameMap = {
      'all': 0,
      'pur': 1,
      'fog': 2,
      'uvc': 3,
    };
    int i = funcNameMap[funcName] ?? 0;
    return functionList[i];
  }

  Map<String, dynamic> toJson() {
    return {'type': 'DeviceIEP', 'owner': 'owner'};
  }
}

class InnerPageControll with ChangeNotifier {
  final List<Widget> curPageList;
  InnerPageControll({required this.curPageList}) {
    controll = PageController(initialPage: 0);
  }

  late final PageController controll;

  late String deviceName;
  int _index = 0;

  void gotoPage(int index, {String name = ''}) {
    _index = index;
    deviceName = name;
    controll.animateToPage(
      _index,
      duration: const Duration(milliseconds: 500), // 動畫持續時間
      curve: Curves.easeInOut, // 動畫曲線
    );
    notifyListeners();
  }

  void slidePage(int index) {
    _index = index;
    notifyListeners();
  }

  int get index => _index;
}
