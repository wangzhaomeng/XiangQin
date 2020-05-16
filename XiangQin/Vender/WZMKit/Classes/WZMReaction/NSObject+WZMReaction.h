//
//  NSObject+WZMReaction.h
//  WZMCommonStatic
//
//  Created by WangZhaomeng on 2019/6/24.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZMReactionManager.h"

@interface NSObject (WZMReaction)

- (void)setReaction:(WZMReactionManager *)reaction;
- (WZMReactionManager *)reaction;

- (void)setNextAction:(nextAction)nextAction;
- (nextAction)nextAction;

@end
