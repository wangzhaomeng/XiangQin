//
//  AppDelegate.m
//  XiangQin
//
//  Created by 富秋 on 2020/5/10.
//  Copyright © 2020 富秋. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [WZMTabBarController shareTabBarController];
    
    //禁止多点触控
    [[UIView appearance] setExclusiveTouch:YES];
    
    
    return YES;
}


@end
