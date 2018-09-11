import 'package:flutter/services.dart';
import 'dart:async';
import 'register_model.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona')
                                ..setMethodCallHandler(_handler);

Future<Map<String,dynamic>> register(RegisterGetuiPushModel model) async{
  return await _channel.invokeMethod("register",model.params);
}

Future<Map<String,dynamic>> clientID() async{
  return await _channel.invokeMethod("clientID");
}










StreamController<Map<String,dynamic>> _receivedMessageDataController =
new StreamController.broadcast();

/// listen received data from getui
Stream<Map<String,dynamic>> get receivedMessageData => _receivedMessageDataController.stream;

Future<dynamic> _handler(MethodCall methodCall) {
  if ("onReceiveMessageData" == methodCall.method) {
    _receivedMessageDataController.add(methodCall.arguments);
  }

  return Future.value(true);
}
