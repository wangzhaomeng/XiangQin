//
//  WZMAlertView.h
//  WZMFoundation
//
//  Created by lhy on 16/8/17.
//  Copyright © 2016年 MaoChao Network Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WZMEnum.h"
#import "WZMBlock.h"

@interface WZMAlertView : UIView

@property (nonatomic, strong) UIColor *cancelColor;
@property (nonatomic, strong) UIColor *OKColor;

- (id)initWithTitle:(NSString *)title message:(NSString *)message OKButtonTitle:(NSString *)OKButtonTitle cancelButtonTitle:(NSString *)cancelButtonTitle type:(WZMAlertViewType)type;

- (void)showAnimated:(BOOL)animated;

/**
 设置取消按钮的点击事件
 */
- (void)setCannelBlock:(wzm_doBlock)cannelBlock;

/**
 设置确定按钮的点击事件
 */
- (void)setOKBlock:(wzm_doBlock)OKBlock;

@end
