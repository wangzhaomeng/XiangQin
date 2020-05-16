//
//  WZMScrollImageView.h
//  WZMKit
//
//  Created by WangZhaomeng on 2017/12/12.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WZMScrollImageViewDelegage;

@interface WZMScrollImageView : UIView

@property (nonatomic, weak) id<WZMScrollImageViewDelegage> delegate;

///图片距边界距离(取正值，图片不可超出视图)
@property (nonatomic, assign) UIEdgeInsets imageViewInset;

///是否显示底部pageControl, 默认YES
@property (nonatomic, assign, getter=isShowPageControl) BOOL showPageControl;

///选中颜色
@property (nonatomic, strong) UIColor *pageIndicatorTintColor;

///未选中颜色
@property (nonatomic, strong) UIColor *currentPageIndicatorTintColor;

///当前选中页
@property (nonatomic, assign) NSInteger currentPage;

///是否自动滚动，默认YES
@property (nonatomic, assign, getter=isAutoScroll) BOOL autoScroll;

- (instancetype)initWithFrame:(CGRect)frame images:(NSArray<UIImage *> *)images;

@end

@protocol WZMScrollImageViewDelegage <NSObject>

@optional
- (void)scrollImageView:(WZMScrollImageView *)scrollImageView didSelectedAtIndex:(NSInteger)index;

@end
