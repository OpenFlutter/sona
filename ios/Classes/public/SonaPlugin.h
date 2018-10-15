#import <Flutter/Flutter.h>
#import "GTSDK/GeTuiSdk.h"
#import <PushKit/PushKit.h>
#import <UserNotifications/UserNotifications.h>


@interface SonaPlugin : UIResponder <FlutterPlugin, PKPushRegistryDelegate, GeTuiSdkDelegate,UNUserNotificationCenterDelegate>
+ (instancetype) sonaPlugin;
@end
