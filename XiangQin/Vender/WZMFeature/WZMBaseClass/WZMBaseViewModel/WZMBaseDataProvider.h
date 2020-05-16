//
//  WZMBaseDataProvider.h
//  LLFeature
//
//  Created by WangZhaomeng on 2017/10/11.
//  Copyright © 2017年 WangZhaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZMURLResponse.h"

///网络请求方式
typedef NS_ENUM(NSInteger, WZMURLRequestMethod) {
    WZMURLRequestMethodGet = 0,  //HTTP Get请求
    WZMURLRequestMethodPost,     //HTTP Post请求
    WZMURLRequestMethodPut,      //HTTP Put请求
    WZMURLRequestMethodDelete,   //HTTP Delet请求
    WZMURLRequestMethodPatch,    //HTTP Patch请求
    WZMURLRequestMethodHead      //HTTP Head请求
};
typedef void(^doHandler)(void);
#define WZM_START_PAGE 1
#define WZM_LOADING @"加载中..."
#define WZM_NO_NET  @"请检查网络连接后重试"
#define WZM_NO_DATA @"暂无数据"
@interface WZMBaseDataProvider : NSObject

///请求的URL
@property (nonatomic, strong) NSString *requestUrl;
///请求的参数
@property (nonatomic, strong) NSDictionary *requestParams;
///请求头的参数
@property (nonatomic, strong) NSDictionary *headerParams;
///请求方式
@property (nonatomic, assign) WZMURLRequestMethod method;
///是否支持分页
@property (nonatomic, assign, getter=isPageEnable) BOOL pageEnable;
///是否本地缓存
@property (nonatomic, assign, getter=isUseLocalCache) BOOL useLocalCache;
///页码,当pageEnable = YES时生效
@property (nonatomic, readonly, assign) NSInteger page;
///本次请求的dataTask
@property (nonatomic, readonly, strong) NSURLSessionDataTask *dataTask;
///请求结果
@property (nonatomic, readonly, strong) WZMURLResponse *response;

#pragma mark - 子类重载
///加载数据
- (void)loadData:(doHandler)loadHandler
        callBack:(doHandler)backHandler;
///解析服务端返回的字符串数据
- (void)parseJSON:(id)json;
///清空已有数据
- (void)clearLastData;
///是否为空的,默认空
- (BOOL)isDataEmpty;

#pragma mark - 页面交互使用
///下拉刷新调用
- (void)headerLoadData:(doHandler)loadHandler
              callBack:(doHandler)backHandler;
///上拉加载调用
- (void)footerLoadData:(doHandler)loadHandler
              callBack:(doHandler)backHandler;

@end
