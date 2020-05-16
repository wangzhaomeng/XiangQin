//
//  WZMAlbumPhotoModel.m
//  WZMKit_Example
//
//  Created by WangZhaomeng on 2019/8/6.
//  Copyright © 2019 wangzhaomeng. All rights reserved.
//

#import "WZMAlbumPhotoModel.h"
#import "WZMAlbumHelper.h"
#import <Photos/Photos.h>
#import "WZMAlbumConfig.h"

@implementation WZMAlbumPhotoModel

+ (instancetype)modelWithAsset:(PHAsset *)asset {
    WZMAlbumPhotoModel *model = [[WZMAlbumPhotoModel alloc] init];
    model.asset = asset;
    model.width = 100;
    model.iCloud = YES;
    model.selected = NO;
    model.animated = NO;
    model.downloading = NO;
    model.type = [WZMAlbumHelper wzm_getAssetType:asset];
    if (model.type == WZMAlbumPhotoTypeVideo) {
        model.duration = [(PHAsset *)asset duration];
        model.timeStr = [model getTimeWithSecond:model.duration];
    }
    else {
        model.duration = 0;
        model.timeStr = @"00";
    }
    return model;
}

///获取缩略图
- (void)getThumbnailCompletion:(void(^)(UIImage *thumbnail))completion cloud:(void(^)(BOOL iCloud))cloud {
    if (self.thumbnail) {
        if (completion) completion(self.thumbnail);
    }
    else {
        [WZMAlbumHelper wzm_getThumbnailWithAsset:self.asset photoWidth:self.width thumbnail:^(UIImage *photo) {
            self.thumbnail = photo;
            if (completion) completion(photo);
        } cloud:^(BOOL iCloud) {
            self.iCloud = iCloud;
            if (cloud) cloud(iCloud);
        }];
    }
}

///获取原图
- (void)getOriginalCompletion:(void(^)(id original))completion {
    if (self.isICloud) {
        [self getICloudImageCompletion:completion];
    }
    else {
        [WZMAlbumHelper wzm_getOriginalWithAsset:self.asset completion:^(id obj) {
            if (completion) completion(obj);
        }];
    }
}

///从iCloud获取原图
- (void)getICloudImageCompletion:(void (^)(id original))completion {
    if (self.downloading) return;
    self.downloading = YES;
    [WZMAlbumHelper wzm_getICloudWithAsset:self.asset progressHandler:nil completion:^(id obj) {
        if (obj) {
            self.iCloud = NO;
        }
        self.downloading = NO;
        if (completion) completion(obj);
    }];
}

///预设尺寸视频
- (void)exportVideoWithPreset:(NSString *)preset outFolder:(NSString *)outFolder completion:(void(^)(NSURL *videoURL))completion {
    [WZMAlbumHelper wzm_exportVideoWithAsset:self.asset preset:preset outFolder:outFolder completion:^(NSURL *videoURL) {
        if (completion) completion(videoURL);
    }];
}

///预设尺寸图片
- (void)exportImageWithImageSize:(CGSize)imageSize completion:(void(^)(UIImage *image))completion {
    [WZMAlbumHelper wzm_exportImageWithAsset:self.asset imageSize:imageSize completion:^(UIImage *image) {
        if (completion) completion(image);
    }];
}

///获取图片
- (void)getImageWithConfig:(WZMAlbumConfig *)config completion:(void(^)(id obj))completion {
    if (self.type == WZMAlbumPhotoTypeVideo) {
        if (config.originalVideo) {
            //原视频
            [self getOriginalCompletion:^(id original) {
                if (completion) completion(original);
            }];
        }
        else {
            //预设尺寸
            [self exportVideoWithPreset:config.videoPreset outFolder:config.videoFolder completion:^(NSURL *videoURL) {
                if (completion) completion(videoURL);
            }];
        }
    }
    else if (self.type == WZMAlbumPhotoTypeAudio) {
        //声音
        if (completion) completion(nil);
    }
    else if (self.type == WZMAlbumPhotoTypePhotoGif && config.allowShowGIF) {
        //GIF
        [self getOriginalCompletion:^(id original) {
            if (completion) completion(original);
        }];
    }
    else {
        if (config.originalImage) {
            //原图
            [self getOriginalCompletion:^(id original) {
                if (completion) {
                    if (original) {
                        completion(original);
                    }
                    else {
                        if (config.allowUseThumbnail) {
                            [self getThumbnailCompletion:^(UIImage *thumbnail) {
                                completion(thumbnail);
                            } cloud:nil];
                        }
                        else {
                            completion(original);
                        }
                    }
                }
            }];
        }
        else {
            //预设尺寸
            [self exportImageWithImageSize:config.imageSize completion:^(UIImage *image) {
                if (completion) {
                    if (image) {
                        completion(image);
                    }
                    else {
                        if (config.allowUseThumbnail) {
                            [self getThumbnailCompletion:^(UIImage *thumbnail) {
                                completion(thumbnail);
                            } cloud:nil];
                        }
                        else {
                            completion(image);
                        }
                    }
                }
            }];
        }
    }
}

///时间
- (NSString *)getTimeWithSecond:(NSInteger)second {
    NSString *time;
    if (second < 60) {
        time = [NSString stringWithFormat:@"00:%02ld",(long)second];
    }
    else {
        if (second < 3600) {
            time = [NSString stringWithFormat:@"%02ld:%02ld",(long)(second/60),(long)(second%60)];
        }
        else {
            time = [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)(second/3600),(long)((second-second/3600*3600)/60),(long)(second%60)];
        }
    }
    return time;
}

@end
