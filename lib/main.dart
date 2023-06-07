import 'package:flutter/material.dart';
import 'package:purmaster/pages/AddNewDevicePage/addnewdevice_page.dart';

import 'package:purmaster/pages/LoginPage/login_page.dart';
import 'package:purmaster/pages/HomePage/home_Page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:purmaster/main_models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void appInitial() async {
    reqestPermission.requestLocationPermission();
    await mqttClient.loadCaCert();
  }

  @override
  Widget build(BuildContext context) {
    appInitial();
    return MaterialApp(
      title: 'PurMaster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      routes: {
        '/loginPage': (context) => const LoginPage(),
        '/homePage': (context) => const HomePage(),
        '/addNewDevicePage': (context) => AddNewDevicePage(),
        //'/mainSettingPage': (context) => SettingPage(),
      },
    );
  }
}
