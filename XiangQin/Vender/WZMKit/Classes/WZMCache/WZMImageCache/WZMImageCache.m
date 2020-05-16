//
//  WZMImageCache.m
//  WZMFoundation
//
//  Created by zhaomengWang on 17/3/14.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMImageCache.h"
#import "WZMLogPrinter.h"
#import "WZMMacro.h"
#import "WZMBase64.h"

@implementation WZMImageCache {
    CGFloat _cacheSize;
    NSString *_cachePath;
    NSMutableDictionary *_memoryCache;
}

+ (instancetype)shareCache {
    static WZMImageCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[WZMImageCache alloc] init];
    });
    return cache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheSize = 0.0;
        _cachePath = [WZM_CACHE_PATH stringByAppendingPathComponent:@"WZMImageCache"];
        _memoryCache = [[NSMutableDictionary alloc] initWithCapacity:0];
        [self createDirectoryAtPath:_cachePath];
    }
    return self;
}

/**
 获取网络图片(同步)
 */
- (UIImage *)getImageWithUrl:(NSString *)url isUseCatch:(BOOL)isUseCatch {
    UIImage *image;
    if (isUseCatch) {
        image = [self getImageFromCacheWithUrl:url];
        if (image == nil) {
            image = [self getImageWithUrl:url];
        }
    }
    else {
        image = [self getImageWithUrl:url];
        if (image == nil) {
            image = [self getImageFromCacheWithUrl:url];
        }
    }
    return image;
}

- (UIImage *)getImageFromCacheWithUrl:(NSString *)url {
    //1、从内存存获取
    NSString *urlKey = [self tureKey:url];
    UIImage *image = [_memoryCache objectForKey:urlKey];
    if (image) {
        return image;
    }
    
    //2、从本地获取
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    if ([self fileExistsAtPath:cachePath]) {
        image = [UIImage imageWithContentsOfFile:cachePath];
        if (image) {
            //存到内存
            [self memoryCacheSetValue:image forKey:urlKey];
            return image;
        }
    }
    return nil;
}

- (UIImage *)getImageWithUrl:(NSString *)url {
    //3、从网络获取
    NSString *urlKey = [self tureKey:url];
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if (imageData) {
        UIImage *urlImage = [UIImage imageWithData:imageData];
        if (urlImage) {
            //存到内存
            [self memoryCacheSetValue:urlImage forKey:urlKey];
            //存到本地
            [self writeFile:imageData toPath:cachePath];
            return urlImage;
        }
    }
    return nil;
}

/**
 获取网络图片(异步)
 */
- (void)getImageWithUrl:(NSString *)url isUseCatch:(BOOL)isUseCatch placeholder:(UIImage *)pla completion:(void(^)(UIImage *image))completion {
    if (!completion) return;
    if (isUseCatch) {
        [self getImageFromCacheWithUrl:url placeholder:pla completion:^(UIImage *image) {
            if (image) {
                completion(image);
            }
            else {
                [self getImageWithUrl:url placeholder:pla completion:completion];
            }
        }];
    }
    else {
        [self getImageWithUrl:url placeholder:pla completion:^(UIImage *image) {
            if (image) {
                completion(image);
            }
            else {
                [self getImageFromCacheWithUrl:url placeholder:pla completion:completion];
            }
        }];
    }
}

- (void)getImageFromCacheWithUrl:(NSString *)url placeholder:(UIImage *)placeholder completion:(void(^)(UIImage *image))completion {
    //1、从内存获取
    NSString *urlKey = [self tureKey:url];
    UIImage *image = [_memoryCache objectForKey:urlKey];
    if (image) {
        completion(image);
        return;
    }
    //2、从本地获取
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    if ([self fileExistsAtPath:cachePath]) {
        image = [UIImage imageWithContentsOfFile:cachePath];
        if (image) {
            //存到内存
            [self memoryCacheSetValue:image forKey:urlKey];
            completion(image);
            return;
        }
    }
    completion(nil);
}

- (void)getImageWithUrl:(NSString *)url placeholder:(UIImage *)pla completion:(void(^)(UIImage *image))completion {
    completion(pla);
    //3、从网络获取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *urlKey = [self tureKey:url];
        NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (imageData) {
            UIImage *urlImage = [UIImage imageWithData:imageData];
            if (urlImage) {
                //存到内存
                [self memoryCacheSetValue:urlImage forKey:urlKey];
                //存到本地
                [self writeFile:imageData toPath:cachePath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(urlImage);
                });
            }
        }
    });
}

/**
 获取网络数据(同步)
 */
- (NSData *)getDataWithUrl:(NSString *)url isUseCatch:(BOOL)isUseCatch {
    NSData *data;
    if (isUseCatch) {
        data = [self getDataFromCacheWithUrl:url];
        if (data == nil) {
            data = [self getDataWithUrl:url];
        }
    }
    else {
        data = [self getDataWithUrl:url];
        if (data == nil) {
            data = [self getDataFromCacheWithUrl:url];
        }
    }
    return data;
}

- (NSData *)getDataFromCacheWithUrl:(NSString *)url {
    //1、从内存获取
    NSString *urlKey = [self tureKey:url];
    NSData *data = [_memoryCache objectForKey:urlKey];
    if (data) {
        return data;
    }
    //2、从本地获取
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    if ([self fileExistsAtPath:cachePath]) {
        data = [NSData dataWithContentsOfFile:cachePath];
        if (data) {
            //存到内存
            [self memoryCacheSetValue:data forKey:urlKey];
            return data;
        }
    }
    return nil;
}

- (NSData *)getDataWithUrl:(NSString *)url {
    //3、从网络获取
    NSString *urlKey = [self tureKey:url];
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if (urlData) {
        //存到内存
        [self memoryCacheSetValue:urlData forKey:urlKey];
        //存到本地
        [self writeFile:urlData toPath:cachePath];
        return urlData;
    }
    return nil;
}

/**
 获取网络数据(异步)
 */
- (void)getDataWithUrl:(NSString *)url isUseCatch:(BOOL)isUseCatch completion:(void(^)(NSData *data))completion {
    if (!completion) return;
    if (isUseCatch) {
        [self getDataFromCacheWithUrl:url completion:^(NSData *data) {
            if (data) {
                completion(data);
            }
            else {
                [self getDataWithUrl:url completion:completion];
            }
        }];
    }
    else {
        [self getDataWithUrl:url completion:^(NSData *data) {
            if (data) {
                completion(data);
            }
            else {
                [self getDataFromCacheWithUrl:url completion:completion];
            }
        }];
    }
}

- (void)getDataFromCacheWithUrl:(NSString *)url completion:(void(^)(NSData *data))completion {
    //1、从内存获取
    NSString *urlKey = [self tureKey:url];
    NSData *data = [_memoryCache objectForKey:urlKey];
    if (data) {
        completion(data);
        return;
    }
    
    //2、从本地获取
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    if ([self fileExistsAtPath:cachePath]) {
        data = [NSData dataWithContentsOfFile:cachePath];
        if (data) {
            //存到内存
            [self memoryCacheSetValue:data forKey:urlKey];
            completion(data);
            return;
        }
    }
    completion(nil);
}

- (void)getDataWithUrl:(NSString *)url completion:(void(^)(NSData *data))completion {
    //3、从网络获取
    NSString *urlKey = [self tureKey:url];
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:urlKey];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *urlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        if (urlData) {
            //存到内存
            [self memoryCacheSetValue:urlData forKey:urlKey];
            //存到本地
            [self writeFile:urlData toPath:cachePath];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(urlData);
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil);
            });
        }
    });
}

- (NSString *)storeImage:(UIImage *)image forKey:(NSString *)key {
    if (image == nil || key.length == 0) {
        WZMLog(@"键值不能为空");
        return @"";
    }
    NSString *tureKey = [self tureKey:key];
    //存到内存
    [self memoryCacheSetValue:image forKey:tureKey];
    //存到本地
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:tureKey];
    if ([self writeFile:UIImagePNGRepresentation(image) toPath:cachePath]) {
        return cachePath;
    }
    return @"";
}

- (UIImage *)imageForKey:(NSString *)key {
    NSString *tureKey = [self tureKey:key];
    UIImage *image = [_memoryCache objectForKey:tureKey];
    if (image == nil) {
        NSString *cachePath = [_cachePath stringByAppendingPathComponent:tureKey];
        if ([self fileExistsAtPath:cachePath]) {
            image = [UIImage imageWithContentsOfFile:cachePath];
            //存到内存
            [self memoryCacheSetValue:image forKey:key];
        }
    }
    return image;
}

- (NSString *)storeData:(NSData *)data forKey:(NSString *)key {
    if (data == nil || key.length == 0) {
        WZMLog(@"键值不能为空");
        return @"";
    }
    NSString *tureKey = [self tureKey:key];
    //存到内存
    [self memoryCacheSetValue:data forKey:tureKey];
    //存到本地
    NSString *cachePath = [_cachePath stringByAppendingPathComponent:tureKey];
    if ([self writeFile:data toPath:cachePath]) {
        return cachePath;
    }
    return @"";
}

- (NSData *)dataForKey:(NSString *)key {
    NSString *tureKey = [self tureKey:key];
    NSData *data = [_memoryCache objectForKey:tureKey];
    if (data == nil) {
        NSString *cachePath = [_cachePath stringByAppendingPathComponent:tureKey];
        if ([self fileExistsAtPath:cachePath]) {
            data = [NSData dataWithContentsOfFile:cachePath];
            //存到内存
            [self memoryCacheSetValue:data forKey:key];
        }
    }
    return data;
}

- (NSString *)filePathForKey:(NSString *)key {
    NSString *tureKey = [self tureKey:key];
    return [_cachePath stringByAppendingPathComponent:tureKey];
}

- (NSString *)tureKey:(NSString *)key {
    NSString *tureKey = [key wzm_base64EncodedString];
    if (key.pathExtension) {
        tureKey = [NSString stringWithFormat:@"%@.%@",tureKey,key.pathExtension];
    }
    return tureKey;
}

- (void)memoryCacheSetValue:(id)value forKey:(NSString *)key {
    NSData *data;
    if ([value isKindOfClass:[UIImage class]]) {
        data = UIImagePNGRepresentation((UIImage *)value);
    }
    else if ([value isKindOfClass:[data class]]) {
        data = (NSData *)value;
    }
    if (data == nil) return;
    if (_cacheSize > 50*1000*1000) {
        [self clearMemory];
    }
    _cacheSize += data.length;
    [_memoryCache setValue:value forKey:key];
}

- (void)clearMemory {
    _cacheSize = 0.0;
    [_memoryCache removeAllObjects];
}

- (void)clearImageCacheCompletion:(wzm_doBlock)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self clearMemory];
        if ([self deleteFileAtPath:_cachePath error:nil]) {
            [self createDirectoryAtPath:_cachePath];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    });
}

#pragma mark - 文件管理
- (BOOL)fileExistsAtPath:(NSString *)filePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    WZMLog(@"fileExistsAtPath:文件未找到");
    return NO;
}

- (BOOL)createDirectoryAtPath:(NSString *)path{
    BOOL isDirectory;
    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory];
    if (isExists && isDirectory) {
        return YES;
    }
    NSError *error = nil;
    BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                            withIntermediateDirectories:YES
                                                             attributes:nil
                                                                  error:&error];
    if (error) {
        WZMLog(@"创建文件夹失败:%@",error);
    }
    return result;
}

- (BOOL)writeFile:(id)file toPath:(NSString *)path{
    BOOL isOK = [file writeToFile:path atomically:YES];
    WZMLog(@"文件存储路径为:%@",path);
    return isOK;
}

- (BOOL)deleteFileAtPath:(NSString *)filePath error:(NSError **)error{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        return [[NSFileManager defaultManager] removeItemAtPath:filePath error:error];
    }
    WZMLog(@"deleteFileAtPath:error:路径未找到");
    return YES;
}

@end
