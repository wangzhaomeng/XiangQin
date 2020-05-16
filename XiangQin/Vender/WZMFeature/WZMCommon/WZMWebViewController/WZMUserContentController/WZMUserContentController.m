//
//  WZMUserContentController.m
//  LLCommonStatic
//
//  Created by WangZhaomeng on 2019/5/27.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//

#import "WZMUserContentController.h"

@interface WZMUserContentController ()<WKScriptMessageHandler>

@end

@implementation WZMUserContentController

- (void)addScriptMessageHandler:(NSArray *)scriptNames {
    for (NSString *name in scriptNames) {
        [self addScriptMessageHandler:self name:name];
    }
}

- (void)removeScriptMessageHandler:(NSArray *)scriptNames {
    for (NSString *name in scriptNames) {
        [self removeScriptMessageHandlerForName:name];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
