import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:purmaster/library/location_data.dart';

Logger logger = Logger();

class MyWeather {
  IconData _weatherIconData = Icons.wb_sunny_outlined;
  final Map<String, dynamic> _weatherInfo = {};

  ValueNotifier<Map<String, dynamic>> weatherNotifier =
      ValueNotifier<Map<String, dynamic>>({});

  double _latitude = 0.0;
  double _longitude = 0.0;
  String _stationId = '';

  Future<bool> updateWeatherInfo() async {
    await _getLocation();
    return true;
  }

  //由經緯度取得最近測站ID
  Future _getLocation({String? emptyLocation}) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    _latitude = position.latitude;
    _longitude = position.longitude;
    print('latitude:$_latitude longitude:$_longitude');
    _stationId =
        fineStationID(_longitude, _latitude, emptyLocation: emptyLocation);
    print('最接近的地點是：$_stationId');
    await _weatherApi(_stationId);
  }

  //提交氣象資訊請求
  Future _weatherApi(String stationId) async {
    const authority = 'opendata.cwb.gov.tw';
    const unencodedPath = '/api/v1/rest/datastore/O-A0001-001';
    final queryParameters = {
      'Authorization': '',
      'stationId': stationId,
    };
    final url = Uri.https(authority, unencodedPath, queryParameters);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        if (!_convert(response.body)) {
          logger.w('data is empty');
          _getLocation(emptyLocation: stationId);
        }
      } else {
        logger.w('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      logger.w('weather api response error');
    }
  }

  bool _convert(String weatherResponse) {
    Map<String, dynamic> data = jsonDecode(weatherResponse);
    if (data.containsKey('records') &&
        data['records'].containsKey('location') &&
        data['records']['location'].isNotEmpty) {
      var location = data['records']['location'][0];
      var temp = location['weatherElement'][3]['elementValue'];
      var humd = location['weatherElement'][4]['elementValue'];
      var wdsd = location['weatherElement'][2]['elementValue'];
      var city = location['parameter'][0]['parameterValue'];
      var town = location['parameter'][2]['parameterValue'];
      var obsTime = data['records']['location'][0]['time']['obsTime'];
      var weatherState = location['weatherElement'][14]['elementValue'];

      _weatherInfo['temp'] =
          int.parse((double.tryParse(temp)!).toStringAsFixed(0));
      _weatherInfo['humd'] =
          double.tryParse((double.tryParse(humd)! * 100).toStringAsFixed(1))!;
      _weatherInfo['wdsd'] = double.tryParse(wdsd)!;
      _weatherInfo['city'] = city as String;
      _weatherInfo['town'] = town as String;
      _weatherInfo['obsTime'] = obsTime.substring(11, 13);

      int nowTime = int.parse(_weatherInfo['obsTime']);

      if (weatherState == '晴') {
        if (nowTime > 6 && nowTime < 18) {
          _weatherIconData = Icons.wb_sunny_outlined;
        } else {
          _weatherIconData = Icons.nightlight_outlined;
        }
      } else if (weatherState == '多雲') {
        if (nowTime > 6 && nowTime < 18) {
          _weatherIconData = Icons.cloud_outlined;
        } else {
          _weatherIconData = Icons.nights_stay_outlined;
        }
      } else if (weatherState == '陰') {
        _weatherIconData = Icons.cloud_outlined;
      } else if (weatherState == '陰有雨') {
        _weatherIconData = Icons.grain;
      } else if (weatherState == '陰有閃電') {
        _weatherIconData = Icons.thunderstorm_outlined;
      } else {
        if (nowTime > 6 && nowTime < 18) {
          _weatherIconData = Icons.wb_sunny_outlined;
          weatherState = '晴';
        } else {
          _weatherIconData = Icons.nightlight_outlined;
          weatherState = '晴';
        }
      }
      _weatherInfo['weatherState'] = weatherState;
      weatherNotifier.value = _weatherInfo;
      logger.i('$_weatherInfo');
      return true;
    } else {
      return false;
    }
  }

  Map<String, dynamic> get info => _weatherInfo;
  IconData get iconData => _weatherIconData;
}
