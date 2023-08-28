import 'dart:convert';

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

  void _convertJsonToBtnWifi(Map<String, dynamic> data, int i) {
    if (data['device']['owner'] == userInfo.email) {
      myListBtnsWifi.add(
        ListButton(
            name: data['deviceName'],
            icon1: Icons.wifi,
            icon2: Icons.arrow_forward_ios_outlined,
            onPress: () {
              List<String> wifiSSID = List<String>.from(data['wifiSSID']);
              callAddDeviceWifi(settingContext, data).then((value) {
                if (value != null) {
                  List<Map<String, dynamic>> deviceList = userInfo.deviceList;
                  String msg = value;
                  if (msg.startsWith('remove:')) {
                    msg = msg.replaceAll('remove:', '');
                    wifiSSID.remove(msg);
                  } else {
                    wifiSSID.remove(msg);
                    wifiSSID.add(msg);
                  }
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
          onPressed: () async {
            if (giveName != null) {
              LoadingDialog.show(context, description: '請稍候');
              await userInfo.updateUserName(giveName!).then((result) {
                LoadingDialog.hide(context);
                if (result) {
                  CustomSnackBar.show(context, '變更完成', level: 0, time: 3);
                  Navigator.pop(context, true);
                } else {
                  CustomSnackBar.show(context, '操作失敗', level: 2, time: 3);
                }
              });
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
  final Map<String, dynamic> data;
  const AddDeviceWifi({super.key, required this.data});

  @override
  _AddDeviceWifiState createState() => _AddDeviceWifiState();
}

class _AddDeviceWifiState extends State<AddDeviceWifi> {
  late final Map<String, dynamic> data;
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
    data = widget.data;
    deviceName = data['deviceName'] as String;
    wifiSSID = List<String>.from(data['wifiSSID']);

    for (int i = 0; i < wifiSSID.length; i++) {
      wifiBtns.add(
        ListButtonPlus(
          name: wifiSSID[i],
          icon1: Icons.wifi,
          icon2: Icons.arrow_drop_down,
          underline: false,
          onPressed: () {
            String topic =
                '${data['device']['owner']}/${data['serialNum']}/wifi';
            mqttClient.sendMessage(topic, 'D${wifiSSID[i]}');
            Navigator.of(context).pop('remove:${wifiSSID[i]}');
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var mainPage = Container(
      height: 300,
      margin: const EdgeInsets.only(top: 30),
      child: SingleChildScrollView(
        child: Column(
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
                        String topic =
                            '${data['device']['owner']}/${data['serialNum']}/wifi';
                        Map<String, dynamic> newWifi = {
                          'SSID': newSSID,
                          'PASSWORD': newPass
                        };
                        String newWifiStr = jsonEncode(newWifi);
                        mqttClient.sendMessage(topic, 'A$newWifiStr');
                        CustomSnackBar.show(context, '新增成功', level: 0);
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
      height: 420,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Text(
            '${limitText(deviceName, 8)} WiFi清單',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color.fromARGB(120, 0, 0, 0),
            ),
          ),
        ),
        pages[index],
      ],
    );
  }
}

Future<String?> callAddDeviceWifi(
    BuildContext context, Map<String, dynamic> data) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AddDeviceWifi(
        data: data,
      );
    },
  );
}

Future<dynamic> callLogout(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 200,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '確定登出嗎?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(120, 0, 0, 0),
                  letterSpacing: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlackButton(
                str: '確認',
                onPressed: () {
                  userInfo.logout().then((result) async {
                    if (result) {
                      await userInfo.removeUserInfo();
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/loginPage',
                        (route) => false,
                      );
                    }
                  });
                },
              ),
              BlackButton(
                  str: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
      ],
    ),
  );
}

Future<dynamic> callDeleteUser(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 200,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '確定刪除帳戶嗎?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(120, 0, 0, 0),
                  letterSpacing: 10,
                ),
              ),
              Text(
                '請注意，一但刪除帳戶後，將無法復原',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(120, 0, 0, 0),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlackButton(
                color: const Color.fromARGB(255, 255, 100, 100),
                str: '刪除',
                onPressed: () {
                  userInfo.deletUser().then((value) async {
                    if (value) {
                      await userInfo.removeUserInfo();
                      await userInfo.logout();
                      // ignore: use_build_context_synchronously
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/loginPage',
                        (route) => false,
                      );
                    }
                  });
                },
              ),
              BlackButton(
                  str: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
      ],
    ),
  );
}

/*
Future<dynamic> callSendFeedback(BuildContext context, String? msg) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 200,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '確定寄出嗎?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(120, 0, 0, 0),
                  letterSpacing: 10,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BlackButton(
                str: '確定',
                onPressed: () async {
                  if (msg != null) {
                    //LoadingDialog.show(context, description: '請稍候');

                    String emailBody =
                        'UserInfo:\n method:${userInfo.method}\n name:${userInfo.name}\n email:${userInfo.email}\n uid:${userInfo.uid}\n\nFeedBack:\n$msg';
                    final Email email = Email(
                      subject: 'PurMaster FeedBack',
                      body: emailBody,
                      recipients: ['ex2252@gmail.com'],
                    );
                    /*final message = Message()
                      ..from = Address(username, userInfo.name)
                      ..recipients.add('ex2252@gmail.com')
                      ..subject = 'PurMaster FeedBack'
                      ..text = emailBody;*/

                    try {
                      await FlutterEmailSender.send(email).then((value) {
                        CustomSnackBar.show(context, '感謝您寶貴的意見', level: 0);
                      });
                      logger.i('Email sent successfully');
                    } catch (error) {
                      logger.e('Error occurred: $error');
                      CustomSnackBar.show(context, '寄送失敗', level: 2);
                    }
                  }
                },
              ),
              BlackButton(
                  str: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
      ],
    ),
  );
}
*/