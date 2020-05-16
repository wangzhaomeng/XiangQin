//
//  WZMLogView.m
//  lhy_test
//
//  Created by WangZhaomeng on 2018/1/29.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "WZMLogView.h"
#import "WZMMacro.h"
#import "UIView+wzmcate.h"
#import "UIColor+wzmcate.h"
#import "WZMLogTableViewCell.h"
#import "WZMDefined.h"

@interface LHYMessageView : UIView<UITableViewDelegate,UITableViewDataSource> {
    BOOL _color;
    UITableView *_tableView;
}
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation LHYMessageView

+ (instancetype)shareMessageView {
    static LHYMessageView *logView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logView = [[LHYMessageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return logView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.scrollEnabled = YES;
        self.dataList = [[NSMutableArray alloc] initWithCapacity:0];
        self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        
        CGRect rect = self.bounds;
        rect.origin.x += 5;
        rect.origin.y += 64;
        rect.size.width -= 10;
        rect.size.height -= 84;
        _tableView = [[UITableView alloc] initWithFrame:rect];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollsToTop = NO;
        _tableView.separatorColor = [UIColor colorWithRed:230/255. green:230/255. blue:230/255. alpha:0.5];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _tableView.tableFooterView = [UIView new];
        [self addSubview:_tableView];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        closeBtn.frame = CGRectMake(12, 20, 44, 44);
        closeBtn.tag = 0;
        closeBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        closeBtn.backgroundColor = [UIColor grayColor];
        closeBtn.layer.masksToBounds = YES;
        closeBtn.layer.cornerRadius = 22;
        [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [closeBtn setTitleColor:[UIColor wzm_getDynamicColorByLightColor:[UIColor blueColor] darkColor:[UIColor redColor]] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
        
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        clearBtn.frame = CGRectMake(self.bounds.size.width-56, 20, 44, 44);
        clearBtn.tag = 1;
        clearBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        clearBtn.backgroundColor = [UIColor grayColor];
        clearBtn.layer.masksToBounds = YES;
        clearBtn.layer.cornerRadius = 22;
        [clearBtn setTitle:@"清除" forState:UIControlStateNormal];
        [clearBtn setTitleColor:[UIColor wzm_getDynamicColorByLightColor:[UIColor blueColor] darkColor:[UIColor redColor]] forState:UIControlStateNormal];
        [clearBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearBtn];
        
        UIButton *topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        topBtn.frame = CGRectMake(CGRectGetMaxX(closeBtn.frame),
                                  _tableView.frame.origin.y-44,
                                  CGRectGetMinX(clearBtn.frame)-CGRectGetMaxX(closeBtn.frame),
                                  44);
        topBtn.tag = 2;
        [topBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:topBtn];
        
        UIButton *bottomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        bottomBtn.frame = CGRectMake(0, self.bounds.size.height-20, self.bounds.size.width, 20);
        bottomBtn.tag = 3;
        [bottomBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:bottomBtn];
    }
    return self;
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataList.count) {
        WZMLogModel *model = [self.dataList objectAtIndex:indexPath.row];
        return model.height+20;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WZMLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"logCell"];
    if (cell == nil) {
        cell = [[WZMLogTableViewCell alloc] initWithWidth:_tableView.wzm_width-10 style:UITableViewCellStyleDefault reuseIdentifier:@"logCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < self.dataList.count) {
        WZMLogModel *model = [self.dataList objectAtIndex:indexPath.row];
        [cell setConfig:model];
    }
    
    return cell;
}

- (void)btnClick:(UIButton *)btn {
    if (btn.tag == 0) {
        //关闭
        self.scrollEnabled = YES;
        [self removeFromSuperview];
    }
    else if (btn.tag == 1) {
        //清除
        self.scrollEnabled = YES;
        [self.dataList removeAllObjects];
        [_tableView reloadData];
    }
    else if (btn.tag == 2) {
        //置顶
        self.scrollEnabled = NO;
        [self scrollsToTopAnimated:YES];
    }
    else {
        //置底
        self.scrollEnabled = YES;
        [self scrollsToBottomAnimated:YES];
    }
}

- (void)scrollsToTopAnimated:(BOOL)animated {
    [_tableView setContentOffset:CGPointMake(0, 0) animated:animated];
}

- (void)scrollsToBottomAnimated:(BOOL)animated {
    if (self.scrollEnabled) {
        if (self.dataList.count > 0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.scrollEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.bounds.size.height > scrollView.contentSize.height) {
        self.scrollEnabled = YES;
    }
    else {
        CGFloat offsetY = scrollView.contentOffset.y+scrollView.bounds.size.height-scrollView.contentSize.height;
        if (offsetY+60 > 0) {
            self.scrollEnabled = YES;
        }
    }
}

- (void)outputString:(NSString *)string {
    
    UIColor *color = (_color ? [UIColor wzm_getDynamicColorByLightColor:[UIColor blueColor] darkColor:[UIColor redColor]] : [UIColor wzm_getDynamicColorByLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]]);
    NSMutableAttributedString *muAttStr = [[NSMutableAttributedString alloc] initWithString:string];
    [muAttStr addAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:[UIFont systemFontOfSize:8]}
                    range:NSMakeRange(0, muAttStr.length)];
    
    WZMLogModel *model = [[WZMLogModel alloc] init];
    model.text = string;
    model.attributedText = [muAttStr copy];
    [model setConfigWithWidth:_tableView.wzm_width-10 font:[UIFont systemFontOfSize:8]];
    [self.dataList addObject:model];
    
    if (self.superview) {
        [_tableView reloadData];
        [self scrollsToBottomAnimated:YES];
    }
    _color = !_color;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (newSuperview) {
        [_tableView reloadData];
        [self scrollsToBottomAnimated:YES];
    }
}

@end

@interface WZMLogView ()

@property (nonatomic, assign, getter=isStart) BOOL start;

@end

@implementation WZMLogView

+ (void)startLog {
#if WZM_APP
    dispatch_async(dispatch_get_main_queue(), ^{
        WZMLogView *logView = [WZMLogView shareLogView];
        logView.start = YES;
        if (logView.superview == nil) {
            [[UIApplication sharedApplication].delegate.window addSubview:logView];
        }
    });
#endif
}

+ (NSString *)outputString:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
        WZMLogView *logView = [WZMLogView shareLogView];
        if (logView.isStart) {
            if (string) {
                LHYMessageView *messageView = [LHYMessageView shareMessageView];
                [messageView outputString:string];
            }
        }
    });
    return (string ? string : @"");
}

+ (instancetype)shareLogView {
    static WZMLogView *logView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logView = [[WZMLogView alloc] initWithFrame:CGRectMake(0, WZM_NAVBAR_HEIGHT, 40, 40)];
        logView.layer.masksToBounds = YES;
        logView.layer.cornerRadius = 20;
        logView.start = NO;
    });
    return logView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
        
        UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
        label.text = @"日志";
        label.textColor = [UIColor wzm_getDynamicColorByLightColor:[UIColor blueColor] darkColor:[UIColor redColor]];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        [self addSubview:label];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
        [self addGestureRecognizer:tapRec];
        
        UIPanGestureRecognizer *panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognizer:)];
        [self addGestureRecognizer:panRec];
    }
}

- (void)tapRecognizer:(UILongPressGestureRecognizer *)recognizer {
#if WZM_APP
    LHYMessageView *messageView = [LHYMessageView shareMessageView];
    if (messageView.superview == nil) {
        [[UIApplication sharedApplication].delegate.window addSubview:messageView];
    }
#endif
}

- (void)panRecognizer:(UIPanGestureRecognizer *)recognizer {
    UIView *tapView = recognizer.view;
    CGPoint point_0 = [recognizer translationInView:tapView];
    
    static CGRect rect;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        rect = tapView.frame;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat x = rect.origin.x+point_0.x;
        CGFloat y = rect.origin.y+point_0.y;
        
        if (x < 0 || x > WZM_SCREEN_WIDTH-tapView.frame.size.width) {
            x = tapView.frame.origin.x;
        }
        if (y < WZM_NAVBAR_HEIGHT || y > WZM_SCREEN_HEIGHT-WZM_TABBAR_HEIGHT-tapView.frame.size.height) {
            y = tapView.frame.origin.y;
        }
        
        tapView.frame = CGRectMake(x, y, tapView.frame.size.width, tapView.frame.size.height);
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        CGRect rect = self.frame;
        if (self.center.x <= WZM_SCREEN_WIDTH/2) {
            rect.origin.x = 0.0;
        }
        else {
            rect.origin.x = WZM_SCREEN_WIDTH-rect.size.width;
        }
        [UIView animateWithDuration:.2 animations:^{
            self.frame = rect;
        }];
    }
}

@end
