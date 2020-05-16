//
//  WZMCatchStore.h
//  WZMKit
//
//  Created by WangZhaomeng on 2018/9/26.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZMCatchStore : NSObject

+ (instancetype)shareStore;

- (void)setObj:(id)obj forKey:(NSString *)key;

- (id)objForKey:(NSString *)key;

@end
