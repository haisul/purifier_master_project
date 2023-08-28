import 'package:purmaster/main_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Logger logger = Logger();

class UserInformation with UserFunction {
  final Map<String, dynamic> _info = {
    'method': '',
    'name': '',
    'pass': '',
    'email': '',
    'uid': '',
    'img': '',
  };

  String get method => _info['method'];
  String get name => _info['name'];
  String get email => _info['email'];
  String get pass => _info['pass'];
  String get uid => _info['uid'];
  String get img => _info['img'] ?? '';
  set name(String val) => _info['name'] = val;
  set img(String val) => _info['img'] = val;

  Future<bool> saveUserInfo(Map<String, dynamic>? info, bool save) async {
    if (info != null) {
      _info['method'] = info['method'];
      _info['name'] = info['name'];
      _info['email'] = info['email'];
      _info['pass'] = info['pass'];
      _info['uid'] = info['uid'];
      _info['img'] = info['img'];
      if (save) {
        String loginMethodStr = jsonEncode(_info);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('loginMethodStr', loginMethodStr);
      }
      return true;
    }
    return false;
  }

  Future<String?> loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      var loginMethodStr = prefs.getString('loginMethodStr');
      var userSetStr = prefs.getString('userSetStr');
      if (userSetStr != null) {
        Map<String, dynamic> userSet = jsonDecode(userSetStr);
        notification.set(userSet['notification']);
      }
      if (loginMethodStr != null) {
        Map<String, dynamic> loginMethod = jsonDecode(loginMethodStr);
        _info['method'] = loginMethod['method'];
        _info['name'] = loginMethod['name'];
        _info['email'] = loginMethod['email'];
        _info['pass'] = loginMethod['pass'];
        _info['uid'] = loginMethod['uid'];
        return loginMethod['method'];
      }
    } catch (e) {
      logger.e(e);
    }
    return null;
  }

  Future<void> removeUserInfo() async {
    _info['method'] = '';
    _info['name'] = '';
    _info['email'] = '';
    _info['pass'] = '';
    _info['uid'] = '';
    _info['img'] = '';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('loginMethodStr');
      logger.w('remove loginMethodStr sucess');
    } catch (e) {
      logger.e('not found loginMethodStr');
    }
  }
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

mixin UserFunction {
  late GoogleSignInAccount? googleUser;
  late UserCredential? userCredential;

  List<Map<String, dynamic>> _deviceList = [];
  set deviceList(List<Map<String, dynamic>> val) => _deviceList = val;
  List<Map<String, dynamic>> get deviceList => _deviceList;

  final FirebaseAuth _auth = FirebaseAuth.instance;

// 登入
  Future<int> login(String email, String password) async {
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _getMapFromFirestore(email);
      return 0;
    } on FirebaseAuthException catch (e) {
      logger.e('Login error: ${e.code}');
      switch (e.code) {
        case 'invalid-email':
          return 1;
        case 'user-not-found':
          return 2;
        case 'wrong-password':
          return 3;
        case 'too-many-requests':
          return 4;
        default:
          return 5;
      }
    }
  }

  //Google登入
  Future<User?> signInWithGoogle() async {
    try {
      // 1. 使用Google Sign-In獲取用戶的資訊
      googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        // 2. 使用Google用戶的資訊獲取Firebase驗證
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;

        // 3. 創建Firebase用戶的憑據
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. 使用Firebase憑據登錄
        userCredential = await _auth.signInWithCredential(credential);

        // 5. 返回Firebase用戶對象
        await _getMapFromFirestore(userCredential?.user?.email ?? "");
        return userCredential?.user;
      }
    } catch (e) {
      logger.e('error:$e');
    }
    return null;
  }

  // 註冊
  Future<int> register(String name, String email, String password) async {
    try {
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = _auth.currentUser;
      await user?.updateDisplayName(name);
      logger.i('Register success: ${userCredential?.user!.uid}');
      return 0;
    } on FirebaseAuthException catch (e) {
      logger.e('Register code:${e.code}\n error: ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          return 1;
        default:
          return 2;
      }
    }
  }

// 重置密碼
  Future<int> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      logger.i('Reset password email sent');
      return 0;
    } on FirebaseAuthException catch (e) {
      logger.e('Reset password errorCode: ${e.code}\n$e');
      switch (e.code) {
        case 'invalid-email':
          return 1;
        case 'user-not-found':
          return 2;
        default:
          return 3;
      }
    }
  }

// 登出
  Future<bool> logout() async {
    try {
      await _auth.signOut();
      if (googleUser != null) {
        googleUser = await GoogleSignIn().signOut();
      }
      _deviceList = [];
      logger.i('Logout success');
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

//刪除帳戶
  Future<bool> deletUser() async {
    try {
      await _auth.currentUser!.delete();
      if (googleUser != null) {
        googleUser = await GoogleSignIn().signOut();
      }
      return true;
    } catch (e) {
      logger.e(e);
      return false;
    }
  }

// 更改使用者名稱
  Future<bool> updateUserName(String newUserName) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.updateDisplayName(newUserName);
        userInfo.name = newUserName;
        return true;
      } on FirebaseAuthException catch (e) {
        logger.e(e.code);
      }
    }
    return false;
  }

// 更改使用者密碼
  Future<int> updatePassword(String email, String password, String newPass,
      String checkNewPass) async {
    if (newPass != checkNewPass) {
      if (newPass.length < 8 || newPass.length > 16 || !passContains(newPass)) {
        return 2;
      }
      return 1;
    }
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await user.updatePassword(newPass);
        return 0;
      } on FirebaseAuthException catch (e) {
        logger.e(e.code);
        switch (e.code) {
          case 'wrong-password':
            return 3;
          default:
            return 4;
        }
      }
    } else {
      logger.e('找不到當前使用者');
      return 4;
    }
  }

// 更改使用者頭像
  Future<void> updateUserImg(File imageFile, String email) async {
    String? imgURL;
    try {
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$email');

      // 上傳圖片到 Firebase Storage
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // 獲取上傳後的圖片 URL
      imgURL = await taskSnapshot.ref.getDownloadURL();
      logger.w(imgURL);
    } on FirebaseAuthException catch (e) {
      logger.e(e.code);
    }

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        if (imgURL != null) {
          await user.updatePhotoURL(imgURL);
          userInfo.img = imgURL;
        }
      } on FirebaseAuthException catch (e) {
        logger.e(e.code);
      }
    }
  }

  //如果使用者非自行創建帳戶的話，從這裡取得使用者資訊
  Future<Map<String, dynamic>?> getCurrentUserInfo(String method,
      {String pass = ''}) async {
    if (userCredential != null && userCredential?.user!.email != null) {
      Map<String, dynamic> info = {
        'method': method,
        'name': userCredential?.user!.displayName,
        'email': userCredential?.user!.email,
        'pass': pass,
        'uid': userCredential?.user!.uid,
        'img': userCredential?.user!.photoURL
      };
      logger.i(info);
      return info;
    }
    return null;
  }

  Future<void> _getMapFromFirestore(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection(email)
              .doc('BtnList')
              .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> dataMap = documentSnapshot.data()!;
        _deviceList =
            List<Map<String, dynamic>>.from(dataMap['deviceBtnListMap']);
      }
    } catch (e) {
      logger.e('getMapFromFirestore error message:$e');
    }
  }

  void uploadFirebase(
      List<Map<String, dynamic>> deviceBtnListMap, String email) {
    deviceList = deviceBtnListMap;
    Map<String, dynamic> dataMap = {
      'deviceBtnListMap': deviceBtnListMap,
    };
    try {
      FirebaseFirestore.instance.collection(email).doc('BtnList').set(dataMap);
    } catch (e) {
      logger.e(e);
    }
  }
}

bool passContains(String text) {
  final pattern = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).*$');
  return pattern.hasMatch(text);
}
