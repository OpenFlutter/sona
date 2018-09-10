import 'package:flutter/services.dart';
import 'dart:async';
import 'register_model.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona');

Future register(RegisterGetuiPushModel model) async{
  return await _channel.invokeMethod("register",model.params);
}

