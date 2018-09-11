//
// Created by mo on 2018/9/11.
//

#import "RegisterHandler.h"


@implementation RegisterHandler

- (void)registerGetui:(FlutterMethodCall *)call result:(FlutterResult)result {
    BOOL registerOnIOS= [call.arguments[@"registerOnIOS"] boolValue];

    if(!registerOnIOS){
        return;
    }

}
@end