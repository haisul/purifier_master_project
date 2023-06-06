import 'package:logger/logger.dart';
import 'package:purmaster/library/mqtt_client.dart';
import 'package:purmaster/library/request_permission.dart';
import 'package:purmaster/library/user_information.dart';

Logger logger = Logger();
RequestPermission reqestPermission = RequestPermission();
UserInformation userInfo = UserInformation();
MqttClient mqttClient = MqttClient(
    host: 'ya0e11c3.ala.us-east-1.emqxsl.com',
    port: 8883,
    clientID: 'mqtt_flutter',
    pass: '33456789',
    userName: 'LJ_IEP');
