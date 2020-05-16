//
//  UINavigationController+wzmcate.m
//  LLFoundation
//
//  Created by wangzhaomeng on 16/10/13.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "UINavigationController+wzmnav.h"
#import <objc/runtime.h>

@implementation UINavigationController (wzmnav)
static NSString *_lineHiddenKey = @"lineHidden";
static NSString *_lineImageViewKey = @"lineImage";

//是否隐藏导航栏线条
- (UIImageView *)lineImageView
{
    return objc_getAssociatedObject(self, &_lineImageViewKey);
}

- (void)setLineImageView:(UIView *)lineImageView
{
    objc_setAssociatedObject(self, &_lineImageViewKey, lineImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setNavLineHidden:(BOOL)navLineHidden {
    
    if (self.navLineHidden == navLineHidden) return;
    
    if (self.lineImageView == nil) {
        self.lineImageView = [self findHairlineImageViewUnder:self.navigationBar];
    }
    self.lineImageView.hidden = navLineHidden;
    
    NSNumber *t = @(navLineHidden);
    objc_setAssociatedObject(self, &_lineHiddenKey, t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)navLineHidden {
    NSNumber *t = objc_getAssociatedObject(self, &_lineHiddenKey);
    return [t boolValue];
}

#pragma mark - 寻找导航栏黑线
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
