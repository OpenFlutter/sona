class RegisterGetuiPushModel {
  final String appID;
  final String appKey;
  final String appSecret;
  final bool registerOnAndroid;
  final bool registerOnIOS;

  RegisterGetuiPushModel(
      {this.appID,
      this.appKey,
      this.appSecret,
      this.registerOnAndroid: true,
      this.registerOnIOS: true});

  get params => _mapInternal();

  Map _mapInternal() {
    return {};
  }
}
