import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Logger logger = Logger();

class MqttClient {
  MqttClient({
    required this.host,
    required this.port,
    required this.clientID,
    required this.pass,
    required this.userName,
  }) {
    try {
      client = MqttServerClient.withPort(host, clientID, port);
      client.secure = true;
      client.logging(on: false);
      client.keepAlivePeriod = 30; // 保持連線的時間間隔（秒）
      client.autoReconnect = true; // 啟用自動重連

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(clientID)
          .startClean(); // 清除之前的連線狀態
      client.connectionMessage = connMess;
      mqttMsgNotifier =
          ValueNotifier<Map<String, dynamic>>({'topic': '', 'msg': ''});
    } catch (e) {
      logger.e(e);
    }
  }
  final String host, clientID, pass, userName;
  final int port;
  late final MqttServerClient client;

  String? _userId;
  set userId(String str) {
    _userId = str;
  }

  late ValueNotifier<Map<String, dynamic>> mqttMsgNotifier;
  String topic = '';
  Map<String, Map<String, dynamic>> serialMap = {};

  String serialNum = '';
  bool _isConnected = false;

  Future loadCaCert() async {
    try {
      String caCertFile =
          await rootBundle.loadString('assets/CAfiles/emqxsl-ca.crt');
      client.securityContext.setTrustedCertificatesBytes(caCertFile.codeUnits);
      logger.i('load caCert success');
    } catch (e) {
      logger.e('mqtt connect error: $e');
    }
  }

  Future<void> mqttConnect() async {
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientID)
        .startClean(); // 清除之前的連線狀態
    client.connectionMessage = connMess;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await client.connect(userName, pass);
        logger.i('mqtt connect success');
      } catch (e) {
        logger.e('mqtt connect error');
      }
    }
  }

  Future<void> onMqttCallBack() async {
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final recMess = c[0].payload as MqttPublishMessage;
          final pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          topic = c[0].topic;
          logger.v('Topic: $topic  Message: $pt');

          if (pt.startsWith('serialNum:')) {
            serialNum = pt.replaceAll('serialNum:', '');
            addNewDeviceTopic(_userId!, serialNum);
            sendMessage(topic, 'userID:${_userId!}');
          } else if (pt.startsWith('connected')) {
            _isConnected = true;
          } else {
            mqttMsgNotifier.value = {'topic': topic, 'msg': pt};
            mqttMsgNotifier.value = {'topic': '', 'msg': ''};
          }
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  void sendMessage(String topic, String msg) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    logger.i('Topic:$topic\nMsg:$msg');
  }

  Future<bool> subscribe(String topic, int qos) async {
    MqttQos mqttqos = MqttQos.atLeastOnce;
    switch (qos) {
      case 0:
        mqttqos = MqttQos.atMostOnce;
        break;
      case 1:
        mqttqos = MqttQos.atLeastOnce;
        break;
      case 2:
        mqttqos = MqttQos.exactlyOnce;
        break;
      default:
        break;
    }
    Completer<bool> completer = Completer<bool>();
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      await MqttUtilities.asyncSleep(1);
      client.subscribe(topic, mqttqos);
      completer.complete(true);
    } else {
      logger.e(
          'ERROR client connection failed - disconnecting, state is ${client.connectionStatus?.state}');
      completer.complete(false);
    }
    return await completer.future;
  }

  Future<bool> unSubscribe(String topic) async {
    Completer<bool> completer = Completer<bool>();
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      await MqttUtilities.asyncSleep(1);
      client.unsubscribe(topic);
      completer.complete(true);
    } else {
      logger.e(
          'ERROR client connection failed - disconnecting, state is ${client.connectionStatus?.state}');
      completer.complete(false);
    }
    return await completer.future;
  }

  Future<bool> initialConnection(String topic) async {
    StreamSubscription<bool>? subscription;
    Completer<bool> completer = Completer<bool>();
    subscribe(topic, 0);

    Stream<bool> stream = Stream<bool>.periodic(
            const Duration(milliseconds: 500), (_) => _isConnected)
        .take(120); //1min

    subscription = stream.listen((isConnected) {
      if (isConnected) {
        completer.complete(true);
        subscription!.cancel();
      }
    }, onDone: () {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      unSubscribe(topic);
      _isConnected = false;
      serialNum = '';
    });

    return completer.future;
  }

  void addNewDeviceTopic(String userId, String serialNum) {
    Map<String, dynamic> topicMap = {
      'topicApp': '',
      'topicEsp': '',
      'topicPms': '',
      'topicTimer': ''
    };
    topicMap['topicApp'] = '$userId/$serialNum/app';
    topicMap['topicEsp'] = '$userId/$serialNum/esp';
    topicMap['topicPms'] = '$userId/$serialNum/pms';
    topicMap['topicTimer'] = '$userId/$serialNum/timer';

    serialMap[serialNum] = topicMap;

    subscribe(topicMap['topicEsp'], 1);
    subscribe(topicMap['topicPms'], 0);
    subscribe(topicMap['topicTimer'], 0);
    logger.i(topicMap);
  }

  void removeDeviceTopic(String serialNum) {
    if (serialMap.keys.contains(serialNum)) {
      Map<String, dynamic>? innerMap = serialMap[serialNum];
      innerMap!.forEach((key, value) {
        unSubscribe(innerMap[key]);
      });
    }
    serialMap.remove(serialNum);
  }

  void disconnect() async {
    client.disconnect();
    logger.i('mqtt disconnected');
  }
}
