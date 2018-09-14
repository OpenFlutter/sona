import 'dart:async';

import 'package:flutter/services.dart';

import 'register_model.dart';
import 'sdk_status.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona')
  ..setMethodCallHandler(_handler);

Future<Map<dynamic, dynamic>> register(RegisterGetuiPushModel model) async {
  return await _channel.invokeMethod("register", model.params);
}

Future<String> clientID() async {
  return await _channel.invokeMethod("clientID");
}

Future turnOnPush({bool isOn: true}) async {
  return await _channel.invokeMethod("turnOnPush", isOn);
}

Future bindAlias(String alias, {String sequenceNum}) async {
  if (alias == null) {
    throw Exception("alias can't be null");
  }
  return await _channel
      .invokeMethod("bindAlias", {"alias": alias, "sequenceNum": sequenceNum});
}

Future unBindAlias(String alias, {String sn, bool isSelf}) async {
  if (alias == null) {
    throw Exception("alias can't be null");
  }
  return await _channel.invokeMethod(
      "unBindAlias", {"alias": alias, "sn": sn, "isSelf": isSelf});
}

StreamController<String> _receivedClientIDController =
    new StreamController.broadcast();

Stream<String> get receivedClientID => _receivedClientIDController.stream;

final StreamController<Map<dynamic, dynamic>> _receivedMessageDataController =
    new StreamController.broadcast();

///// listen data from getui
Stream<Map<String, dynamic>> get receivedMessageData =>
    _receivedMessageDataController.stream;

StreamController<GTSdkStatus> _receivedSdkStatusController =
    new StreamController.broadcast();

Stream<GTSdkStatus> get receivedSdkStatus =>
    _receivedSdkStatusController.stream;

Future<dynamic> _handler(MethodCall methodCall) {
  if ("onReceiveMessageData" == methodCall.method) {
    print(
        "${methodCall.arguments} -arguments ${methodCall.arguments.runtimeType}");
    _receivedMessageDataController.add(methodCall.arguments);
  } else if ("onReceiveClientId" == methodCall.method) {
    _receivedClientIDController.add(methodCall.arguments);
  } else if ("onReceiveOnlineState" == methodCall.arguments) {
    _handleSdkStatus(methodCall);
  }

  return Future.value(true);
}

_handleSdkStatus(MethodCall methodCall) {
  if ("STARTING" == methodCall.arguments) {
    _receivedSdkStatusController.add(GTSdkStatus.STARTING);
  } else if ("STARTED" == methodCall.arguments) {
    _receivedSdkStatusController.add(GTSdkStatus.STARTED);
  } else if ("OFFLINE" == methodCall.arguments) {
    _receivedSdkStatusController.add(GTSdkStatus.OFFLINE);
  } else if ("STOPPED" == methodCall.arguments) {
    _receivedSdkStatusController.add(GTSdkStatus.STOPPED);
  }
}
