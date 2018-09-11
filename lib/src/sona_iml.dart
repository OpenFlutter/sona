import 'package:flutter/services.dart';
import 'dart:async';
import 'register_model.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona');

Future<Map<String,dynamic>> register(RegisterGetuiPushModel model) async{
  return await _channel.invokeMethod("register",model.params);
}

Future<Map<String,dynamic>> clientID() async{
  return await _channel.invokeMethod("clientID");
}
