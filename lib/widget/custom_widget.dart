import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:purmaster/pages/IepPage/iep_page_models.dart';
import 'package:slider_button/slider_button.dart';
import 'dart:async';
import 'dart:ui';

//主標題顏色Color.fromARGB(180, 0, 0, 0),
//內文顏色Color.fromARGB(120, 0, 0, 0),
//TextStyle(fontFamily: 'Agencyb', fontSize: 48, color: Colors.white),
//藍綠色Color(0xff5bc1c9)

class ListButton extends StatelessWidget {
  final String name;
  final IconData icon1;
  final IconData icon2;
  final void Function() onPress;
  final bool underline;
  const ListButton({
    super.key,
    required this.name,
    required this.icon1,
    required this.icon2,
    required this.onPress,
    this.underline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      height: 40,
      width: double.infinity,
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(0), // 调整padding
          ),
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        onPressed: onPress,
        child: Row(
          children: [
            const SizedBox(
              width: 30,
            ),
            Container(
              margin: const EdgeInsets.only(right: 30),
              child: Icon(
                icon1,
                color: const Color(0xffcccccc),
                size: 30,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        limitText(name, 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(120, 0, 0, 0),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Icon(
                          icon2,
                          color: const Color(0xffcccccc),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  if (underline)
                    Container(
                      height: 2,
                      color: const Color(0xffcccccc),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ListButtonPlus extends StatefulWidget {
  final String name;
  final IconData icon1;
  final IconData icon2;
  final void Function() onPressed;
  final bool underline;
  final bool click;
  const ListButtonPlus(
      {super.key,
      required this.name,
      required this.icon1,
      required this.icon2,
      required this.onPressed,
      this.underline = true,
      this.click = false});

  @override
  State<ListButtonPlus> createState() => _ListButtonPlusState();
}

class _ListButtonPlusState extends State<ListButtonPlus> {
  late bool click;
  @override
  void initState() {
    super.initState();
    click = widget.click;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          height: 40,
          width: double.infinity,
          child: TextButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all<EdgeInsets>(
                const EdgeInsets.all(0), // 调整padding
              ),
              overlayColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(60, 90, 90, 90)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
                ),
              ),
            ),
            onPressed: () {
              setState(() {
                click = !click;
              });
            },
            child: Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Container(
                  margin: const EdgeInsets.only(right: 30),
                  child: Icon(
                    widget.icon1,
                    color: const Color(0xffcccccc),
                    size: 30,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(120, 0, 0, 0),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Icon(
                              widget.icon2,
                              color: const Color(0xffcccccc),
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      if (widget.underline)
                        Container(
                          height: 2,
                          color: const Color(0xffcccccc),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (click)
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: const Color.fromARGB(255, 255, 130, 130),
                  margin: const EdgeInsets.all(0),
                  height: 30,
                  width: 50,
                  child: TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(0), // 调整padding
                      ),
                    ),
                    onPressed: widget.onPressed,
                    child: const Text(
                      '刪除',
                      style: TextStyle(
                        color: Color(0xffffffff),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class IntoDeviceButton extends StatelessWidget {
  String name;
  final String serialNum;
  final IepPageControll device;
  final String owner;
  final String img;
  List<String> wifiList;
  final void Function(bool) onPressed;

  ValueNotifier<String>? nameNotifier;
  ValueNotifier<bool>? onlineNotifier;

  IntoDeviceButton(
      {super.key,
      required this.name,
      required this.serialNum,
      required this.wifiList,
      required this.device,
      required this.owner,
      required this.img,
      required this.onPressed}) {
    nameNotifier = ValueNotifier<String>(name);
    onlineNotifier = ValueNotifier<bool>(false);
  }

  void reNamed(String val) {
    name = val;
    nameNotifier!.value = val;
  }

  void updateOnline(bool val) {
    onlineNotifier!.value = val;
  }

  @override
  Widget build(BuildContext context) {
    var btnName = ValueListenableBuilder(
        valueListenable: nameNotifier!,
        builder: (context, str, child) {
          return Text(
            str,
            style: const TextStyle(
                fontSize: 12,
                color: Color.fromARGB(120, 0, 0, 0),
                fontWeight: FontWeight.bold),
            softWrap: true,
            maxLines: 2,
          );
        });
    var onlineState = ValueListenableBuilder(
        valueListenable: onlineNotifier!,
        builder: (context, val, child) {
          return Icon(
            Icons.cloud_done_outlined,
            color: val != true
                ? const Color(0xffcccccc)
                : const Color.fromARGB(255, 100, 170, 255),
            size: 20,
          );
        });
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          )
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(10), // 调整padding
          ),
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        onPressed: () => onPressed(onlineNotifier!.value),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      img,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.center,
                    child: btnName,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: onlineState,
            ),
          ],
        ),
      ),
    );
  }
}

class AddDeviceButton extends StatelessWidget {
  void Function() onPress;
  AddDeviceButton({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          )
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(0), // 调整padding
          ),
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        onPressed: onPress,
        child: const Icon(
          Icons.add_box,
          size: 50,
          color: Color(0xffcccccc),
        ),
      ),
    );
  }
}

class BlackButton extends StatelessWidget {
  String str;
  double height;
  double width;
  void Function() onPressed;
  Color color;
  BlackButton({
    super.key,
    required this.str,
    required this.onPressed,
    this.height = 35,
    this.width = 75,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(0),
      height: height,
      width: width,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(0), // 调整padding
          ),
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          str,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xffffffff)),
        ),
      ),
    );
  }
}

class NormalButton extends StatelessWidget {
  String str;
  double height;
  double width;
  String imgAssets;
  void Function()? onPressed;

  NormalButton(
      {super.key,
      required this.str,
      required this.onPressed,
      this.height = 50,
      this.width = 100,
      this.imgAssets = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          )
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: imgAssets == ''
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            if (imgAssets != '')
              Container(
                  margin: const EdgeInsets.only(right: 30),
                  child: Image.asset(imgAssets)),
            Text(
              str,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(120, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  void Function() onPress;
  String str;
  GoogleButton({
    super.key,
    required this.str,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          ),
        ],
      ),
      width: 250,
      height: 45,
      child: TextButton(
        onPressed: onPress,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 25,
              child: Image.asset(
                'assets/google.png',
                fit: BoxFit.cover,
              ),
            ),
            Text(
              str,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(120, 0, 0, 0),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PowerButton extends StatefulWidget {
  void Function(bool) onPressed;
  bool isTurnOn;
  bool disable;
  PowerButton({
    super.key,
    this.isTurnOn = false,
    this.disable = false,
    required this.onPressed,
  });

  @override
  State<PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<PowerButton> {
  String str = '關閉';
  String img = 'assets/turnOff.png';
  void changeState() {
    setState(() {
      if (widget.isTurnOn) {
        str = '啟動';
        img = 'assets/turnOn.png';
      } else {
        str = '關閉';
        img = 'assets/turnOff.png';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    changeState();
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 15, left: 30, right: 30),
      height: 70,
      width: 400,
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          )
        ],
      ),
      child: TextButton(
        onPressed: () {
          if (!widget.disable) {
            widget.isTurnOn = !widget.isTurnOn;
            changeState();
            widget.onPressed(widget.isTurnOn);
          }
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all<Color>(
              const Color.fromARGB(60, 90, 90, 90)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // 設置水波紋的圓角半徑
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                margin: const EdgeInsets.only(right: 30),
                child: Image.asset(img)),
            Text(
              str,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 5,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(120, 0, 0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwitchButton extends StatefulWidget {
  Color activeColor;
  void Function(bool) onChanged;
  bool isTurnOn;
  SwitchButton({
    super.key,
    this.isTurnOn = false,
    required this.onChanged,
    this.activeColor = const Color(0xff00C2FF),
  });

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
      activeColor: widget.activeColor,
      value: widget.isTurnOn,
      showOnOff: true,
      activeText: ('ON'),
      inactiveText: ('OFF'),
      onToggle: (bool value) {
        setState(() {
          widget.isTurnOn = value;
        });
        widget.onChanged(widget.isTurnOn);
      },
    );
  }
}

class PurMasterAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  void Function()? onPressed;
  bool centerTitle;
  bool returnButton;
  bool settingButton;
  bool popupButton;

  PurMasterAppBar({
    super.key,
    required this.context,
    required this.title,
    this.onPressed,
    this.centerTitle = false,
    this.returnButton = false,
    this.settingButton = false,
    this.popupButton = false,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    var returnBtn = IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(
          Icons.arrow_back,
          size: 30,
          color: Color.fromARGB(180, 0, 0, 0),
        ),
        onPressed: onPressed);
    var settingBtn = IconButton(
        padding: const EdgeInsets.all(0),
        icon: const Icon(
          Icons.settings,
          size: 30,
          color: Color.fromARGB(180, 0, 0, 0),
        ),
        onPressed: onPressed);
    var popupBtn = IconButton(
      padding: const EdgeInsets.all(0),
      onPressed: () {
        callPopup(context);
      },
      icon: const Icon(
        Icons.more_vert,
        color: Color.fromARGB(180, 0, 0, 0),
      ),
    );

    return AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/appBar.png'),
                    fit: BoxFit.fitWidth),
              ),
            ),
            Container(
              height: null,
              width: null,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0x00ffffff), Color(0xffffffff)],
                  stops: [0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        title: SizedBox(
          height: 120,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!returnButton) Container(),
                    if (returnButton) returnBtn,
                    if (returnButton)
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Color.fromARGB(180, 0, 0, 0),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 10,
                            ),
                          ),
                        ),
                      ),
                    if (settingButton) settingBtn,
                    if (popupButton) popupBtn,
                  ],
                ),
              ),
              if (!returnButton)
                Container(
                  height: 40,
                  width: double.infinity,
                  alignment: centerTitle == false
                      ? Alignment.centerLeft
                      : Alignment.center,
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(180, 0, 0, 0),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 10,
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(130);
}

class CardWidget extends StatelessWidget {
  double? width;
  double height;
  //double margin;
  //double padding;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  List<Widget> children;
  CardWidget(
      {super.key,
      required this.width,
      required this.height,
      required this.children,
      this.margin = const EdgeInsets.all(30),
      this.padding = const EdgeInsets.all(15)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1, // 陰影擴散程度
            blurRadius: 10, // 陰影模糊程度
            offset: const Offset(2, 2), // 陰影偏移量
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}

class CallDialog extends StatelessWidget {
  final double width;
  final double? height;
  final double margin;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;
  final bool noBackground;
  const CallDialog(
      {super.key,
      required this.width,
      this.height,
      required this.children,
      this.padding = const EdgeInsets.all(15),
      this.margin = 30,
      this.noBackground = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // 設置模糊效果
            child: Container(
              color: Colors.black.withOpacity(0), // 設置半透明黑色背景
            ),
          ),
        ),
        Dialog(
          backgroundColor: const Color(0x00ffffff),
          shadowColor: const Color(0x00ffffff),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: noBackground != true
                ? BoxDecoration(
                    color: const Color(0xffffffff),
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1, // 陰影擴散程度
                        blurRadius: 10, // 陰影模糊程度
                        offset: const Offset(2, 2), // 陰影偏移量
                      ),
                    ],
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}

class DividingLine extends StatelessWidget {
  const DividingLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 360,
      height: 2,
      color: const Color(0xffcccccc),
    );
  }
}

class InputBox extends StatefulWidget {
  final Function(String)? onChanged;
  const InputBox({
    super.key,
    required this.onChanged,
  });

  @override
  State<InputBox> createState() => _InputBoxState();
}

class _InputBoxState extends State<InputBox> {
  void getText(str) {
    if (widget.onChanged != null) widget.onChanged!(str);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 250,
      child: TextField(
        onChanged: (str) => getText(str),
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
    );
  }
}

class PasswordInput extends StatefulWidget {
  final Function(String)? onChanged;
  const PasswordInput({
    super.key,
    this.onChanged,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _showPass = false;
  void getText(str) {
    if (widget.onChanged != null) widget.onChanged!(str);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 250,
      child: TextField(
        style: const TextStyle(fontSize: 16),
        obscureText: _showPass == false ? true : false,
        onChanged: (str) => getText(str),
        decoration: InputDecoration(
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: Color(0xffcccccc),
            ),
          ),
          suffixIcon: IconButton(
            iconSize: 25,
            padding: const EdgeInsets.all(0),
            onPressed: () {
              _showPass = !_showPass;
              setState(() {});
            },
            icon: Icon(
              _showPass == false ? Icons.visibility_off : Icons.visibility,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSnackBar {
  static void show(BuildContext context, String message,
      {int level = 2, int time = 3}) {
    Color myColor;
    switch (level) {
      case 0:
        myColor = const Color.fromARGB(255, 100, 170, 255);
        break;
      case 1:
        myColor = const Color.fromARGB(255, 255, 200, 100);
        break;
      case 2:
        myColor = const Color.fromARGB(255, 255, 100, 100);
        break;
      default:
        myColor = const Color.fromARGB(255, 255, 100, 100);
        break;
    }
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: myColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      duration: Duration(seconds: time),
      action: SnackBarAction(
        label: 'x',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class LoadingDialog {
  static Future<dynamic> show(BuildContext context,
      {required String description, int time = 0}) {
    if (time != 0) {
      Timer.periodic(Duration(seconds: time), (timer) {
        Navigator.pop(context);
        timer.cancel();
      });
    }
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CallDialog(
        width: 320,
        noBackground: true,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(30),
                  height: 70,
                  width: 70,
                  child: const CircularProgressIndicator(
                    strokeWidth: 7,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffffffff),
                    letterSpacing: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

Future<dynamic> callReName(BuildContext context) {
  String newName = '';
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 250,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '重新命名',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(120, 0, 0, 0),
                  letterSpacing: 10,
                ),
              ),
              TextField(
                onChanged: (str) {
                  newName = str;
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context, 'reName:$newName');
                },
              ),
              BlackButton(
                  str: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
      ],
    ),
  );
}

Future<dynamic> callRemove(BuildContext context) {
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
                '確定刪除嗎?',
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
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context, 'remove');
                },
              ),
              BlackButton(
                  str: '取消',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }),
            ],
          ),
        )
      ],
    ),
  );
}

Future<dynamic> callPopup(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => CallDialog(
      width: 320,
      height: 500,
      noBackground: true,
      children: [
        Expanded(
          child: Center(
            child: SliderButton(
              height: 70,
              width: 250,
              buttonSize: 55,
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.red,
              ),
              label: const Text(
                '關閉設備',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(120, 0, 0, 0),
                    letterSpacing: 10),
              ),
              boxShadow: const BoxShadow(
                  blurRadius: 5.0, color: Color.fromARGB(120, 0, 0, 0)),
              action: () {
                Navigator.pop(context);
                Navigator.pop(context, 'shutDown');
              },
            ),
          ),
        ),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 80, 200, 80),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: IconButton(
                    onPressed: () => callReName(context),
                    icon: const Icon(
                      Icons.drive_file_rename_outline,
                      size: 40,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    '重新命名',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ]),
        ),
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 100, 100),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: IconButton(
                    onPressed: () => callRemove(context),
                    icon: const Icon(
                      Icons.delete,
                      size: 40,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    '刪除設備',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
              ]),
        ),
      ],
    ),
  );
}

String limitText(String text, int maxLength) {
  if (text.length <= maxLength) {
    return text;
  } else {
    return '${text.substring(0, maxLength)}...';
  }
}
