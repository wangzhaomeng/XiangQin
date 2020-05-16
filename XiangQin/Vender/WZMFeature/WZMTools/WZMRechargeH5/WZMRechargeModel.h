//
//  WZMRechargeModel.h
//  ZiMuKing
//
//  Created by Zhaomeng Wang on 2020/1/13.
//  Copyright © 2020 Vincent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WZMRechargeModel : NSObject

/// h5 支付相关
/// vs
/// url schemes标识
@property (nonatomic, copy) NSString *wxSchemes;
/// 回调标识
@property (nonatomic, copy) NSString *wxRedirect;
/// 授权域名
@property (nonatomic, copy) NSString *wxAuthDomain;
/// 网页标识
@property (nonatomic, copy) NSString *wxH5Identifier;
/// chb
/// url schemes标识
@property (nonatomic, copy) NSString *alSchemes;
/// from schemes标识
@property (nonatomic, copy) NSString *alSchemesKey;
/// 支付回调标识
@property (nonatomic, copy) NSString *alUrlKey;
///本应用的url schemes
@property (nonatomic, copy) NSString *mySchemes;

/// 单例
#if DEBUG
//请查看.m中对应的注释
+ (instancetype)shareModel;
#endif

@end
