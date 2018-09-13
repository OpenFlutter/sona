import 'dart:async';

import 'package:flutter/services.dart';

import 'register_model.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona')
  ..setMethodCallHandler(_handler);

Future<Map<dynamic, dynamic>> register(RegisterGetuiPushModel model) async {
  return await _channel.invokeMethod("register", model.params);
}

Future<String> clientID() async {
  return await _channel.invokeMethod("clientID");
}

Future turnOnPush({bool isOn:true}) async{
  return await _channel.invokeMethod("turnOnPush",isOn);
}



Future bindAlias(String alias,{String sn})async{
  if(alias == null ){
    throw Exception("alias can't be null");
  }
  return await _channel.invokeMethod("bindAlias",{"alias":alias,"sn":sn});
}

Future unBindAlias(String alias,{String sn,bool isSeft})async{
  if(alias == null ){
    throw Exception("alias can't be null");
  }
  return await _channel.invokeMethod("unBindAlias",{"alias":alias,"sn":sn,"isSeft":isSeft});
}

StreamController<String> _receivedClientIDController =
    new StreamController.broadcast();

Stream<String> get receivedClientID => _receivedClientIDController.stream;

final StreamController<Map<dynamic, dynamic>> _receivedMessageDataController =
    new StreamController.broadcast();

///// listen data from getui
//Stream<Map<String, dynamic>> get receivedMessageData =>
//    _receivedMessageDataController.stream;

StreamController<bool> _receivedOnlineStateController =
    new StreamController.broadcast();

Stream<bool> get receivedOnlineState => _receivedOnlineStateController.stream;

Future<dynamic> _handler(MethodCall methodCall) {

  if ("onReceiveMessageData" == methodCall.method) {
    print("${methodCall.arguments} -arguments ${methodCall.arguments.runtimeType}");
    _receivedMessageDataController.add(methodCall.arguments);
  } else if ("onReceiveClientId" == methodCall.method) {
    _receivedClientIDController.add(methodCall.arguments);
  } else if ("onReceiveOnlineState" == methodCall.arguments) {
    _receivedOnlineStateController.add(methodCall.arguments);
  }

  return Future.value(true);
}

