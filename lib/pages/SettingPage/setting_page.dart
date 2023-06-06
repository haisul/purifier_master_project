import 'package:flutter/material.dart';
import 'package:purmaster/main_models.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:provider/provider.dart';
import 'package:purmaster/pages/SettingPage/setting_page_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

////////////////////MainPage////////////////////
class SettingPage extends StatelessWidget {
  final SettingPageControll settingPageControll;
  SettingPage({super.key, required this.settingPageControll}) {
    settingPageControll.getMapFromFirestore();
  }

  final List<Widget> curPageList = const [
    ServiceChoise(),
    ProfilePage(),
    SettingPage1(),
    SettingPage2(),
    SettingPage3(),
    SettingPage4(),
    SettingPage5(),
    SettingPage6(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) =>
              InnerPageControll(curPageList: curPageList),
        ),
        ChangeNotifierProvider.value(value: settingPageControll),
      ],
      child:
          Consumer<InnerPageControll>(builder: (context, pageControll, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: const Color(0xffffffff),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 180,
                  child: PurMasterAppBar(
                      context: context,
                      title: pageControll.curPageName,
                      returnButton: true,
                      onPressed: () {
                        if (pageControll.index != 0) {
                          pageControll.gotoPage(0);
                        } else {
                          Navigator.pop(context);
                        }
                      }),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.15,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: WillPopScope(
                      onWillPop: () async {
                        if (pageControll.index != 0) {
                          pageControll.gotoPage(0);
                          return false;
                        } else {
                          return true;
                        }
                      },
                      child: pageControll.curPage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ServiceChoise extends StatelessWidget implements NameWidget {
  @override
  String get name => '設定';
  const ServiceChoise({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 125,
            width: 125,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 210, 210, 210),
              shape: BoxShape.circle,
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              height: 125,
              width: 125,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(62.5),
                child: userInfo.img != ''
                    ? Image.network(
                        userInfo.img,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/profile.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
          BlackButton(
              width: 105,
              str: 'Edit Profile',
              onPressed: () => context.read<InnerPageControll>().gotoPage(1)),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: ListView(
              itemExtent: 80,
              padding: const EdgeInsets.only(top: 0),
              physics: const ClampingScrollPhysics(),
              children: [
                ListButton(
                    name: '韌體更新',
                    icon1: Icons.ios_share,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(2)),
                ListButton(
                    name: '分享設備',
                    icon1: Icons.share,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(3)),
                ListButton(
                    name: '網路管理',
                    icon1: Icons.wifi,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(4)),
                ListButton(
                    name: '通知設定',
                    icon1: Icons.notifications_active_outlined,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(5)),
                ListButton(
                    name: '登出',
                    icon1: Icons.logout_outlined,
                    icon2: Icons.chevron_right,
                    onPress: () => callLogout(context)),
                ListButton(
                    name: '意見回饋',
                    icon1: Icons.rate_review_outlined,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(6)),
                ListButton(
                    name: '關於',
                    icon1: Icons.info_outline,
                    icon2: Icons.chevron_right,
                    onPress: () =>
                        context.read<InnerPageControll>().gotoPage(7)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////ProfilePage////////////////////

class ProfilePage extends StatefulWidget implements NameWidget {
  @override
  String get name => '使用者資訊';
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> photoPicker() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File file = File(image.path);
      userInfo.updateUserImg(file, userInfo.email).then((value) {
        Provider.of<InnerPageControll>(context, listen: false).gotoPage(0);
        CustomSnackBar.show(context, '變更完成', level: 'info', time: 5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                TextButton(
                  onPressed: () => photoPicker(),
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 210, 210, 210),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 125,
                      width: 125,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(62.5),
                        child: userInfo.img != ''
                            ? Image.network(
                                userInfo.img,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/profile.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  width: 320,
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '使用者名稱',
                              style: TextStyle(fontSize: 16),
                            ),
                            Container(
                              height: 2,
                              width: null,
                              color: const Color(0xffcccccc),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userInfo.name,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                BlackButton(
                                  str: '變更',
                                  onPressed: () {
                                    //callChangeName(context);
                                    callChangeName(context).then((value) {
                                      if (value) {
                                        Provider.of<InnerPageControll>(context,
                                                listen: false)
                                            .gotoPage(0);
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'E-Mail',
                              style: TextStyle(fontSize: 16),
                            ),
                            Container(
                              height: 2,
                              width: null,
                              color: const Color(0xffcccccc),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 15),
                              child: Text(
                                userInfo.email,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 15, bottom: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '密碼變更',
                              style: TextStyle(fontSize: 16),
                            ),
                            Container(
                              height: 2,
                              width: null,
                              color: const Color(0xffcccccc),
                            ),
                            Container(
                              alignment: Alignment.centerRight,
                              child: BlackButton(
                                str: '變更',
                                onPressed: () {
                                  if (userInfo.method != 'google') {
                                    callChangePass(context);
                                  } else {
                                    CustomSnackBar.show(
                                        context, 'Google登入不支援密碼變更');
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////Page1(software update)////////////////////

class SettingPage1 extends StatefulWidget implements NameWidget {
  @override
  String get name => '韌體更新';
  const SettingPage1({super.key});
  @override
  State<SettingPage1> createState() => _SettingPage1State();
}

class _SettingPage1State extends State<SettingPage1> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CardWidget(
                width: 320,
                height: 195,
                padding: const EdgeInsets.all(30),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.asset(
                            'assets/google.png',
                          )),
                      BlackButton(
                        str: '更新',
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    alignment: Alignment.bottomLeft,
                    width: null,
                    child: const Text(
                      '智能消毒機',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    alignment: Alignment.bottomLeft,
                    width: null,
                    child: const Text(
                      '智能消毒機有可更新的韌體。',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              Container(
                  margin: const EdgeInsets.all(30),
                  child: NormalButton(str: '全部更新', onPressed: () {})),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////Page2(share device)////////////////////

class SettingPage2 extends StatefulWidget implements NameWidget {
  @override
  String get name => '分享設備';
  const SettingPage2({super.key});
  @override
  State<SettingPage2> createState() => _SettingPage2State();
}

class _SettingPage2State extends State<SettingPage2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              '我的設備',
              style: TextStyle(
                  color: Color.fromARGB(180, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5),
            ),
            const DividingLine(),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 30),
              width: null,
              height: MediaQuery.of(context).size.height * 0.25,
              child: ListView(
                itemExtent: 75,
                padding: const EdgeInsets.only(top: 0),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...Provider.of<SettingPageControll>(context).myListBtnsShare
                ],
              ),
            ),
            const Text(
              '其他設備',
              style: TextStyle(
                  color: Color.fromARGB(180, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5),
            ),
            const DividingLine(),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 30),
              width: null,
              height: MediaQuery.of(context).size.height * 0.25,
              child: ListView(
                itemExtent: 75,
                padding: const EdgeInsets.only(top: 0),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...Provider.of<SettingPageControll>(context)
                      .otherListBtnsShare
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////Page3(device wifi manager)////////////////////

class SettingPage3 extends StatefulWidget implements NameWidget {
  @override
  String get name => '網路管理';
  const SettingPage3({super.key});
  @override
  State<SettingPage3> createState() => _SettingPage3State();
}

class _SettingPage3State extends State<SettingPage3> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              '我的設備',
              style: TextStyle(
                  color: Color.fromARGB(180, 0, 0, 0),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5),
            ),
            const DividingLine(),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 30),
              width: null,
              height: MediaQuery.of(context).size.height * 0.7,
              child: ListView(
                padding: const EdgeInsets.only(top: 0),
                physics: const BouncingScrollPhysics(),
                children: [
                  ...Provider.of<SettingPageControll>(context).myListBtnsWifi,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////Page4(notification setting)////////////////////

class SettingPage4 extends StatefulWidget implements NameWidget {
  @override
  String get name => '通知設定';
  const SettingPage4({super.key});
  @override
  State<SettingPage4> createState() => _SettingPage4State();
}

class _SettingPage4State extends State<SettingPage4> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                '系統通知',
                style: TextStyle(
                    color: Color.fromARGB(180, 0, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5),
              ),
              const DividingLine(),
              Container(
                margin: const EdgeInsets.only(top: 30, bottom: 30),
                padding: const EdgeInsets.only(left: 25, right: 25),
                width: 350,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1, // 陰影擴散程度
                      blurRadius: 10, // 陰影模糊程度
                      offset: const Offset(2, 2), // 陰影偏移量
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '設備通知',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(180, 0, 0, 0),
                      ),
                    ),
                    SwitchButton(onChanged: (state) {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////Page5(feedback)////////////////////

class SettingPage5 extends StatefulWidget implements NameWidget {
  @override
  String get name => '意見回饋';
  const SettingPage5({super.key});
  @override
  State<SettingPage5> createState() => _SettingPage5State();
}

class _SettingPage5State extends State<SettingPage5> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CardWidget(
                width: 320,
                height: 300,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: const Text(
                      '感謝您提供寶貴的意見',
                      style: TextStyle(
                          color: Color.fromARGB(120, 0, 0, 0),
                          fontSize: 14,
                          letterSpacing: 2),
                    ),
                  ),
                  Container(
                    width: 250,
                    height: 200,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(10, 0, 0, 0),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: const TextField(
                      maxLines: null, // 設置為 null，讓其自動換行
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.0), // 設置上下左右 padding
                        border: InputBorder.none,
                        hintText: 'Enter a message',
                      ),
                    ),
                  ),
                ],
              ),
              NormalButton(str: 'Send', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////Page6(information)////////////////////

class SettingPage6 extends StatefulWidget implements NameWidget {
  @override
  String get name => '關於';
  const SettingPage6({super.key});
  @override
  State<SettingPage6> createState() => _SettingPage6State();
}

class _SettingPage6State extends State<SettingPage6> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1, // 陰影擴散程度
                    blurRadius: 10, // 陰影模糊程度
                    offset: const Offset(2, 2), // 陰影偏移量
                  ),
                ],
              ),
              child: Image.asset('assets/logo.png'),
            ),
            Container(
                margin: const EdgeInsets.only(top: 30),
                child: const Text(
                  'PurifyMaster',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(180, 0, 0, 0),
                  ),
                )),
            const Text(
              '版本:2.23.0.1',
              style: TextStyle(
                color: Color.fromARGB(180, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////widget////////////////////

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
                  userInfo.logout().then((value) async {
                    await userInfo.removeUserInfo();
                    // ignore: use_build_context_synchronously
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/loginPage',
                      (route) => false,
                    );
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

abstract class NameWidget {
  String get name;
}
