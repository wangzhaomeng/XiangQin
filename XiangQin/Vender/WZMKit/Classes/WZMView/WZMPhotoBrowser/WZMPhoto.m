//
//  WZMPhoto.m
//  WZMPhotoBrowser
//
//  Created by zhaomengWang on 17/2/6.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMPhoto.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+wzmcate.h"
#import "WZMGifImageView.h"
#import "WZMImageCache.h"
#import "UIView+wzmcate.h"
#import "NSData+wzmcate.h"
#import "UIImage+wzmcate.h"
#import "WZMVideoPlayerView.h"
#import "WZMLogPrinter.h"
#import "WZMPanGestureRecognizer.h"
#import "WZMAlbumPhotoModel.h"
#import "WZMAlbumHelper.h"
#import "WZMPublic.h"
#import "WZMDefined.h"

#define WZMPhotoMaxSCale 3.0  //最大缩放比例
#define WZMPhotoMinScale 1.0  //最小缩放比例
@interface WZMPhoto ()<UIScrollViewDelegate>{
    WZMVideoPlayerView *_videoView;
    WZMGifImageView *_imageView;
    NSData         *_imageData;
    NSURL          *_videoUrl;
    UIImage        *_currentImage;
    BOOL           _isGif;
    BOOL           _isVideo;
    BOOL           _display;
    CGRect         _startFrame;
    UIImageView    *_errorImageView;
}
@end

@implementation WZMPhoto

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minimumZoomScale = WZMPhotoMinScale;
        self.maximumZoomScale = WZMPhotoMaxSCale;
        self.backgroundColor  = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        UITapGestureRecognizer *singleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick:)];
        [self addGestureRecognizer:singleClick];
        
        UITapGestureRecognizer *doubleClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleClick.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleClick];
        
        [singleClick requireGestureRecognizerToFail:doubleClick];
        
        UILongPressGestureRecognizer *longClick = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longClick:)];
        [self addGestureRecognizer:longClick];
        
        WZMPanGestureRecognizer *panClick = [[WZMPanGestureRecognizer alloc] initWithTarget:self action:@selector(panClick:)];
        panClick.direction = WZMPanGestureRecognizerDirectionVertical;
        panClick.verticalDirection = WZMPanGestureRecognizerVerticalDirectionDown;
        [self addGestureRecognizer:panClick];
        
        _imageView = [[WZMGifImageView alloc] init];
        _imageView.hidden = YES;
        [self addSubview:_imageView];
        [self showPlaceholderImage];
        
        _videoView = [[WZMVideoPlayerView alloc] initWithFrame:self.bounds];
        _videoView.hidden = YES;
        [self addSubview:_videoView];
        
        _errorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.wzm_width-40, self.wzm_height-40, 20, 20)];
        _errorImageView.image = [WZMPublic imageWithFolder:@"album" imageName:@"album_error.png"];
        [self addSubview:_errorImageView];
    }
    return self;
}

- (void)start {
    _display = YES;
    if (_isGif) {
        [_imageView startGif];
    }
    else if (_isVideo) {
        if (_display) {
            if (_videoUrl) {
                [_videoView playWithUrl:_videoUrl];
            }
        }
    }
}

- (void)stop {
    _display = NO;
    if (_isGif) {
        [_imageView stopGif];
    }
    else if (_isVideo) {
        [_videoView stop];
    }
}

#pragma mark - private method
//根据路径/网址加载图片
- (void)setPath:(NSString *)path {
    if (path.length == 0) return;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        if ([self checkVideo:url network:NO]) {
            //视频
            [self setupVideoUrl:url];
        }
        else {
            _imageData = [NSData dataWithContentsOfFile:path];
            [self setupImageData];
        }
    }
    else {
        NSURL *URL = [NSURL URLWithString:path];
        if (URL == nil) {
            URL = [NSURL URLWithString:[path wzm_getURLEncoded]];
        }
        BOOL isNetImage = NO;
#if WZM_APP
        isNetImage = [[UIApplication sharedApplication] canOpenURL:URL];
#endif
        if (isNetImage) {
            if ([self checkVideo:URL network:YES]) {
                //视频
                [self setupVideoUrl:URL];
            }
            else {
                _imageData = [[WZMImageCache shareCache] dataForKey:path];
                if (_imageData == nil) {
                    [self showPlaceholderImage];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        _imageData = [[WZMImageCache shareCache] getDataWithUrl:path isUseCatch:YES];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self setupImageData];
                        });
                    });
                }
                else {
                    [self setupImageData];
                }
            }
        }
        else {
            [self showPlaceholderImage];
        }
    }
}

//更新image
- (void)setupImageData {
    if (_imageData) {
        _isGif = ([_imageData wzm_contentType] == WZMImageTypeGIF);
        _currentImage = [UIImage imageWithData:_imageData];
        [self setupImageView];
    }
    else {
        [self showPlaceholderImage];
    }
}

//设置图片的宽高比
- (void)setupImageView {
    _imageView.hidden = NO;
    _imageView.frame = [self imageFrame];
    if (_isGif) {
        _imageView.gifData = _imageData;
    }
    else {
        _imageView.image = _currentImage;
    }
}

//设置视频
- (void)setupVideoUrl:(NSURL *)url {
    _isVideo = YES;
    _videoUrl = url;
    _videoView.hidden = NO;
}

//是否是视频
- (BOOL)checkVideo:(NSURL *)url network:(BOOL)network {
    if (network) {
        [self showPlaceholderImage];
        NSString *extension = [url.pathExtension wzm_getLowercase];
        if ([extension isEqualToString:@"mp4"] || [extension isEqualToString:@"mov"] || [extension isEqualToString:@"3gp"] || [extension isEqualToString:@"mpv"]) {
            return YES;
        }
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    return ([tracks count] > 0);
}

//显示占位图
- (void)showPlaceholderImage {
    _currentImage = self.placeholderImage;
    [self setupImageView];
}

//计算imageView的frame
- (CGRect)imageFrame {
    CGRect imageFrame;
    if (_currentImage.size.width > self.bounds.size.width || _currentImage.size.height > self.bounds.size.height) {
        CGFloat imageRatio = _currentImage.size.width/_currentImage.size.height;
        CGFloat photoRatio = self.bounds.size.width/self.bounds.size.height;
        
        if (imageRatio > photoRatio) {
            imageFrame.size = CGSizeMake(self.bounds.size.width, self.bounds.size.width/_currentImage.size.width*_currentImage.size.height);
            imageFrame.origin.x = 0;
            imageFrame.origin.y = (self.bounds.size.height-imageFrame.size.height)/2.0;
        }
        else {
            imageFrame.size = CGSizeMake(self.bounds.size.height/_currentImage.size.height*_currentImage.size.width, self.bounds.size.height);
            imageFrame.origin.x = (self.bounds.size.width-imageFrame.size.width)/2.0;
            imageFrame.origin.y = 0;
        }
    }
    else {
        imageFrame.size = _currentImage.size;
        imageFrame.origin.x = (self.bounds.size.width-_currentImage.size.width)/2.0;
        imageFrame.origin.y = (self.bounds.size.height-_currentImage.size.height)/2.0;
    }
    return imageFrame;
}

- (void)resetConfig {
    _isGif = NO;
    _isVideo = NO;
    _videoUrl = nil;
    _imageData = nil;
    _currentImage = nil;
    [_videoView stop];
    [_imageView stopGif];
    _imageView.gifData = nil;
    _imageView.hidden = YES;
    _videoView.hidden = YES;
    _errorImageView.hidden = YES;
}

#pragma mark - setter getter
- (void)setWzm_image:(id)wzm_image {
    if (_wzm_image == wzm_image) return;
    [self resetConfig];
    if ([wzm_image isKindOfClass:[UIImage class]]) {
        _currentImage = (UIImage *)wzm_image;
        [self setupImageView];
    }
    else if ([wzm_image isKindOfClass:[NSString class]]) {
        if ([_wzm_image isEqualToString:wzm_image]) return;
        [self setPath:(NSString *)wzm_image];
    }
    else if ([wzm_image isKindOfClass:[NSData class]]) {
        _imageData = (NSData *)wzm_image;
        [self setupImageData];
    }
    else if ([wzm_image isKindOfClass:[NSURL class]]) {
        NSURL *url = (NSURL *)wzm_image;
        [self setPath:url.path];
    }
    else if ([wzm_image isKindOfClass:[WZMAlbumPhotoModel class]]) {
        WZMAlbumPhotoModel *model = (WZMAlbumPhotoModel *)wzm_image;
        BOOL isICloud = model.isICloud;
        if (isICloud) {
            [model getThumbnailCompletion:^(UIImage *thumbnail) {
                if (model.isICloud) {
                    self.wzm_image = thumbnail;
                }
            } cloud:nil];
        }
        [model getOriginalCompletion:^(id original) {
            if (original) {
                self.wzm_image = original;
                if (_display) {
                    [self start];
                }
                _errorImageView.hidden = YES;
            }
            else {
                //从iCloud获取图片失败,可以在此处写一些提示或者UI处理
                _errorImageView.hidden = NO;
            }
            if (isICloud) {
                [WZMAlbumHelper postUpdateAlbumNotification];
            }
        }];
        if (isICloud) {
            [WZMAlbumHelper postUpdateAlbumNotification];
        }
    }
    else {
        [self showPlaceholderImage];
    }
    _wzm_image = wzm_image;
}

- (UIImage *)placeholderImage {
    if (_placeholderImage == nil) {
        _placeholderImage = [UIImage wzm_getRectImageByColor:[UIColor whiteColor] size:CGSizeMake(self.wzm_width, self.wzm_width)];
    }
    return _placeholderImage;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_isVideo) {
        return _videoView;
    }
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = (self.bounds.size.width>self.contentSize.width)?(self.bounds.size.width-self.contentSize.width)*0.5:0.0;
    CGFloat offsetY = (self.bounds.size.height>self.contentSize.height)?(self.bounds.size.height-self.contentSize.height)*0.5:0.0;
    CGPoint center = CGPointMake(scrollView.contentSize.width*0.5+offsetX, scrollView.contentSize.height*0.5+offsetY);
    if (_isVideo) {
        _videoView.center = center;
    }
    else {
        _imageView.center = center;
    }
}

#pragma mark - 手势交互
//单击
- (void)singleClick:(UITapGestureRecognizer *)gestureRecognizer {
    [self setDelegeteType:WZMGestureRecognizerTypeSingle];
}

//长按
- (void)longClick:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self setDelegeteType:WZMGestureRecognizerTypeLong];
    }
}

- (void)panClick:(WZMPanGestureRecognizer *)gesture {
    CGPoint point_0 = [gesture translationInView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_isVideo) {
            _startFrame = _videoView.frame;
        }
        else {
            _startFrame = _imageView.frame;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGFloat scale;
        if (point_0.y > 0) {
            scale = 1-(point_0.y/self.wzm_height*0.7);
        }
        else {
            scale = 1.0;
        }
        CGFloat x = _startFrame.origin.x+point_0.x;
        CGFloat y = _startFrame.origin.y+point_0.y;
        if (_isVideo) {
            _videoView.transform = CGAffineTransformMakeScale(scale, scale);
            _videoView.frame = CGRectMake(x, y, _videoView.frame.size.width, _videoView.frame.size.height);
        }
        else {
            _imageView.transform = CGAffineTransformMakeScale(scale, scale);
            _imageView.frame = CGRectMake(x, y, _imageView.frame.size.width, _imageView.frame.size.height);
        }
        if ([self.wzm_delegate respondsToSelector:@selector(photo:didPanWithAlpha:)]) {
            [self.wzm_delegate photo:self didPanWithAlpha:scale];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        if (point_0.y > 100) {
            [UIView animateWithDuration:0.2 animations:^{
                if (_isVideo) {
                    _videoView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    _videoView.frame = _startFrame;
                }
                else {
                    _imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    _imageView.frame = _startFrame;
                }
            }];
            [self setDelegeteType:WZMGestureRecognizerTypeClose];
        }
        else {
            [UIView animateWithDuration:0.2 animations:^{
                if (_isVideo) {
                    _videoView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    _videoView.frame = _startFrame;
                }
                else {
                    _imageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                    _imageView.frame = _startFrame;
                }
                if ([self.wzm_delegate respondsToSelector:@selector(photo:didPanWithAlpha:)]) {
                    [self.wzm_delegate photo:self didPanWithAlpha:1.0];
                }
            }];
        }
    }
}

//双击
- (void)doubleClick:(UITapGestureRecognizer *)gestureRecognizer {
    [self setDelegeteType:WZMGestureRecognizerTypeDouble];
    if (self.zoomScale > WZMPhotoMinScale) {
        [self setZoomScale:WZMPhotoMinScale animated:YES];
    }
    else {
        CGPoint touchPoint;
        if (_isVideo) {
            touchPoint = [gestureRecognizer locationInView:_videoView];
        }
        else {
            touchPoint = [gestureRecognizer locationInView:_imageView];
        }
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat xsize = self.frame.size.width/newZoomScale;
        CGFloat ysize = self.frame.size.height/newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x-xsize/2, touchPoint.y-ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)setDelegeteType: (WZMGestureRecognizerType)type {
    if ([self.wzm_delegate respondsToSelector:@selector(clickAtPhoto:contentType:gestureType:)]) {
        WZMAlbumPhotoType contentType;
        if (_isGif) {
            contentType = WZMAlbumPhotoTypePhotoGif;
        }
        else if (_isVideo) {
            contentType = WZMAlbumPhotoTypeVideo;
        }
        else {
            contentType = WZMAlbumPhotoTypePhoto;
        }
        [self.wzm_delegate clickAtPhoto:self contentType:contentType gestureType:type];
    }
}

- (void)dealloc {
    WZMLog(@"%@释放了",NSStringFromClass(self.class));
}

@end
