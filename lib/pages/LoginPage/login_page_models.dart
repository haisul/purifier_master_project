import 'package:purmaster/main_models.dart';
import 'package:flutter/material.dart';
import 'package:purmaster/widget/custom_widget.dart';

class LoginPagePageControll with ChangeNotifier {
  BuildContext context;
  List<Widget> pageList;
  LoginPagePageControll({required this.context, required this.pageList});

  late Widget curPage = pageList[0];
  void changePage(int page) {
    curPage = pageList[page];
    notifyListeners();
  }

  bool isKeepLogin = true;

  Future<bool> loginWithEmail(String? email, String? password) async {
    if (email == null) {
      CustomSnackBar.show(context, '請輸入帳號');
    } else if (password == null) {
      CustomSnackBar.show(context, '請輸入密碼');
    } else if (password.length < 8 || password.length > 16) {
      CustomSnackBar.show(context, '請輸入8~16位英文數字密碼');
    } else {
      return userInfo.login(email, password).then((errorCode) async {
        String msg = '';
        switch (errorCode) {
          case 0:
            Map<String, dynamic>? info =
                await userInfo.getCurrentUserInfo('email', pass: password);
            return userInfo
                .saveUserInfo(info!, isKeepLogin)
                .then((value) => value);
          case 1:
            msg = 'e-mail格式錯誤';
            break;
          case 2:
            msg = '此帳號尚未註冊';
            break;
          case 3:
            msg = '密碼錯誤';
            break;
          case 4:
            msg = '伺服器錯誤，請稍後再試';
            break;
          case 5:
            msg = '錯誤';
            break;
        }
        CustomSnackBar.show(context, msg);
        return false;
      });
    }
    return false;
  }

  Future<bool> loginWithGoogle() async {
    await userInfo.signInWithGoogle();
    Map<String, dynamic>? info = await userInfo.getCurrentUserInfo('google');
    bool result = await userInfo.saveUserInfo(info!, isKeepLogin);
    mqttClient.userId = userInfo.email;
    await mqttClient.mqttConnect();
    await mqttClient.onMqttCallBack();
    if (result) {
      return true;
    } else {
      return false;
    }
  }

  void regist(
      String? name, String? email, String? password, String? confirmPassword) {
    if (name != null &&
        email != null &&
        password != null &&
        confirmPassword != null) {
      if (!email.contains('@')) {
        CustomSnackBar.show(context, 'E-Mail格式不正確');
      } else if (password.length < 8 ||
          password.length > 16 ||
          !_passContains(password)) {
        CustomSnackBar.show(context, '請輸入8~16位英文數字密碼');
      } else if (password != confirmPassword) {
        CustomSnackBar.show(context, '密碼不一致');
      } else {
        userInfo.register(name, email, password).then((value) {
          if (value == 0) {
            changePage(3);
          } else if (value == 1) {
            CustomSnackBar.show(context, 'e-mail已註冊');
          } else {
            CustomSnackBar.show(context, '錯誤');
          }
        });
      }
    } else {
      if (name == null) {
        CustomSnackBar.show(context, '請輸入使用者名稱');
        return;
      }
      if (email == null) {
        CustomSnackBar.show(context, '請輸入E-Mail');
        return;
      }
      if (password == null) {
        CustomSnackBar.show(context, '請輸入密碼');
        return;
      }
      if (confirmPassword == null) {
        CustomSnackBar.show(context, '請輸入密碼確認');
        return;
      }
    }
  }

  void resetPass(email) {
    if (email == null) {
      CustomSnackBar.show(context, '請輸入E-Mail');
      return;
    }
    userInfo.resetPassword(email).then((value) {
      switch (value) {
        case 0:
          CustomSnackBar.show(context, '請至信箱收取新密碼', level: 0);
          break;
        case 1:
          CustomSnackBar.show(context, 'e-mail格式錯誤');
          return;
        case 2:
          CustomSnackBar.show(context, '此e-mail尚未註冊');
          return;
        default:
          CustomSnackBar.show(context, '錯誤');
          return;
      }

      changePage(0);
    });
  }

  void keepLogin(val) {
    isKeepLogin = val;
    if (!val) {
      userInfo.removeUserInfo();
    }
    notifyListeners();
  }

  bool _passContains(String text) {
    final pattern = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).*$');
    return pattern.hasMatch(text);
  }

  Future<void> autoLogin() async {
    String? method = await userInfo.loadUserInfo();
    if (method == 'google') {
      googleLoginButton();
    } else if (method == 'email') {
      emailLoginButton(userInfo.email, userInfo.pass);
      logger.e(method);
    } else {
      return;
    }
  }

  Future<void> emailLoginButton(String? email, String? password) async {
    LoadingDialog.show(context, description: '登入中');
    bool result = await loginWithEmail(email, password);
    // ignore: use_build_context_synchronously
    LoadingDialog.hide(context);
    if (result) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/homePage',
        (route) => false,
      );
    }
  }

  Future<void> googleLoginButton() async {
    LoadingDialog.show(context, description: '登入中');
    bool result = await loginWithGoogle();
    // ignore: use_build_context_synchronously
    LoadingDialog.hide(context);
    if (result) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/homePage',
        (route) => false,
      );
    }
  }
}
