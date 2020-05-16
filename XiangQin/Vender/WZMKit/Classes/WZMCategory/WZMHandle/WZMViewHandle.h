//
//  WZMViewHandle.h
//  test
//
//  Created by XHL on 16/8/16.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMEnum.h"

@interface WZMViewHandle : UIView

+ (void)wzm_showAlertMessage:(NSString *)message;
+ (void)wzm_showInfoMessage:(NSString *)message;
+ (void)wzm_showProgressMessage:(NSString *)message;
+ (void)wzm_dismiss;

/**
 在状态栏显示网络加载的齿轮图标
 */
+ (void)wzm_setNetworkActivityIndicatorVisible:(BOOL)visible;

/**
 屏蔽触发事件
 */
+ (void)wzm_beginIgnoringInteractionEventsDuration:(NSTimeInterval)duration;

/**
 隐藏/显示状态栏
 */
+ (void)wzm_setStatusBarHidden:(BOOL)hidden;

/**
 设置状态栏颜色,需要在info.plist中，将View controller-based status bar appearance设为NO
 */
+ (void)wzm_setStatusBarStyle: (WZMStatusBarStyle)statusBarStyle;

///寻找导航栏黑线
+ (UIImageView *)wzm_findShadowImageView:(UIView *)view;

@end
