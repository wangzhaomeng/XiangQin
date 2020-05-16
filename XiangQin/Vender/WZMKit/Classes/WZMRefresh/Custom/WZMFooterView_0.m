//
//  WZMFooterView_0.m
//  WZMKit
//
//  Created by WangZhaomeng on 2017/11/25.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import "WZMFooterView_0.h"

@implementation WZMFooterView_0

- (void)updateRefreshState:(WZMRefreshState)refreshState {
    if (refreshState == _refreshState) return;
    _refreshState = refreshState;
    
//    NSString *refreshText;
//    if (refreshState == WZMRefreshStateNormal) {
//        refreshText = @"上拉可以加载更多";
//    }
//    else if (refreshState == WZMRefreshStateWillRefresh) {
//        refreshText = @"松开立即加载更多";
//    }
//    else if (refreshState == WZMRefreshStateRefreshing) {
//        refreshText = @"正在加载数据...";
//    }
//    else {
//        refreshText = @"没有更多数据了";
//    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    [super scrollViewContentOffsetDidChange:change];
    if (self.scrollView.contentOffset.y <= 0) return;
}

- (void)scrollViewPanStateDidChange:(NSDictionary *)change{
    [super scrollViewPanStateDidChange:change];
    if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    else if (self.scrollView.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
    }
}

@end
