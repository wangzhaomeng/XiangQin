//
//  WZMTabBarController.m
//  LLTabBarViewController
//
//  Created by zhaomengWang on 2017/3/31.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMTabBarController.h"
#import "WZMNavigationController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"
#import "WZMMacro.h"

@interface WZMTabBarController ()<UITabBarControllerDelegate>

@end

@implementation WZMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view insertSubview:[self screenShotView] atIndex:0];
}

+ (instancetype)shareTabBarController {
    static WZMTabBarController *tabBarController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tabBarController = [[WZMTabBarController alloc] init];
        tabBarController.tabBar.translucent = NO;
        
        FirstViewController *firstViewController = [[FirstViewController alloc] init];
        WZMNavigationController *firstNav = [[WZMNavigationController alloc] initWithRootViewController:firstViewController];
        
        SecondViewController *secondViewController = [[SecondViewController alloc] init];
        WZMNavigationController *secondNav = [[WZMNavigationController alloc] initWithRootViewController:secondViewController];
        
        ThirdViewController *thirdViewController = [[ThirdViewController alloc] init];
        WZMNavigationController *thirdNav = [[WZMNavigationController alloc] initWithRootViewController:thirdViewController];
        
        FourthViewController *fourthViewController = [[FourthViewController alloc] init];
        WZMNavigationController *fourthNav = [[WZMNavigationController alloc] initWithRootViewController:fourthViewController];
        
        FifthViewController *fifViewController = [[FifthViewController alloc] init];
        WZMNavigationController *fifNav = [[WZMNavigationController alloc] initWithRootViewController:fifViewController];
        
        tabBarController.delegate = tabBarController;
        [tabBarController setViewControllers:@[firstNav,secondNav,thirdNav,fourthNav,fifNav]];
        [tabBarController setConfig];
    });
    return tabBarController;
}

- (void)setConfig {
    NSArray *titles = @[@"第一页",@"第二页",@"第三页",@"第四页",@"第五页"];
    NSArray *normalImages = @[@"tabbar_icon",@"tabbar_icon",@"tabbar_icon",@"tabbar_icon",@"tabbar_icon"];
    NSArray *selectImages = @[@"tabbar_icon_on",@"tabbar_icon_on",@"tabbar_icon_on",@"tabbar_icon",@"tabbar_icon"];
    for (NSInteger i = 0; i < self.tabBar.items.count; i ++) {
        NSDictionary *atts = @{NSForegroundColorAttributeName:[UIColor wzm_getDynamicColorByLightColor:[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:1.0] darkColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]],NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
        NSDictionary *selAtts = @{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:12.0]};
        
        UIImage *img = [[UIImage imageNamed:normalImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selImg = [[UIImage imageNamed:selectImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *tabBarItem = self.tabBar.items[i];
        if (@available(iOS 13.0, *)) {
            UITabBarAppearance *appearance = [UITabBarAppearance new];
            appearance.backgroundColor = [UIColor wzm_getDynamicColorByLightColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0] darkColor:[UIColor colorWithRed:8.0/255.0 green:8.0/255.0 blue:8.0/255.0 alpha:1.0]];
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = atts;
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = selAtts;
            tabBarItem.standardAppearance = appearance;
        }
        else {
            [tabBarItem setTitleTextAttributes:atts forState:UIControlStateNormal];
            [tabBarItem setTitleTextAttributes:selAtts forState:UIControlStateSelected];
        }
        tabBarItem.title = titles[i];
        tabBarItem.image = img;
        tabBarItem.selectedImage = selImg;
    }
}

- (void)setBadgeValue:(NSString *)badgeValue atIndex:(NSInteger)index {
    if (index < self.tabBar.items.count) {
        UITabBarItem *tabBarItem = self.tabBar.items[index];
        tabBarItem.badgeValue = badgeValue;
    }
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForScreenEdgesDeferringSystemGestures {
    return self.selectedViewController;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 4) {
        LHYLoginViewController *loginVC = [[LHYLoginViewController alloc] init];
        [(UINavigationController *)tabBarController.selectedViewController pushViewController:loginVC animated:YES];
        return NO;
    }
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
- (void)traitCollectionDidChange:(UITraitCollection*)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    //模式切换,重新设置
    [self setConfig];
}
#endif

#pragma mark - lazy load
- (WZMScreenShotView *)screenShotView {
    if (_screenShotView == nil) {
        _screenShotView = [[WZMScreenShotView alloc] init];
        _screenShotView.frame = WZM_SCREEN_BOUNDS;
        _screenShotView.hidden = YES;
    }
    return _screenShotView;
}

@end
