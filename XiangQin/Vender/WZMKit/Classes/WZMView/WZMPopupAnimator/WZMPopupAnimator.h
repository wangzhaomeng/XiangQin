//
//  WZMPopupAnimator.h
//  WZMFoundation
//
//  Created by zhaomengWang on 17/3/3.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMEnum.h"
#import "WZMBlock.h"

@protocol WZMPopupAnimatorDelegate;

@interface WZMPopupAnimator : UIView

@property (nonatomic, weak) id<WZMPopupAnimatorDelegate> delegate;

+ (instancetype)shareAnimator;
- (void)popUpView:(UIView *)view animationStyle: (WZMAnimationStyle)animationStyle duration:(NSTimeInterval)duration completion:(wzm_doBlock)completion;
- (void)dismiss:(BOOL)animated completion:(wzm_doBlock)completion;

@end

@protocol WZMPopupAnimatorDelegate <NSObject>

@optional
- (void)dismissAnimationCompletion;

@end
