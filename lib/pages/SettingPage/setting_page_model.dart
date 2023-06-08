import 'package:flutter/material.dart';
import 'package:purmaster/pages/SettingPage/setting_page.dart';
import 'package:purmaster/main_models.dart';
import 'package:purmaster/widget/custom_widget.dart';

class SettingPageControll with ChangeNotifier {
  final BuildContext settingContext;
  SettingPageControll({required this.settingContext});

  List<ListButton> myListBtnsShare = [];
  List<ListButton> otherListBtnsShare = [];
  List<ListButton> myListBtnsWifi = [];

  Future<void> getMapFromFirestore() async {
    myListBtnsShare.clear();
    otherListBtnsShare.clear();
    myListBtnsWifi.clear();
    List<Map<String, dynamic>> dataList = userInfo.deviceList;

    for (int i = 0; i < dataList.length; i++) {
      _convertJsonToBtnShare(dataList[i]);
      _convertJsonToBtnWifi(dataList[i], i);
    }
  }

  void _convertJsonToBtnShare(dataList) {
    if (dataList['device']['owner'] == userInfo.email) {
      myListBtnsShare.add(
        ListButton(
          name: dataList['deviceName'],
          icon1: Icons.share,
          icon2: Icons.arrow_forward_ios_outlined,
          onPress: () => callShareDevice(settingContext).then((value) => null),
        ),
      );
    } else {
      otherListBtnsShare.add(
        ListButton(
          name: dataList['deviceName'],
          icon1: Icons.abc,
          icon2: Icons.arrow_forward_ios_outlined,
          onPress: () =>
              callRemoveShareDevice(settingContext, dataList['deviceName'])
                  .then((value) =>
                      value == true ? removeBtn(dataList['deviceName']) : null),
        ),
      );
    }
    notifyListeners();
  }

  void _convertJsonToBtnWifi(dataList, int i) {
    if (dataList['device']['owner'] == userInfo.email) {
      myListBtnsWifi.add(
        ListButton(
            name: dataList['deviceName'],
            icon1: Icons.wifi,
            icon2: Icons.arrow_forward_ios_outlined,
            onPress: () {
              List<String> wifiSSID = List<String>.from(dataList['wifiSSID']);
              callAddDeviceWifi(
                      settingContext, dataList['deviceName'], wifiSSID)
                  .then((value) {
                if (value != null) {
                  List<Map<String, dynamic>> deviceList = userInfo.deviceList;
                  String topic =
                      '${deviceList[i]['owner']}/${deviceList[i]['serialNum']}/wifi';
                  String msg = value;
                  if (msg.startsWith('remove:')) {
                    msg = msg.replaceAll('remove:', '');
                    logger.e(msg);
                    wifiSSID.remove(msg);
                  } else {
                    wifiSSID.add(msg);
                  }
                  mqttClient.sendMessage(topic, wifiSSID.toString());
                  deviceList[i]['wifiSSID'] = wifiSSID;
                  userInfo.uploadFirebase(deviceList, userInfo.email);
                }
              });
            }),
      );
    }
    notifyListeners();
  }

  void removeBtn(String deviceName) {
    for (int i = 0; i < otherListBtnsShare.length; i++) {
      if (deviceName == otherListBtnsShare[i].name) {
        otherListBtnsShare.removeAt(i);
      }
    }
    notifyListeners();
  }
}

class InnerPageControll with ChangeNotifier {
  final List<Widget> curPageList;
  InnerPageControll({required this.curPageList});

  int index = 0;
  late Widget curPage = curPageList[0];
  late String curPageName = (curPage as NameWidget).name;

  void gotoPage(int i) {
    index = i;
    curPage = curPageList[index];
    curPageName = (curPageList[index] as NameWidget).name;
    notifyListeners();
  }
}

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Future<dynamic> callChangeName(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return const ChangeName();
    },
  );
}

class ChangeName extends StatefulWidget {
  const ChangeName({super.key});

  @override
  State<ChangeName> createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  String? giveName;
  @override
  Widget build(BuildContext context) {
    return CallDialog(
      width: 320,
      height: 200,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '使用者名稱變更',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '使用者名稱',
                style: TextStyle(fontSize: 12),
              ),
              InputBox(onChanged: (str) => giveName = str),
            ],
          ),
        ),
        BlackButton(
          str: '確認',
          onPressed: () {
            if (giveName != null) {
              userInfo.updateUserName(giveName!);
              CustomSnackBar.show(context, '變更完成', level: 'info', time: 5);
              Navigator.pop(context, true);
            } else {
              CustomSnackBar.show(context, '請輸入完整資訊');
            }
          },
        ),
      ],
    );
  }
}

Future<dynamic> callChangePass(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const ChangePass();
    },
  );
}

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  String? oldPass;
  String? givePass;
  String? checkPass;

  void checkPassWord() {
    if (oldPass != null && givePass != null && checkPass != null) {
      userInfo
          .updatePassword(userInfo.email, oldPass!, givePass!, checkPass!)
          .then((result) {
        switch (result) {
          case 0:
            Navigator.pop(context);
            logger.i('update password sucess');
            break;
          case 1:
            CustomSnackBar.show(context, '密碼驗證不一致');
            break;
          case 2:
            CustomSnackBar.show(context, '請輸入8~16位英文數字密碼');
            break;
          case 3:
            CustomSnackBar.show(context, '密碼錯誤');
            break;
          default:
            CustomSnackBar.show(context, '網路錯誤');
            break;
        }
      });
    } else {
      CustomSnackBar.show(context, '請輸入完整資訊');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallDialog(
      width: 320,
      height: 500,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '密碼變更',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '舊密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(
                onChanged: (str) => oldPass = str,
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '設定新密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(
                onChanged: (str) => givePass = str,
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '確認新密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(
                onChanged: (str) => checkPass = str,
              ),
            ],
          ),
        ),
        BlackButton(
          str: '確認',
          onPressed: () => checkPassWord(),
        ),
      ],
    );
  }
}

Future<dynamic> callChangePassA(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 450,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '密碼變更',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '舊密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(),
            ],
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '設定新密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(),
            ],
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '確認新密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(),
            ],
          ),
        ),
        BlackButton(
          str: '確認',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

Future<dynamic> callShareDevice(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const ShareDevice();
    },
  );
}

class ShareDevice extends StatefulWidget {
  const ShareDevice({super.key});

  @override
  State<ShareDevice> createState() => _CallShareDevicetate();
}

class _CallShareDevicetate extends State<ShareDevice> {
  String? giveEmail;
  @override
  Widget build(BuildContext context) {
    return CallDialog(
      width: 320,
      height: 200,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '分享設備',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '分享給:',
                style: TextStyle(fontSize: 12),
              ),
              InputBox(
                onChanged: (str) => giveEmail = str,
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BlackButton(
              str: '確認',
              onPressed: () {
                Navigator.pop(context, giveEmail);
              },
            ),
            BlackButton(
              str: '取消',
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}

Future<dynamic> callRemoveShareDevice(BuildContext context, String deviceName) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 200,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '刪除設備',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Text(
            '確定刪除$deviceName?',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BlackButton(
              str: '確認',
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            BlackButton(
              str: '取消',
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        )
      ],
    ),
  );
}

class AddDeviceWifi extends StatefulWidget {
  final String deviceName;
  final List<String> wifiSSID;
  const AddDeviceWifi(
      {super.key, required this.deviceName, required this.wifiSSID});

  @override
  _AddDeviceWifiState createState() => _AddDeviceWifiState();
}

class _AddDeviceWifiState extends State<AddDeviceWifi> {
  late String deviceName;
  late List<String> wifiSSID;
  List<ListButtonPlus> wifiBtns = [];

  int index = 0;
  late List<Widget> pages;

  String? newSSID;
  String? newPass;

  void changePage(int i) {
    setState(() {
      index = i;
    });
  }

  void click(int i) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    deviceName = widget.deviceName;
    wifiSSID = widget.wifiSSID;

    for (int i = 0; i < wifiSSID.length; i++) {
      wifiBtns.add(
        ListButtonPlus(
          name: wifiSSID[i],
          icon1: Icons.wifi,
          icon2: Icons.arrow_drop_down,
          underline: false,
          onPressed: () {
            Navigator.of(context).pop('remove:${wifiSSID[i]}');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var mainPage = Container(
      height: 500,
      margin: const EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...wifiBtns,
            ListButton(
              name: '新增Wifi',
              icon1: Icons.add,
              icon2: Icons.arrow_forward_ios_outlined,
              underline: false,
              onPress: () => changePage(1),
            ),
          ],
        ),
      ),
    );

    var addPage = Container(
      margin: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SSID',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                  width: 250,
                  child: TextField(
                    onChanged: (ssid) => newSSID = ssid,
                    style: const TextStyle(fontSize: 16),
                    decoration: const InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Color(0xffcccccc),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '密碼',
                  style: TextStyle(fontSize: 12),
                ),
                PasswordInput(
                  onChanged: (pass) => newPass = pass,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 50),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlackButton(
                  str: '確認',
                  onPressed: () {
                    if (newSSID != null && newPass != null) {
                      if (newPass!.length >= 8) {
                        CustomSnackBar.show(context, '新增成功', level: 'info');
                        Navigator.of(context).pop(newSSID);
                      } else {
                        CustomSnackBar.show(context, 'WIFI密碼必須大於8位');
                      }
                    } else {
                      CustomSnackBar.show(context, '請輸入完整資訊');
                    }
                  },
                ),
                BlackButton(str: '取消', onPressed: () => changePage(0)),
              ],
            ),
          )
        ],
      ),
    );
    pages = [mainPage, addPage];

    return CallDialog(
      width: 320,
      height: 600,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Text(
            '$deviceName WiFi清單',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        pages[index],
      ],
    );
  }
}

Future<String?> callAddDeviceWifi(
    BuildContext context, String deviceName, List<String> wifiSSID) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AddDeviceWifi(
        deviceName: deviceName,
        wifiSSID: wifiSSID,
      );
    },
  );
}
