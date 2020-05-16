//
//  WZMRefreshFooterView.m
//  refresh
//
//  Created by zhaomengWang on 17/3/16.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMRefreshFooterView.h"
#import <objc/message.h>

// 运行时objc_msgSend
#define WZMRefreshMsgSend(...)       ((void (*)(void *, SEL, UIView *))objc_msgSend)(__VA_ARGS__)
#define WZMRefreshMsgTarget(target)  (__bridge void *)(target)
@implementation WZMRefreshFooterView{
    CGFloat _contentOffsetY;
    CGFloat _lastContentHeight;
}

+ (instancetype)footerWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    WZMRefreshFooterView *refreshFooter = [[self alloc] init];
    refreshFooter.refreshingTarget = target;
    refreshFooter.refreshingAction = action;
    [[NSNotificationCenter defaultCenter] addObserver:refreshFooter selector:@selector(refreshMoreData:) name:WZMRefreshMoreData object:nil];
    return refreshFooter;
}

- (void)refreshMoreData:(NSNotification *)notification {
    
    BOOL moreData = [notification.object boolValue];
    if (moreData) {
        [self refreshNormal];
    }
    else {
        [self noMoreData];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        _contentOffsetY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
    }
    else {
        _contentOffsetY = 0.0;
    }
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.bounds.size.height+_contentOffsetY;
    self.frame = frame;
    
    NSInteger w = ceil([_messageLabel.text sizeWithAttributes:@{NSFontAttributeName:WZM_TIME_FONT}].width);
    self.arrowView.frame = CGRectMake((self.bounds.size.width-w)/2-35, (WZMRefreshHeaderHeight-40)/2.0, 15, 40);
    
    self.loadingView.center = self.arrowView.center;
    self.loadingView.color = WZM_REFRESH_COLOR;
}

- (void)createViews {
    [super createViews];
    _messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _messageLabel.font = WZM_REFRESH_FONT;
    _messageLabel.text = @"上拉可以加载更多";
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.textColor = WZM_REFRESH_COLOR;
    [self addSubview:_messageLabel];
}

- (void)updateRefreshState:(WZMRefreshState)refreshState {
    if (refreshState == _refreshState) return;
    
    NSString *refreshText;
    if (refreshState == WZMRefreshStateNormal) {
        refreshText = @"上拉可以加载更多";
    }
    else if (refreshState == WZMRefreshStateWillRefresh) {
        refreshText = @"松开立即加载更多";
    }
    else if (refreshState == WZMRefreshStateRefreshing) {
        refreshText = @"正在加载数据...";
    }
    else {
        refreshText = @"没有更多数据了";
    }
    _messageLabel.text = refreshText;
    _refreshState = refreshState;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y <= 0) return;
    
    CATransform3D transform3D = WZM_TRANS_FORM;
    
    if (_refreshState == WZMRefreshStateNoMoreData) {
        if (self.scrollView.contentOffset.y >= WZMRefreshFooterHeight+_contentOffsetY) {
            transform3D = CATransform3DIdentity;
        }
    }
    else {
        if (self.scrollView.contentOffset.y < WZMRefreshFooterHeight+_contentOffsetY) {
            [self refreshNormal];
        }
        else {
            [self willRefresh];
            transform3D = CATransform3DIdentity;
        }
    }
    [UIView animateWithDuration:.3 animations:^{
        self.arrowView.layer.transform = transform3D;
    }];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change {
    [super scrollViewContentSizeDidChange:change];
    
    if (self.scrollView.contentSize.height > self.scrollView.bounds.size.height) {
        _contentOffsetY = self.scrollView.contentSize.height-self.scrollView.bounds.size.height;
    }
    else {
        _contentOffsetY = 0.0;
    }
    CGRect frame = self.frame;
    frame.origin.y = self.scrollView.bounds.size.height+_contentOffsetY;
    self.frame = frame;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (self.scrollView.contentOffset.y >= WZMRefreshFooterHeight+_contentOffsetY) {
            [self beginRefresh];
        }
    }
    else if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.arrowView.hidden = NO;
    }
}

- (void)beginRefresh {
    if (self.isRefreshing == NO) {
        [super beginRefresh];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(-WZMRefreshFooterHeight-_contentOffsetY, 0, 0, 0);
                _lastContentHeight = self.scrollView.contentSize.height;
            } completion:^(BOOL finished) {
                if ([self.refreshingTarget respondsToSelector:self.refreshingAction]) {
                    WZMRefreshMsgSend(WZMRefreshMsgTarget(self.refreshingTarget), self.refreshingAction, self);
                }
            }];
        });
    }
}

- (void)endRefresh:(BOOL)more {
    if (self.isRefreshing) {
        [super endRefresh:more];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (more == NO) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }];
            }
            else if (_contentOffsetY == 0) {
                
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
                else {
                    [UIView animateWithDuration:0.35 animations:^{
                        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                    }];
                }
            }
            else {
                //[UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.scrollView.contentOffset = CGPointMake(0, _lastContentHeight-self.scrollView.bounds.size.height+WZMRefreshFooterHeight);
                //}];
            }
        });
    }
}

- (void)endRefresh {
    if (self.isRefreshing) {
        BOOL more = !(_lastContentHeight == self.scrollView.contentSize.height);
        [super endRefresh:more];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (more == NO) {
                [UIView animateWithDuration:0.35 animations:^{
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }];
            }
            else if (_contentOffsetY == 0) {
                
                if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
                else {
                    [UIView animateWithDuration:0.35 animations:^{
                        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                    }];
                }
            }
            else {
                //[UIView animateWithDuration:.35 animations:^{
                self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                self.scrollView.contentOffset = CGPointMake(0, _lastContentHeight-self.scrollView.bounds.size.height+WZMRefreshFooterHeight);
                //}];
            }
        });
    }
}

@end
