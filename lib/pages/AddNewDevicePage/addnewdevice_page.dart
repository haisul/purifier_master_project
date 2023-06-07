import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:provider/provider.dart';
import 'package:purmaster/main_models.dart';
import 'package:app_settings/app_settings.dart';
import 'package:purmaster/pages/AddNewDevicePage/addnewdevice_page_models.dart';

////////////////////PageMain////////////////////

class AddNewDevicePage extends StatefulWidget {
  const AddNewDevicePage({super.key});

  @override
  State<AddNewDevicePage> createState() => _AddNewDevicePageState();
}

class _AddNewDevicePageState extends State<AddNewDevicePage> {
  final List<Widget> curPageList = const [
    DeviceChoisePage(),
    DeviceSetNamePage(),
    DeviceSetWifiPage(),
    DeviceConnectPage()
  ];

  final AddNewDevicePageControll addNewDevicePageControll =
      AddNewDevicePageControll();

  @override
  void dispose() {
    addNewDevicePageControll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: addNewDevicePageControll),
        ChangeNotifierProvider(
            create: (_) => InnerPageControll(curPageList: curPageList)),
      ],
      child: Consumer<InnerPageControll>(
        builder: (context, pageControll, child) {
          return Scaffold(
            backgroundColor: const Color(0xffffffff),
            appBar: PurMasterAppBar(
                context: context,
                title: '新增設備',
                returnButton: pageControll.index == 3 ? false : true,
                onPressed: () {
                  Navigator.pop(context);
                }),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Align(
                alignment: Alignment.topCenter,
                child: pageControll.curPage,
              ),
            ),
          );
        },
      ),
    );
  }
}

////////////////////Page0(chiose device)////////////////////

class DeviceChoisePage extends StatefulWidget {
  const DeviceChoisePage({
    super.key,
  });

  @override
  State<DeviceChoisePage> createState() => _DeviceChoisePageState();
}

class _DeviceChoisePageState extends State<DeviceChoisePage> {
  List<Widget> pages = const [
    IEPInnerPage(title: '消毒機'),
    EADInnerPage(title: '乾燥機'),
    CPInnerPage(title: '空壓機'),
  ];
  int currentIndex = 0;

  void changeInner(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DeviceListBtn(
                        title: '消毒機',
                        onPressed: () => changeInner(0),
                        isSelected: currentIndex == 0),
                    DeviceListBtn(
                        title: '乾燥機',
                        onPressed: () => changeInner(1),
                        isSelected: currentIndex == 1),
                    DeviceListBtn(
                        title: '空壓機',
                        onPressed: () => changeInner(2),
                        isSelected: currentIndex == 2),
                    DeviceListBtn(
                        title: '底泥機',
                        onPressed: () {},
                        isSelected: currentIndex == 3),
                    DeviceListBtn(
                        title: '消毒門',
                        onPressed: () {},
                        isSelected: currentIndex == 4),
                  ],
                ),
              ),
              Container(
                width: 2,
                color: const Color(0xffcccccc),
              )
            ],
          ),
        ),
        Expanded(child: pages[currentIndex]),
      ],
    );
  }
}

class IEPInnerPage extends StatelessWidget {
  final String title;
  const IEPInnerPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '消毒機',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(120, 0, 0, 0),
                  ),
                ),
                Expanded(child: DividingLine()),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              width: double.infinity,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  NewDeviceBtn(
                    title: '智能消毒機1',
                    img: 'assets/deviceImg/IEP1.png',
                    onPressed: () => context
                        .read<InnerPageControll>()
                        .intoPage(1, name: '智能消毒機1'),
                  ),
                  NewDeviceBtn(
                    title: '智能消毒機2',
                    onPressed: () => context
                        .read<InnerPageControll>()
                        .intoPage(1, name: '智能消毒機2'),
                  ),
                  NewDeviceBtn(
                    title: '智能消毒機3',
                    onPressed: () => context
                        .read<InnerPageControll>()
                        .intoPage(1, name: '智能消毒機3'),
                  ),
                  NewDeviceBtn(
                    title: '智能消毒機Lite',
                    onPressed: () => context
                        .read<InnerPageControll>()
                        .intoPage(1, name: '智能消毒機Lite'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EADInnerPage extends StatelessWidget {
  final String title;
  const EADInnerPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '乾燥機',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(120, 0, 0, 0),
                  ),
                ),
                Expanded(child: DividingLine()),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              height: double.infinity,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  NewDeviceBtn(
                    title: '免插電\n空氣乾燥機1',
                    onPressed: () {},
                  ),
                  NewDeviceBtn(
                    title: '免插電\n空氣乾燥機2',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CPInnerPage extends StatelessWidget {
  final String title;
  const CPInnerPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '空壓機',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(120, 0, 0, 0),
                  ),
                ),
                Expanded(child: DividingLine()),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(15),
              height: double.infinity,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  NewDeviceBtn(
                    title: '智能空壓機15HP',
                    onPressed: () {},
                  ),
                  NewDeviceBtn(
                    title: '智能空壓機30HP',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////Page1(enter device Name)////////////////////

class DeviceSetNamePage extends StatefulWidget {
  const DeviceSetNamePage({super.key});
  @override
  State<DeviceSetNamePage> createState() => _DeviceSetNamePageState();
}

class _DeviceSetNamePageState extends State<DeviceSetNamePage> {
  late String giveName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CardWidget(
            width: 320,
            height: 200,
            padding: const EdgeInsets.all(30),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '設備',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        context.watch<InnerPageControll>().deviceName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(180, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                height: 50,
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '名稱',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(
                      height: 20,
                      width: 250,
                      child: TextField(
                        onChanged: (str) {
                          giveName = str;
                        },
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
            ],
          ),
          Container(
              margin: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NormalButton(
                    str: '下一步',
                    onPressed: () {
                      try {
                        context.read<AddNewDevicePageControll>().saveName(
                            context.read<InnerPageControll>().deviceName);
                        context
                            .read<AddNewDevicePageControll>()
                            .saveName(giveName);
                        context.read<InnerPageControll>().intoPage(2);
                      } catch (e) {
                        logger.e(e);
                        CustomSnackBar.show(context, '請輸入新增設備名稱');
                      }
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

////////////////////Page2(enter device wifi)////////////////////

class DeviceSetWifiPage extends StatefulWidget {
  const DeviceSetWifiPage({super.key});
  @override
  State<DeviceSetWifiPage> createState() => _DeviceSetWifiPageState();
}

class _DeviceSetWifiPageState extends State<DeviceSetWifiPage> {
  late String password;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Provider.of<AddNewDevicePageControll>(context, listen: false)
          .wifiState) {
        CustomSnackBar.show(context, '請開啟WIFI無線網路');
      }
    });
  }

  void startSmartConfig() {
    if (password.length > 7) {
      context.read<AddNewDevicePageControll>().savePassword(password);
      context.read<InnerPageControll>().intoPage(3);
    } else if (password.length < 8) {
      CustomSnackBar.show(context, '請輸入至少8位英文或數字密碼');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CardWidget(
            width: 320,
            height: 190,
            padding: const EdgeInsets.all(30),
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
                      height: 25,
                      width: 250,
                      child: Text(
                        context.watch<AddNewDevicePageControll>().wifiName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(180, 0, 0, 0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                margin: const EdgeInsets.only(top: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '密碼',
                      style: TextStyle(fontSize: 12),
                    ),
                    PasswordInput(
                      onChanged: (pass) => password = pass,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.all(30),
            width: null,
            child: const Text(
              '1.開啟設備設定頁面\n2.選擇wifi設定\n3.選擇自動配對\n4.確認手機已透過wifi連線至網路\n5.輸入WIFI密碼\n6.點擊下一步\n7.等待網路配對完成',
              style: TextStyle(
                fontSize: 12,
                color: Color.fromARGB(120, 0, 0, 0),
                letterSpacing: 3,
                height: 2,
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NormalButton(
                    str: 'WIFI設定',
                    onPressed: () => AppSettings.openWIFISettings(),
                  ),
                  NormalButton(
                    str: '下一步',
                    onPressed: () {
                      if (!Provider.of<AddNewDevicePageControll>(context,
                              listen: false)
                          .wifiState) {
                        CustomSnackBar.show(context, '請開啟WIFI無線網路');
                      } else {
                        startSmartConfig();
                      }
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

////////////////////Page3(wait for device connect wifi)////////////////////

class DeviceConnectPage extends StatefulWidget {
  const DeviceConnectPage({
    super.key,
  });
  @override
  State<DeviceConnectPage> createState() => _DeviceConnectPageState();
}

class _DeviceConnectPageState extends State<DeviceConnectPage> {
  int count = 0;
  Timer? timer;

  void startPairing() {
    context.read<AddNewDevicePageControll>().pairing(context).then((complete) {
      if (complete) {
        try {
          context
              .read<AddNewDevicePageControll>()
              .saveSerialNum(mqttClient.serialNum);
        } catch (e) {
          logger.e(e);
        }
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (count > 3) {
            count = 0;
            timer.cancel();
            Navigator.pop(context,
                context.read<AddNewDevicePageControll>().getNewDeviceInfo);
          }
          count++;
        });
      } else {
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (count > 2) {
            count = 0;
            timer.cancel();
            Navigator.pop(context);
          }
          count++;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startPairing();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sync,
          size: 60,
          color: Color.fromARGB(180, 0, 0, 0),
        ),
        Container(
          margin: const EdgeInsets.all(30),
          width: null,
          child: Text(
            context.watch<AddNewDevicePageControll>().connectMsg,
            style: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(180, 0, 0, 0),
              letterSpacing: 3,
              height: 2,
            ),
          ),
        ),
      ],
    );
  }
}

////////////////////Widget////////////////////

class NewDeviceBtn extends StatelessWidget {
  final String title;
  final String img;
  final void Function() onPressed;
  const NewDeviceBtn(
      {super.key,
      required this.title,
      required this.onPressed,
      this.img = 'assets/google.png'});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 48,
            child: Image.asset(
              img,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color.fromARGB(120, 0, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceListBtn extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final bool isSelected;
  const DeviceListBtn(
      {super.key,
      required this.title,
      required this.onPressed,
      this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(
            width: 15,
          ),
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xff00C2FF)
                  : const Color(0xffcccccc),
            ),
          ),
          Container(
            width: 10,
            height: 50,
            color:
                isSelected ? const Color(0xff00C2FF) : const Color(0x00000000),
          ),
        ],
      ),
    );
  }
}
