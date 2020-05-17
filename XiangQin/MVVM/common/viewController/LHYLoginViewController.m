//
//  LHYLoginViewController.m
//  XiangQin
//
//  Created by Zhaomeng Wang on 2020/5/16.
//  Copyright © 2020 富秋. All rights reserved.
//

#import "LHYLoginViewController.h"

@interface LHYLoginViewController ()<UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) UIButton *codeBtn;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UITextField *passwordTextField;

@end

@implementation LHYLoginViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.time = 60;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
#else
    self.automaticallyAdjustsScrollViewInsets = NO;
#endif
    scrollView.delegate = self;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    WZMAutoHeader *header = [[WZMAutoHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, WZM_SCREEN_WIDTH, 150.0+WZM_NAVBAR_HEIGHT)];
    header.image = [UIImage imageNamed:@"fl_mine_top"];
    [scrollView addSubview:header];
    
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(20.0, header.wzm_maxY-80.0, WZM_SCREEN_WIDTH-40.0, 250.0)];
    inputView.backgroundColor = [UIColor whiteColor];
    inputView.wzm_cornerRadius = 5.0;
    [scrollView addSubview:inputView];
    [inputView wzm_setShadowRadius:5.0 offset:0.0 color:THEME_COLOR alpha:0.5];
    
    UILabel *loginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, inputView.wzm_width, 40.0)];
    loginLabel.text = @"手机登录";
    loginLabel.textColor = [UIColor darkGrayColor];
    loginLabel.textAlignment = NSTextAlignmentCenter;
    loginLabel.font = [UIFont systemFontOfSize:12.0];
    [inputView addSubview:loginLabel];
    
    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, loginLabel.wzm_maxY+10.0, inputView.wzm_width-40.0, 40.0)];
    phoneTextField.wzm_cornerRadius = 20.0;
    phoneTextField.wzm_borderColor = THEME_COLOR;
    phoneTextField.wzm_borderWidth = 0.5;
    phoneTextField.font = [UIFont systemFontOfSize:15.0];
    phoneTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 40.0)];
    phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    phoneTextField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 40.0)];
    phoneTextField.rightViewMode = UITextFieldViewModeAlways;
    [inputView addSubview:phoneTextField];
    self.phoneTextField = phoneTextField;
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, phoneTextField.wzm_maxY+20.0, inputView.wzm_width-40.0, 40.0)];
    passwordTextField.wzm_cornerRadius = 20.0;
    passwordTextField.wzm_borderColor = THEME_COLOR;
    passwordTextField.wzm_borderWidth = 0.5;
    passwordTextField.font = [UIFont systemFontOfSize:15.0];
    passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 40.0)];
    passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    passwordTextField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80.0, 40.0)];
    passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    [inputView addSubview:passwordTextField];
    self.passwordTextField = passwordTextField;
    
    UIButton *codeBtn = [[UIButton alloc] initWithFrame:passwordTextField.rightView.bounds];
    codeBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
    [codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [codeBtn addTarget:self action:@selector(codeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [codeBtn setBackgroundImage:[UIImage wzm_getImageByColor:THEME_COLOR] forState:UIControlStateNormal];
    [passwordTextField.rightView addSubview:codeBtn];
    self.codeBtn = codeBtn;
    
    UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0, passwordTextField.wzm_maxY+30.0, inputView.wzm_width-40.0, 40.0)];
    loginBtn.wzm_cornerRadius = 20.0;
    loginBtn.enabled = NO;
    loginBtn.adjustsImageWhenHighlighted = NO;
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage wzm_getImageByColor:THEME_COLOR] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:loginBtn];
    
    //监听输入框变化
    @wzm_weakify(self);
    [phoneTextField wzm_executeInput:^(UITextField *textField_, WZMTextInputType textInput_) {
        if (textInput_ == WZMTextInputTypeChange) {
            @wzm_strongify(self);
            loginBtn.enabled = (self.phoneTextField.text.length == 11 && self.passwordTextField.text.length >= 4);
        }
    }];
    
    [passwordTextField wzm_executeInput:^(UITextField *textField_, WZMTextInputType textInput_) {
        if (textInput_ == WZMTextInputTypeChange) {
            @wzm_strongify(self);
            loginBtn.enabled = (self.phoneTextField.text.length == 11 && self.passwordTextField.text.length >= 4);
        }
    }];
}

- (void)loginBtnClick:(UIButton *)btn {
    
}

- (void)codeBtnClick:(UIButton *)btn {
    WZMDispatch_create_main_queue_timer(@"codeTime", 1, ^{
        if (self.time > 0) {
            self.time --;
            self.codeBtn.enabled = NO;
            NSString *timeStr = [NSString stringWithFormat:@"等待(%@)",@(self.time)];
            [self.codeBtn setTitle:timeStr forState:UIControlStateNormal];
        }
        else {
            self.codeBtn.enabled = YES;
            WZMDispatch_cancelTimer(@"codeTime");
            [self.codeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        }
    });
}

- (BOOL)navigatonBarIsHidden{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
