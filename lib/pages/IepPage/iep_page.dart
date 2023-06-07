import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purmaster/main_models.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:ele_progress/ele_progress.dart';
import 'dart:async';
import 'package:purmaster/pages/IepPage/iep_page_models.dart';
import 'package:slider_button/slider_button.dart';

////////////////////MainPage////////////////////

class IepPage extends StatelessWidget {
  final String title;
  final String userId;
  final String serialNum;
  final IepPageControll iepPageControll;
  late final List<Widget> curPageList;

  IepPage({
    super.key,
    required this.title,
    required this.serialNum,
    required this.userId,
    required this.iepPageControll,
  }) {
    curPageList = [
      IepPageAll(serialNum: serialNum, userId: userId),
      IepPagePur(serialNum: serialNum, userId: userId),
      IepPageFog(serialNum: serialNum, userId: userId),
      IepPageUvc(serialNum: serialNum, userId: userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: iepPageControll),
        ChangeNotifierProvider(
            create: (_) => InnerPageControll(curPageList: curPageList)),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xffffffff),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: SizedBox(
                height: 180,
                child: PurMasterAppBar(
                  context: context,
                  title: '',
                  returnButton: true,
                  popupButton: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Consumer2<IepPageControll, InnerPageControll>(
                builder: (context, iepPageControll, pageController, child) {
              return Positioned(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const DustInfoCard(),
                      Container(
                        height: 50,
                        color: const Color(0xffcccccc),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IEPFunctionBtn(
                              title: '全速清淨',
                              onPressed: () =>
                                  iepPageControll.mainPower != false
                                      ? pageController.gotoPage(0)
                                      : null,
                              isSelected: pageController.index == 0,
                            ),
                            IEPFunctionBtn(
                              title: '空氣淨化',
                              onPressed: () =>
                                  iepPageControll.mainPower != false
                                      ? pageController.gotoPage(1)
                                      : null,
                              isSelected: pageController.index == 1,
                            ),
                            IEPFunctionBtn(
                              title: '超音波霧化',
                              onPressed: () =>
                                  iepPageControll.mainPower != false
                                      ? pageController.gotoPage(2)
                                      : null,
                              isSelected: pageController.index == 2,
                            ),
                            IEPFunctionBtn(
                              title: 'UVC滅菌燈',
                              onPressed: () =>
                                  iepPageControll.mainPower != false
                                      ? pageController.gotoPage(3)
                                      : null,
                              isSelected: pageController.index == 3,
                            ),
                          ],
                        ),
                      ),
                      if (iepPageControll.mainPower)
                        Expanded(
                          child: PageView.builder(
                            controller: pageController.controll,
                            itemCount: pageController.curPageList.length,
                            onPageChanged: pageController.slidePage,
                            itemBuilder: (context, index) {
                              return pageController.curPageList[index];
                            },
                          ),
                        ),
                      if (!iepPageControll.mainPower)
                        Expanded(
                          child: Center(
                            child: SliderButton(
                              height: 70,
                              width: 250,
                              buttonSize: 55,
                              icon: const Icon(
                                Icons.power_settings_new,
                                color: Color.fromARGB(120, 0, 0, 0),
                              ),
                              label: const Text(
                                '啟動設備',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(120, 0, 0, 0),
                                    letterSpacing: 10),
                              ),
                              boxShadow: const BoxShadow(
                                  blurRadius: 5.0,
                                  color: Color.fromARGB(120, 0, 0, 0)),
                              action: () {
                                mqttClient.sendMessage(
                                    '$userId/$serialNum/app', 'turnOn');
                                LoadingDialog.show(context, '啟動中');
                                iepPageControll.updateMainPower(true);
                                Timer(const Duration(seconds: 3), () {
                                  LoadingDialog.hide(context);
                                });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

////////////////////InnerPage////////////////////

class IepPageAll extends StatelessWidget {
  final String serialNum;
  final String userId;
  const IepPageAll({super.key, required this.serialNum, required this.userId});
  final String func = 'all';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PowerButton(
            isTurnOn: context.watch<IepPageControll>().functionList[0].state,
            onPressed: (state) {
              mqttClient.sendMessage('$userId/$serialNum/app',
                  '${func}_state:${state ? 'on' : 'off'}');
              context.read<IepPageControll>().setState(func, state);
            },
          ),
          ControllCardWidget(
            height: 285,
            width: 400,
            title: '運轉時間設定',
            children: [
              TimeCountDownDashboard(
                func: func,
              ),
              TimeSetBtn(
                serialNum: serialNum,
                userId: userId,
                func: func,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class IepPagePur extends StatelessWidget {
  final String serialNum;
  final String userId;
  const IepPagePur({super.key, required this.serialNum, required this.userId});
  final String func = 'pur';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PowerButton(
            isTurnOn: context.watch<IepPageControll>().functionList[1].state,
            onPressed: (state) {
              mqttClient.sendMessage('$userId/$serialNum/app',
                  '${func}_state:${state ? 'on' : 'off'}');
              context.read<IepPageControll>().setState(func, state);
            },
          ),
          ControllCardWidget(
            height: 160,
            width: 400,
            title: '清淨模式',
            children: [
              PurModeGroup(
                mode: context.watch<IepPageControll>().pur.purMode,
                onSelected: (mode) {
                  String modeStr = 'Auto';
                  switch (mode) {
                    case 0:
                      modeStr = 'Auto';
                      break;
                    case 1:
                      modeStr = 'Sleep';
                      break;
                    case 2:
                      modeStr = 'Manual';
                      break;
                  }
                  mqttClient.sendMessage(
                      '$userId/$serialNum/app', '${func}_mode$modeStr');
                  context.read<IepPageControll>().setPurMode(mode);
                },
              ),
            ],
          ),
          Consumer<IepPageControll>(builder: (context, controll, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: controll.pur.purMode != 2 ? 0 : 180.0,
              curve: Curves.easeInOut,
              child: SingleChildScrollView(
                child: ControllCardWidget(
                  height: 145,
                  width: 400,
                  title: '清淨範圍調整',
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Text(
                        '${context.watch<IepPageControll>().pur.fanSpeed}%',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff5bc1c9)),
                      ),
                    ),
                    Slider(
                      min: 0.0,
                      max: 100.0,
                      divisions: 20,
                      activeColor: const Color(0xff5bc1c9),
                      inactiveColor: const Color(0x555bc1c9),
                      value: controll.pur.fanSpeed.toDouble(),
                      onChanged: (value) => controll.setPurSpeed(value),
                      onChangeEnd: (value) {
                        value < 10 ? value = 10.0 : value = value;
                        mqttClient.sendMessage('$userId/$serialNum/app',
                            '${func}_speed:${value.toInt()}');
                        controll.setPurSpeed(value);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          ControllCardWidget(
            height: 285,
            width: 400,
            title: '運轉時間設定',
            children: [
              TimeCountDownDashboard(
                func: func,
              ),
              TimeSetBtn(
                serialNum: serialNum,
                userId: userId,
                func: func,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class IepPageFog extends StatelessWidget {
  final String serialNum;
  final String userId;
  const IepPageFog({super.key, required this.serialNum, required this.userId});
  final String func = 'fog';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PowerButton(
            isTurnOn: context.watch<IepPageControll>().functionList[2].state,
            onPressed: (state) {
              mqttClient.sendMessage('$userId/$serialNum/app',
                  '${func}_state:${state ? 'on' : 'off'}');
              context.read<IepPageControll>().setState(func, state);
            },
          ),
          ControllCardWidget(
            height: 285,
            width: 400,
            title: '運轉時間設定',
            children: [
              TimeCountDownDashboard(
                func: func,
              ),
              TimeSetBtn(
                serialNum: serialNum,
                userId: userId,
                func: func,
              )
            ],
          ),
        ],
      ),
    );
  }
}

class IepPageUvc extends StatelessWidget {
  final String serialNum;
  final String userId;
  const IepPageUvc({super.key, required this.serialNum, required this.userId});
  final func = 'uvc';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PowerButton(
            isTurnOn: context.watch<IepPageControll>().functionList[3].state,
            onPressed: (state) {
              mqttClient.sendMessage('$userId/$serialNum/app',
                  '${func}_state:${state ? 'on' : 'off'}');
              context.read<IepPageControll>().setState(func, state);
            },
          ),
          ControllCardWidget(
            height: 285,
            width: 400,
            title: '運轉時間設定',
            children: [
              TimeCountDownDashboard(
                func: func,
              ),
              TimeSetBtn(
                serialNum: serialNum,
                userId: userId,
                func: func,
              )
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////widget////////////////////

class IEPFunctionBtn extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final bool isSelected;
  const IEPFunctionBtn(
      {super.key,
      required this.title,
      required this.onPressed,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isSelected == true
              ? const Color(0xff5AB7BE)
              : const Color.fromARGB(120, 0, 0, 0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

//purModeSwitch

class PurModeGroup extends StatelessWidget {
  final void Function(int) onSelected;
  final int mode;
  const PurModeGroup({
    super.key,
    required this.mode,
    required this.onSelected,
  });

  final String autoOffImg = 'assets/auto_off.png';
  final String sleepOffImg = 'assets/sleep_off.png';
  final String manualOffImg = 'assets/manual_off.png';
  final String autoOnImg = 'assets/auto_on.png';
  final String sleepOnImg = 'assets/sleep_on.png';
  final String manualOnImg = 'assets/manual_on.png';

  void changeState(int mode) {
    mode = mode;
    onSelected(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(0),
              ),
            ),
            onPressed: () => changeState(0),
            child: Image.asset(mode == 0 ? autoOnImg : autoOffImg),
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(0),
              ),
            ),
            onPressed: () => changeState(1),
            child: Image.asset(mode == 1 ? sleepOnImg : sleepOffImg),
          ),
          TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(0),
              ),
            ),
            onPressed: () => changeState(2),
            child: Image.asset(mode == 2 ? manualOnImg : manualOffImg),
          ),
        ],
      ),
    );
  }
}

//dustCard

class ControllCardWidget extends StatelessWidget {
  final double width, height;
  final String title;
  final List<Widget> children;
  const ControllCardWidget(
      {super.key,
      required this.height,
      required this.width,
      required this.title,
      required this.children});

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      width: width,
      height: height,
      margin: const EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
      children: [
        Text(
          title,
          style: const TextStyle(
            letterSpacing: 10,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff5AB7BE),
          ),
        ),
        ...children,
      ],
    );
  }
}

class DustInfoCard extends StatelessWidget {
  const DustInfoCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var humdValue = Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          const Icon(
            Icons.water_drop_outlined,
            size: 30,
            color: Color.fromARGB(255, 120, 120, 120),
          ),
          RichText(
            text: TextSpan(
              text: '${context.watch<IepPageControll>().pms['rhum']}',
              style: const TextStyle(
                fontFamily: 'Agencyb',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
              children: const <TextSpan>[
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var tempValue = Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.only(
        left: 20,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.thermostat,
            size: 30,
            color: Color.fromARGB(255, 120, 120, 120),
          ),
          RichText(
            text: TextSpan(
              text: '${context.watch<IepPageControll>().pms['temp']?.toInt()}',
              style: const TextStyle(
                fontFamily: 'Agencyb',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 120, 120, 120),
              ),
              children: const <TextSpan>[
                TextSpan(
                  text: '°C',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    var pm25Value = Container(
      margin: const EdgeInsets.only(top: 90),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'Agencyb',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 120, 120, 120),
          ),
          text: '${context.watch<IepPageControll>().pms['pm25']?.toInt()}',
          children: const [
            TextSpan(text: 'um/m3', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
    return Container(
      margin: const EdgeInsets.only(top: 70, bottom: 30),
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(112.5)),
      ),
      height: 225,
      width: 225,
      child: Stack(children: [
        Image.asset(
          'assets/dustInfo.png',
          fit: BoxFit.contain,
          color: const Color.fromARGB(255, 120, 120, 120),
        ),
        Center(
          child: Column(
            children: [
              pm25Value,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  tempValue,
                  humdValue,
                ],
              ),
            ],
          ),
        )
      ]),
    );
  }
}

//setTimeGroup

class TimeSetBtn extends StatelessWidget {
  final String serialNum;
  final String func;
  final String userId;
  const TimeSetBtn({
    super.key,
    required this.serialNum,
    required this.userId,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          height: 50,
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.all(0)),
            ),
            onPressed: () => myTimePickerDialog(
              context,
              func,
              serialNum,
              userId,
            ),
            child: Image.asset('assets/settime.png'),
          ),
        ),
        SwitchButton(
          isTurnOn: context.watch<IepPageControll>().getFunc(func).countState,
          onChanged: (state) {
            context.read<IepPageControll>().setCountState(func, state);
            mqttClient.sendMessage('$userId/$serialNum/app',
                '${func}_count:${state ? 'on' : 'off'}');
          },
          activeColor: const Color(0xff5bc1c9),
        ),
      ],
    );
  }
}

class TimeCountDownDashboard extends StatelessWidget {
  final String func;
  const TimeCountDownDashboard({super.key, required this.func});

  String timeConvert(int time) {
    String? hrBuff, minBuff, secBuff;
    hrBuff = time ~/ 3600 < 10 ? '0${time ~/ 3600}' : '${time ~/ 3600}';
    minBuff = time % 3600 ~/ 60 < 10
        ? '0${time % 3600 ~/ 60}'
        : '${time % 3600 ~/ 60}';
    secBuff =
        time % 3600 % 60 < 10 ? '0${time % 3600 % 60}' : '${time % 3600 % 60}';
    return '$hrBuff:$minBuff:$secBuff';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      width: 150,
      height: 150,
      child: EProgress(
        type: ProgressType.circle,
        strokeWidth: 20,
        progress: ((context.watch<IepPageControll>().getFunc(func).countTime /
                    context.watch<IepPageControll>().getFunc(func).time) *
                100)
            .toInt(),
        format: (progress) {
          return timeConvert(
              context.watch<IepPageControll>().getFunc(func).countTime);
        },
        textStyle: const TextStyle(
          color: Color(0xff5bc1c9),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Agencyb',
        ),
        colors: const [
          Color(0xff5bc1c9),
          Color(0xff88fcfc),
        ],
      ),
    );
  }
}

class TimePicker extends StatefulWidget {
  final void Function(int) onChanged;
  final String func;
  final BuildContext context;
  const TimePicker({
    super.key,
    required this.context,
    required this.func,
    required this.onChanged,
  });

  @override
  State<TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  int hr = 0, min = 0;

  @override
  void initState() {
    super.initState();
    hr = widget.context.watch<IepPageControll>().getFunc(widget.func).time ~/
        3600;
    min = (widget.context.watch<IepPageControll>().getFunc(widget.func).time %
            3600) ~/
        60;
  }

  void changeTime(String commend) {
    setState(() {
      switch (commend) {
        case 'hrUp':
          hr += 1;
          break;
        case 'hrDown':
          hr -= 1;
          break;
        case 'minUp':
          min += 5;
          break;
        case 'minDown':
          min -= 5;
          break;
        default:
      }
      hr = hr % 24;
      min = min % 60;
    });
    int time = hr * 3600 + min * 60;
    widget.onChanged(time);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => changeTime('hrUp'),
              icon: const Icon(
                Icons.arrow_drop_up_sharp,
                size: 48,
                color: Color(0xff5bc1c9),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              child: Text(
                '$hr\nHR',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Agencyb',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xff5bc1c9),
                ),
              ),
            ),
            IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => changeTime('hrDown'),
                icon: const Icon(
                  Icons.arrow_drop_down_sharp,
                  size: 48,
                  color: Color(0xff5bc1c9),
                )),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () => changeTime('minUp'),
              icon: const Icon(
                Icons.arrow_drop_up_sharp,
                size: 48,
                color: Color(0xff5bc1c9),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              child: Text(
                '$min\nMIN',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Agencyb',
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: Color(0xff5bc1c9),
                ),
              ),
            ),
            IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => changeTime('minDown'),
                icon: const Icon(
                  Icons.arrow_drop_down_sharp,
                  size: 48,
                  color: Color(0xff5bc1c9),
                )),
          ],
        ),
      ],
    );
  }
}

Future<dynamic> myTimePickerDialog(
    BuildContext context, func, serialNum, userId) {
  int setTime = 0;
  return showDialog(
    context: context,
    builder: (dialogContext) => CallDialog(
      width: 320,
      height: 380,
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          child: const Text(
            '時間設定',
            style: TextStyle(
              letterSpacing: 10,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff5AB7BE),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          child: TimePicker(
              context: context,
              func: func,
              onChanged: (time) {
                setTime = time;
              }),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BlackButton(
                  str: '確認',
                  color: const Color(0xff5bc1c9),
                  onPressed: () {
                    if (setTime != 0) {
                      mqttClient.sendMessage(
                          '$userId/$serialNum/app', '${func}_time:$setTime');
                      context.read<IepPageControll>().setTime(func, setTime);
                      Navigator.pop(context);
                    }
                  }),
              BlackButton(
                str: '取消',
                color: const Color(0xff5bc1c9),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        )
      ],
    ),
  );
}
