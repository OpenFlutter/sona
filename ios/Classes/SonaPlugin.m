#import "SonaPlugin.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

#import <UserNotifications/UserNotifications.h>

#endif

@implementation SonaPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"com.jarvanmo/sona"
                  binaryMessenger:[registrar messenger]];
    SonaPlugin *instance = [SonaPlugin sonaPlugin];
    [instance setMethodChannel:channel];
    [registrar addMethodCallDelegate:instance channel:channel];
}

FlutterMethodChannel *methodChannel;

BOOL isRgisterGetuiBySona = YES;
const NSString *keyAlias = @"alias";

+ (BOOL)registerGetuiPushBySona {
    return isRgisterGetuiBySona;
}

+ (void)setRegisterGetuiPushBySona:(BOOL)registerGetuiPushBySona {
    isRgisterGetuiBySona = registerGetuiPushBySona;
}

#pragma mark - LifeCycle

+ (instancetype)sonaPlugin {
    static dispatch_once_t onceToken;
    static SonaPlugin *instance;
    dispatch_once(&onceToken, ^{
        instance = [[SonaPlugin alloc] init];

    });
    return instance;
}

- (void)setMethodChannel:(FlutterMethodChannel *)channel {
    methodChannel = channel;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"register" isEqualToString:call.method]) {
        [self registerGetui:call result:result];
    } else if ([@"turnOnPush" isEqualToString:call.method]) {
        [self turnOnPush:call result:result];
    } else if ([@"bindAlias" isEqualToString:call.method]) {
        [self bindAlias:call result:result];
    } else if ([@"unBindAlias" isEqualToString:call.method]) {
        [self unBindAlias:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }


}

- (void)bindAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *aliasFromSona = call.arguments[keyAlias];


    NSString *sn = call.arguments[@"sequenceNum"];

    if ([StringUtil isBlank:sn]) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval time = [currentDate timeIntervalSince1970] * 1000;// *1000 是精确到毫秒，不乘就是精确到秒
        NSString *timeString = [NSString stringWithFormat:@"bindAlias_%.0f", time];
        sn = timeString;
    }

    [GeTuiSdk bindAlias:aliasFromSona andSequenceNum:sn];

    result(@YES);
}

- (void)unBindAlias:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *aliasFromSona = call.arguments[keyAlias];


    NSString *sn = call.arguments[@"sequenceNum"];

    if ([StringUtil isBlank:sn]) {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval time = [currentDate timeIntervalSince1970] * 1000;
        NSString *timeString = [NSString stringWithFormat:@"bindAlias_%.0f", time];
        sn = timeString;
    }

    BOOL isSelf = [call.arguments[@"isSelf"] boolValue];
    [GeTuiSdk unbindAlias:aliasFromSona andSequenceNum:sn andIsSelf:isSelf];

    result(@YES);
}

- (void)turnOnPush:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL isOn = [call.arguments boolValue];
    [GeTuiSdk setPushModeForOff:!isOn];
    result(@YES);
}

- (void)registerGetui:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL registerOnIOS = [call.arguments[@"registerOnIOS"] boolValue];

    if (!registerOnIOS) {
        result(@{
                @"platform": @"iOS",
                @"result": @YES
        });
        return;
    }

    NSString *kGtAppId = call.arguments[@"appID"];
    NSString *kGtAppKey = call.arguments[@"appKey"];
    NSString *kGtAppSecret = call.arguments[@"appSecret"];
    if ([StringUtil isBlank:kGtAppId] || [StringUtil isBlank:kGtAppKey] || [StringUtil isBlank:kGtAppSecret]) {
        result([FlutterError errorWithCode:@"invalid appID,appKey,or appSecret"
                                   message:@"these params can't be blank,have a check please!"
                                   details:[NSString stringWithFormat:@"appID=%@,appKey=%@,appSecret=%@", kGtAppId, kGtAppKey, kGtAppSecret]]);
        return;
    }

    NSString *channel = call.arguments[@"channel"];
    if (![StringUtil isBlank:channel]) {
        [GeTuiSdk setChannelId:channel];
    }

    BOOL lbsLocationEnable = [call.arguments[@""] boolValue];
    BOOL userVerify = [call.arguments[@"userVerify"] boolValue];
    [GeTuiSdk lbsLocationEnable:lbsLocationEnable andUserVerify:userVerify];


    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];

    [GeTuiSdk setPushModeForOff:NO];
    // 注册APNs - custom method - 开发者自定义的方法
    [self registerRemoteNotification];

    // 注册VOIP
    [self voipRegistration];
}

#pragma mark - 用户通知(推送) _自定义方法

/** 注册远程通知 */
- (void)registerRemoteNotification {
    /*
     警告：Xcode8的需要手动开启“TARGETS -> Capabilities -> Push Notifications”
     */

    /*
        警告：该方法需要开发者自定义，以下代码根据APP支持的iOS系统不同，代码可以对应修改。
        以下为演示代码，注意根据实际需要修改，注意测试支持的iOS系统都能获取到DeviceToken
     */
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0 // Xcode 8编译会调用
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];

        [[UIApplication sharedApplication] registerForRemoteNotifications];
#else // Xcode 7编译会调用
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
#endif
    } else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType) (UIRemoteNotificationTypeAlert |
                UIRemoteNotificationTypeSound |
                UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
}

#pragma mark - 远程通知(推送)回调

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);

    // [ GTSdk ]：向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** 远程通知注册失败委托 */
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"\n>>>[DeviceToken Error]:%@\n\n", error.description);
}

#pragma mark - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (BOOL)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];

    // 控制台打印接收APNs信息
    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);

    completionHandler(UIBackgroundFetchResultNewData);

    return YES;
}

#pragma mark - iOS 10中收到推送消息

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {

    NSLog(@"willPresentNotification：%@", notification.request.content.userInfo);

    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {

    NSLog(@"didReceiveNotification：%@", response.notification.request.content.userInfo);

    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];

    completionHandler();
}

#endif

#pragma mark - VOIP 接入

/** 注册VOIP服务 */
- (void)voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}

// 实现 PKPushRegistryDelegate 协议方法

/** 系统返回VOIPToken，并提交个推服务器 */
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(NSString *)type {
    NSString *voiptoken = [credentials.token.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    voiptoken = [voiptoken stringByReplacingOccurrencesOfString:@" " withString:@""];

    //向个推服务器注册 VoipToken
    [GeTuiSdk registerVoipToken:voiptoken];
}

/** 接收VOIP推送中的payload进行业务逻辑处理（一般在这里调起本地通知实现连续响铃、接收视频呼叫请求等操作），并执行个推VOIP回执统计 */
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
    //个推VOIP回执统计
    [GeTuiSdk handleVoipNotification:payload.dictionaryPayload];

    //TODO:接受VOIP推送中的payload内容进行具体业务逻辑处理
    NSLog(@"[Voip Payload]:%@,%@", payload, payload.dictionaryPayload);
}


#pragma mark - GeTuiSdkDelegate

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    // [4-EXT-1]: 个推SDK已注册，返回clientId
    NSLog(@"\n>>[GTSdk RegisterClient]:%@\n\n", clientId);
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    // [EXT]:个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>[GTSdk error]:%@\n\n", [error localizedDescription]);
}


/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
//    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];

    NSDictionary *commonResult = @{
            @"appID": appId,
            @"taskID": taskId,
            @"messageID": msgId,
            @"offLine": @(offLine),

    };


    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:commonResult];
    // 数据转换
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
        result[@"payload"] = payloadMsg;
    }

    [methodChannel invokeMethod:@"onReceiveMessageData" arguments:result];
}

/** SDK收到sendMessage消息回调 */
- (void)GeTuiSdkDidSendMessage:(NSString *)messageId result:(int)result {
    // 发送上行消息结果反馈
    NSString *msg = [NSString stringWithFormat:@"sendmessage=%@,result=%d", messageId, result];
    NSLog(@"\n>>[GTSdk DidSendMessage]:%@\n\n", msg);
}

/** SDK运行状态通知 */
- (void)GeTuiSDkDidNotifySdkState:(SdkStatus)aStatus {
    // 通知SDK运行状态
    NSLog(@"\n>>[GTSdk SdkState]:%u\n\n", aStatus);

    NSString *argument = @"STARTED";
    if (aStatus == SdkStatusStarting) {
        argument = @"STARTING";
    } else if (aStatus == SdkStatusOffline) {
        argument = @"OFFLINE";
    } else if (aStatus == SdkStatusStoped) {
        argument = @"STOPPED";
    }

    [methodChannel invokeMethod:@"onReceiveOnlineState" arguments:argument];

}

/** SDK设置推送模式回调 */
- (void)GeTuiSdkDidSetPushMode:(BOOL)isModeOff error:(NSError *)error {
    if (error) {
        NSLog(@"\n>>[GTSdk SetModeOff Error]:%@\n\n", [error localizedDescription]);
        return;
    }

    NSLog(@"\n>>[GTSdk SetModeOff]:%@\n\n", isModeOff ? @"开启" : @"关闭");
}

@end
