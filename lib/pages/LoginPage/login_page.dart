import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purmaster/widget/custom_widget.dart';
import 'package:purmaster/pages/LoginPage/login_page_models.dart';
import 'package:provider/provider.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  final List<Widget> pageList = const [
    LoginPage0(),
    LoginPage1(),
    LoginPage2(),
    LoginPage3()
  ];

  void checkInternet(BuildContext context) async {
    await Connectivity().checkConnectivity().then((value) {
      if (value == ConnectivityResult.none) {
        callInformation(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    checkInternet(context);
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          LoginPagePageControll(context: context, pageList: pageList),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Consumer<LoginPagePageControll>(
          builder: (context, pageController, child) {
            return Scaffold(
              backgroundColor: const Color(0xffffffff),
              appBar: PurMasterAppBar(
                context: context,
                title: '淨化大師',
                centerTitle: true,
                returnButton:
                    pageController.curPage != pageList[0] ? true : false,
                onPressed: () => pageController.changePage(0),
              ),
              body: pageController.curPage,
            );
          },
        ),
      ),
    );
  }
}

////////////////////Page1(login)////////////////////

class LoginPage0 extends StatefulWidget {
  const LoginPage0({super.key});
  @override
  State<LoginPage0> createState() => _LoginPage0State();
}

class _LoginPage0State extends State<LoginPage0> {
  String? email, password;

  @override
  Widget build(BuildContext context) {
    Provider.of<LoginPagePageControll>(context, listen: false).autoLogin();
    var loginCard = CardWidget(
      width: 320,
      height: 300,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '登入',
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
                '帳號',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(
                height: 20,
                width: 250,
                child: TextField(
                  onChanged: (str) {
                    email = str;
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
                onChanged: (str) {
                  password = str;
                },
              ),
            ],
          ),
        ),
        SizedBox(
          width: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Checkbox(
                        value:
                            context.watch<LoginPagePageControll>().isKeepLogin,
                        onChanged: (value) => context
                            .read<LoginPagePageControll>()
                            .keepLogin(value),
                      ),
                      const Text(
                        '保持登入',
                        style: TextStyle(
                            fontSize: 12, color: Color.fromARGB(180, 0, 0, 0)),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        context.read<LoginPagePageControll>().changePage(2),
                    child: const Text(
                      '忘記密碼?',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            loginCard,
            Container(
              margin: const EdgeInsets.only(top: 55),
              child: GoogleButton(
                str: 'Log in with Google',
                onPress: () =>
                    Provider.of<LoginPagePageControll>(context, listen: false)
                        .googleLoginButton(),
              ),
            ),
            Container(
              width: 250,
              margin: const EdgeInsets.only(top: 50, bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NormalButton(
                    str: '登入',
                    onPressed: () => Provider.of<LoginPagePageControll>(context,
                            listen: false)
                        .emailLoginButton(email, password),
                  ),
                  NormalButton(
                    str: '註冊帳號',
                    onPressed: () =>
                        context.read<LoginPagePageControll>().changePage(1),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////Page2(sign up)////////////////////

class LoginPage1 extends StatefulWidget {
  const LoginPage1({
    super.key,
  });

  @override
  State<LoginPage1> createState() => _LoginPage1State();
}

class _LoginPage1State extends State<LoginPage1> {
  String? name, email, password, confirmPassword;
  CardWidget loginCard() {
    return CardWidget(
      width: 320,
      height: 400,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '註冊帳號',
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
              SizedBox(
                height: 20,
                width: 250,
                child: TextField(
                  onChanged: (str) {
                    name = str;
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
        Container(
          margin: const EdgeInsets.only(top: 30),
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E-Mail',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(
                height: 20,
                width: 250,
                child: TextField(
                  onChanged: (str) {
                    email = str;
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
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '設定密碼',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(
                onChanged: (str) => password = str,
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          margin: const EdgeInsets.only(top: 30, bottom: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '密碼確認',
                style: TextStyle(fontSize: 12),
              ),
              PasswordInput(
                onChanged: (str) => confirmPassword = str,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            loginCard(),
            Container(
              margin: const EdgeInsets.only(top: 50, bottom: 50),
              child: NormalButton(
                str: '註冊',
                onPressed: () => context
                    .read<LoginPagePageControll>()
                    .regist(name, email, password, confirmPassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////Page3(forget password)////////////////////

class LoginPage2 extends StatefulWidget {
  const LoginPage2({
    super.key,
  });

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  String? email;

  CardWidget loginCard() {
    return CardWidget(
      width: 320,
      height: 300,
      children: [
        const Align(
          alignment: Alignment.topRight,
          child: Text(
            '忘記密碼',
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          height: 100,
          width: 260,
          margin: const EdgeInsets.only(top: 30),
          child: const Text(
            '讓我們幫您恢復帳號存取\n請提供註冊e-mail\n系統將寄送重設密碼郵件至您的信箱\n(若未收到郵件，請檢查垃圾信件夾)',
            style: TextStyle(fontSize: 14, letterSpacing: 1.5, height: 1.8),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          height: 50,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E-Mail',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(
                height: 20,
                width: 250,
                child: TextField(
                  onChanged: (str) {
                    email = str;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            loginCard(),
            Container(
              height: 45,
              margin: const EdgeInsets.only(top: 55),
            ),
            Container(
              margin: const EdgeInsets.only(top: 50, bottom: 50),
              child: NormalButton(
                str: '重設密碼',
                onPressed: () =>
                    context.read<LoginPagePageControll>().resetPass(email),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////Page4(sign up complete)////////////////////

class LoginPage3 extends StatefulWidget {
  const LoginPage3({
    super.key,
  });

  @override
  State<LoginPage3> createState() => _LoginPage3State();
}

class _LoginPage3State extends State<LoginPage3> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      Provider.of<LoginPagePageControll>(context, listen: false).changePage(0);
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            '註冊完成\n請重新登入',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(120, 0, 0, 0),
              letterSpacing: 10,
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

Future<void> callInformation(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CallDialog(width: 320, height: 200, children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.error_outline_rounded, size: 80),
              Text(
                '請開啟網路',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(180, 0, 0, 0)),
              )
            ],
          ),
        )
      ]);
    },
  );
}
