//
//  WZMAppJump.m
//  WZMFoundation
//
//  Created by wangzhaomeng on 16/8/18.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMAppJump.h"
#import <StoreKit/StoreKit.h>
#import "WZMAlertView.h"
#import "WZMDefined.h"
#import "WZMBase64.h"

@interface WZMAppJump ()<SKStoreProductViewControllerDelegate>

@end

@implementation WZMAppJump

+ (WZMAppJump *)shareJump {
    static WZMAppJump* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WZMAppJump alloc] init];
    });
    return instance;
}

//判断APP是否第一次启动
+ (BOOL)checkAppIsFirstLaunch:(NSString *)key {
    BOOL firstStart = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (!firstStart) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return !firstStart;
}

//拨打指定电话
+ (void)callTelePhone:(NSString *)phone {
#if WZM_APP
    NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"telprompt://%@",phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
#endif
}

//打开链接
+ (BOOL)openUrlStr:(NSString *)urlStr{
#if WZM_APP
    NSURL *url = [NSURL URLWithString:urlStr];
    BOOL  canOpen = [[UIApplication sharedApplication] canOpenURL:url];
    if (canOpen) {
        [[UIApplication sharedApplication] openURL:url];
    }
    return canOpen;
#endif
    return NO;
}

//打开APP设置界面
+ (void)openAPPSetting{
#if WZM_APP
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
#endif
}

//打开QQ私聊界面
+ (BOOL)QQChatToUser:(NSString *)account{
#if WZM_APP
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=wpa&uin=%@&version=1&src_type=web", account]];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    return NO;
#endif
    return NO;
}

+ (BOOL)QQJoinGroup:(NSString *)group key:(NSString *)key {
#if WZM_APP
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", group,key];
    NSURL *url = [NSURL URLWithString:urlStr];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    else return NO;
#endif
    return NO;
}

//打开应用
+ (BOOL)openAppWithAppType:(WZMAPPType)type {
    NSString *APPSchemeName = [[self getAPPSchemeName:type] wzm_base64DecodedString];
    if ([self checkIfAppInstalled:APPSchemeName]) {
        [self openAppWithAppScheme:APPSchemeName];
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)checkIfAppInstalled:(NSString *)appScheme{
#if WZM_APP
    BOOL a = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", appScheme]]];
    return a;
#endif
    return NO;
}

+ (BOOL)openAppWithAppScheme:(NSString *)appScheme{
#if WZM_APP
    BOOL a = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", appScheme]]];
    return a;
#endif
    return NO;
}

+ (NSString *)getAPPSchemeName:(WZMAPPType)type{
    switch (type) {
        case 0:  return @"bXFxOi8v";
        case 1:  return @"d2VpeGluOi8v";
        case 2:  return @"c2luYXdlaWJvOi8v";
        case 3:  return @"YWxpcGF5Oi8v";
        case 4:  return @"dGFvYmFvOi8v";
        default: return @"";
    }
}

//AppStore评论
+ (void)openAppStoreScore:(NSString *)appId type: (WZMAppStoreType)type{
    if (type == WZMAppStoreTypeOpen) {
        [self wzm_AppStoreScoreOpen:appId];
    }
    else {
        [self wzm_AppStoreScoreInApp:appId];
    }
}

+ (void)wzm_AppStoreScoreOpen:(NSString *)appId {
#if WZM_APP
    NSString *store = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",appId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:store]];
#endif
}

+ (void)wzm_AppStoreScoreInApp:(NSString *)appId {
#if WZM_APP
    if (@available(iOS 10.3, *)) {
        if([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            [SKStoreReviewController requestReview];
        }
    }
    else {
        [self wzm_AppStoreScoreOpen:appId];
    }
#endif
}

//AppStore下载
+ (void)openAppStoreDownload:(NSString *)appId type: (WZMAppStoreType)type{
    if (type == WZMAppStoreTypeOpen) {
        [WZMAppJump openAppStoreDownloadInAppStore:appId];
    }
    else {
        [[WZMAppJump shareJump] openAppStoreDownloadInInnerApp:appId];
    }
}

+ (void)openAppStoreDownloadInAppStore:(NSString *)appId{
#if WZM_APP
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appId]]];
#endif
}

- (void)openAppStoreDownloadInInnerApp:(NSString *)appId{
#if WZM_APP
    SKStoreProductViewController *sc = [[SKStoreProductViewController alloc] init];
    sc.delegate = self;
    UIViewController* presentingCtrl = [UIApplication sharedApplication].delegate.window.rootViewController;
    if (presentingCtrl.presentedViewController) {
        presentingCtrl = presentingCtrl.presentedViewController;
    }
    [sc loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier:appId}
                  completionBlock:^(BOOL result, NSError *error) {
                      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                      if (error) {
                          //没有打开内部App Store弹窗
                          if (presentingCtrl.presentedViewController == sc) {
                              WZMAlertView *alertView = [[WZMAlertView alloc] initWithTitle:@"温馨提示" message:@"无法显示该应用,是否跳转到AppStore内查看" OKButtonTitle:@"确定" cancelButtonTitle:@"取消" type:WZMAlertViewTypeNormal];
                              [alertView setOKBlock:^{
                                  [WZMAppJump openAppStoreDownloadInAppStore:appId];
                              }];
                              [alertView showAnimated:YES];
                          }
                      }
                  }];
    [presentingCtrl presentViewController:sc animated:YES completion:nil];
#endif
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
