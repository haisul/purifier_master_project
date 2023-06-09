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
      client.onDisconnected = onDisconnected;

      final MqttConnectMessage connMess = MqttConnectMessage()
          .withClientIdentifier(clientID)
          .startClean(); // 清除之前的連線狀態
      client.connectionMessage = connMess;
      mqttMsgNotifier =
          ValueNotifier<Map<String, dynamic>>({'topic': '', 'msg': ''});
      connectedNotifier = ValueNotifier<bool>(false);
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
  late ValueNotifier<bool> connectedNotifier;
  String topic = '';
  Map<String, Map<String, dynamic>> serialMap = {};

  bool isConnected = false;

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

  void onDisconnected() {
    connectedNotifier.value = false;
  }

  Future<void> mqttConnect() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await client.connect(userName, pass);
        connectedNotifier.value = true;
        logger.i('mqtt connect success');
      } catch (e) {
        logger.e('mqtt connect error');
      }
    }
  }

  String serialNum = '';
  Future<void> onMqttCallBack() async {
    try {
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final recMess = c[0].payload as MqttPublishMessage;
          final pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          topic = c[0].topic;
          //logger.v('Topic: $topic  Message: $pt');

          if (pt.startsWith('serialNum:')) {
            serialNum = pt.replaceAll('serialNum:', '');
            addNewDeviceTopic(_userId!, serialNum);
            sendMessage(topic, 'userID:${_userId!}');
          } else if (pt.startsWith('connected')) {
            isConnected = true;
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
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
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

    subscribe(topicMap['topicEsp'], 2);
    subscribe(topicMap['topicPms'], 0);
    subscribe(topicMap['topicTimer'], 2);
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
