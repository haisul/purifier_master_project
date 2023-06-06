import 'dart:async';

class FunctionStatus {
  String name;
  bool _state = false;
  bool _countState = false;
  int _time = 1800;
  int _countTime = 1800;
  Timer? _timer;

  FunctionStatus({
    required this.name,
    bool state = false,
    bool countState = false,
    int time = 1800,
    int countTime = 1800,
  })  : _countTime = countTime,
        _time = time,
        _countState = countState,
        _state = state;

  Timer? get timer => _timer;
  set timer(Timer? val) => _timer = val;

  bool get state => _state;
  set state(bool val) => _state = val;

  bool get countState => _countState;
  set countState(bool val) => _countState = val;

  int get time => _time;
  set time(int val) => _time = val;

  int get countTime => _countTime;
  set countTime(int val) => _countTime = val;
}

class PurFunctionStatus extends FunctionStatus {
  PurFunctionStatus({required super.name}) {
    _purModeMap = {'Auto': true, 'Sleep': false, 'Manual': false};
  }

  int _purMode = 0;

  int _fanSpeed = 10;
  late Map<String, bool> _purModeMap;

  int get fanSpeed => _fanSpeed;
  set fanSpeed(int val) => _fanSpeed = val;

  int get purMode => _purMode;
  set purMode(int val) => _purMode = val;

  void changeMode(int mode) {
    switch (mode) {
      case 0:
        _purModeMap = {'Auto': true, 'Sleep': false, 'Manual': false};
        break;
      case 1:
        _purModeMap = {'Auto': false, 'Sleep': true, 'Manual': false};
        break;
      case 2:
        _purModeMap = {'Auto': false, 'Sleep': false, 'Manual': true};
        break;
      default:
    }
    _purMode = mode;
  }
}
