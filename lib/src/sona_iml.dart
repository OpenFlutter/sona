import 'dart:async';

import 'package:flutter/services.dart';

import 'sdk_status.dart';
import 'son_data_model.dart';

final MethodChannel _channel = const MethodChannel('com.jarvanmo/sona')
  ..setMethodCallHandler(_handler);

///[appID],[appKey] and [appSecret]  only works  on iOS because
///you have to configure these params in your build.gradle file on Android.
/// sona will register push-manager if [registerOnAndroid] or [registerOnIOS] is true
///[pushServiceName] only works on Android .GeTui allows you
/// use custom push service to ensure GeTui works well on some devices.[pushServiceName] is a full name of your
/// push service in JAVA.[pushServiceName] is not necessary.For details ,see [details](http://docs.getui.com/getui/mobile/android/androidstudio_maven/)
/// [channel] only works on iOS
Future<Map<dynamic, dynamic>> register(
    {String appID,
    String appKey,
    String appSecret,
    bool registerOnAndroid: true,
    bool registerOnIOS: true,
    String channel,
    String pushServiceName,
    bool lbsLocationEnable: false,
    bool userVerify: false}) async {
  return await _channel.invokeMethod("registerGeTui", {
    "appID": appID,
    "appKey": appKey,
    "appSecret": appSecret,
    "registerOnAndroid": registerOnAndroid,
    "registerOnIOS": registerOnIOS,
    "channel": channel,
    "pushServiceName": pushServiceName,
    "lbsLocationEnable": lbsLocationEnable,
    "userVerify": userVerify
  });
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
Stream<Map<dynamic, dynamic>> get receivedMessageData =>
    _receivedMessageDataController.stream;

StreamController<GTSdkStatus> _receivedSdkStatusController =
    new StreamController.broadcast();

Stream<GTSdkStatus> get receivedSdkStatus =>
    _receivedSdkStatusController.stream;

StreamController<OnNotificationMessageClickedModel>
    _onNotificationMessageClickedController = new StreamController.broadcast();

Stream<OnNotificationMessageClickedModel> get onNotificationMessageClicked =>
    _onNotificationMessageClickedController.stream;

dispose() {
  _receivedClientIDController.close();
  _receivedMessageDataController.close();
  _receivedSdkStatusController.close();
  _onNotificationMessageClickedController.close();
}

Future<dynamic> _handler(MethodCall methodCall) {
  if ("onReceiveMessageData" == methodCall.method) {
    _receivedMessageDataController.add(methodCall.arguments);
  } else if ("onReceiveClientId" == methodCall.method) {
    _receivedClientIDController.add(methodCall.arguments);
  } else if ("onReceiveOnlineState" == methodCall.arguments) {
    _handleSdkStatus(methodCall);
  } else if ("onNotificationMessageClicked" == methodCall.arguments) {
    _handleOnNotificationMessageClicked(methodCall);
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

_handleOnNotificationMessageClicked(MethodCall methodCall) {
  _onNotificationMessageClickedController.add(OnNotificationMessageClickedModel(
      platform: methodCall.arguments["platform"],
      appID: methodCall.arguments["appID"],
      taskID: methodCall.arguments["taskID"],
      messageID: methodCall.arguments["messageID"],
      pkgName: methodCall.arguments["pkgName"],
      content: methodCall.arguments["content"],
      title: methodCall.arguments["title"]));
}
