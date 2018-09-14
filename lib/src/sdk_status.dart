///Android only has two kind of status:[GTSdkStatus.STARTED] and [GTSdkStatus.OFFLINE]
///Read official documents for more details.
enum GTSdkStatus{
  STARTING,  // 正在启动
  STARTED,   // 启动、在线
  STOPPED,    // 停止
  OFFLINE,   // 离线
}