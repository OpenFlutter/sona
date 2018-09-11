///[appID],[appKey] and [appSecret]  only works  on iOS because
///you have to configure these params in your build.gradle file on Android.
/// sona will register push-manager if [registerOnAndroid] or [registerOnIOS] is true
///[pushServiceName] only works on Android .GeTui allows you
/// use custom push service to ensure GeTui works well on some devices.[pushServiceName] is a full name of your
/// push service in JAVA.[pushServiceName] is not necessary.For details ,see [details](http://docs.getui.com/getui/mobile/android/androidstudio_maven/)
class RegisterGetuiPushModel {
  final String appID;
  final String appKey;
  final String appSecret;
  final bool registerOnAndroid;
  final bool registerOnIOS;

  final String pushServiceName;

  RegisterGetuiPushModel(
      {this.appID,
      this.appKey,
      this.appSecret,
      this.registerOnAndroid: true,
      this.registerOnIOS: true,
      this.pushServiceName});

  get params => _mapInternal();

  Map _mapInternal() {
    return {};
  }
}
