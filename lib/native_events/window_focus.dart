import 'package:flutter/services.dart';

typedef WindowFocusChangeFunction = void Function(bool);

class EventChannelWindowFocus {
  static const MethodChannel _channel =
      const MethodChannel('floss.myzel394.relieve/window_focus');
  static List<Function> _listeners = [];

  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'windowFocusChanged') {
        for (var listener in _listeners) {
          listener(call.arguments as bool);
        }
      }

      return null;
    });
  }

  static void addListener(final WindowFocusChangeFunction listener) {
    _listeners.add(listener);
  }

  static void removeListener(final WindowFocusChangeFunction listener) {
    _listeners.remove(listener);
  }
}
