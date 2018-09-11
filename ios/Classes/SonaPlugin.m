#import "SonaPlugin.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@implementation SonaPlugin
+ (void)registerWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel *channel = [FlutterMethodChannel
            methodChannelWithName:@"com.jarvanmo/sona"
                  binaryMessenger:[registrar messenger]];
    SonaPlugin *instance = [[SonaPlugin alloc] initInternal];
    [registrar addMethodCallDelegate:instance channel:channel];
}


BOOL isRgisterGetuiBySona = YES;

+ (BOOL)registerGetuiPushBySona {
    return isRgisterGetuiBySona;
}

+ (void)setRegisterGetuiPushBySona:(BOOL)registerGetuiPushBySona {
    isRgisterGetuiBySona = registerGetuiPushBySona;
}


- (instancetype)initInternal {
    self = [super init];
    if (self) {

    }

    return self;
}


- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"register" isEqualToString:call.method]) {
        [self registerGetui:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }


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


    // 注册APNs - custom method - 开发者自定义的方法
    [self registerRemoteNotification];

    // 注册VOIP
    [self voipRegistration];
}

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

#pragma mark - VOIP 接入

/** 注册VOIP服务 */
- (void)voipRegistration {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    PKPushRegistry *voipRegistry = [[PKPushRegistry alloc] initWithQueue:mainQueue];
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
}



- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)pushCredentials forType:(PKPushType)type {
}
@end
