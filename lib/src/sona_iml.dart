import 'package:flutter/services.dart';
import 'dart:async';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona');

Future register() async{
  return await _channel.invokeMethod("register","");
}