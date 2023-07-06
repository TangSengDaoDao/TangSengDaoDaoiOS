//
//  WKDeleteAccountVercodeVC.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

typedef enum : NSUInteger {
    CodeStatusNormal, // 正常
    CodeStatusGeting, // 获取中
    CodeStatusCountdown // 倒计时中
} CodeStatus;

#import "WKDeleteAccountVercodeVC.h"

@interface WKDeleteAccountVercodeVC ()

@property(nonatomic,strong) UIButton *okBtn;

@property(nonatomic,strong) UIView *itemView;

@property(nonatomic,strong) UITextField *vercodeFd;

@property(nonatomic,strong) UIButton *getCodeBtn;
@property(nonatomic, strong) NSTimer *codeTimer;
@property(nonatomic) NSInteger countdownSec; //倒计时
@property(nonatomic,assign) CodeStatus status;

@end

static NSDate *lastGetCodeDate;

@implementation WKDeleteAccountVercodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"请输入验证码");
    
    self.rightView = self.okBtn;
    
    [self.view addSubview:self.itemView];
    [self.itemView addSubview:self.vercodeFd];
    
    self.vercodeFd.rightView = self.getCodeBtn;
    self.vercodeFd.rightViewMode = UITextFieldViewModeAlways;
    
    [self okEnabled:NO];
    
    [self layoutViews];
    
    
    BOOL startFlag = false;
    if(lastGetCodeDate) {
       NSInteger second = [[NSDate date] timeIntervalSince1970] - [lastGetCodeDate timeIntervalSince1970];
        if(second<60) {
            self.countdownSec = 60 - second;
            self.status = CodeStatusCountdown;
            startFlag = true;
            [self startCountDown];
        }
    }
    if(!startFlag) {
        [self requestSendCode];
    }
  
}

-(void) requestSendCode {
    __weak typeof(self) weakSelf = self;
    self.status = CodeStatusGeting;
    [self refreshSendCode];
    [self sendCode].then(^{
        lastGetCodeDate  = [NSDate date];
        weakSelf.countdownSec = 60.0f; // 60秒倒计时
        weakSelf.status = CodeStatusCountdown;
        [weakSelf startCountDown];
    }).catch(^(NSError *error){
        weakSelf.status = CodeStatusNormal;
        [weakSelf refreshSendCode];
        [weakSelf.view showHUDWithHide:error.domain];
    });
}

-(void) startCountDown {
    [self refreshSendCode];
    _codeTimer =
    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(refreshSendCode)
                                   userInfo:nil
                                    repeats:YES];
}


-(void) refreshSendCode {
    if(self.status == CodeStatusNormal) {
        self.getCodeBtn.alpha = 1.0f;
        self.getCodeBtn.enabled = YES;
        [self.getCodeBtn setTitle:LLang(@"获取验证码") forState:UIControlStateNormal];
    }else if(self.status == CodeStatusGeting) {
        self.getCodeBtn.alpha = 0.5f;
        self.getCodeBtn.enabled = NO;
        [self.getCodeBtn setTitle:LLang(@"获取中") forState:UIControlStateNormal];
    }else if(self.status == CodeStatusCountdown) {
        if(self.countdownSec<=1) {
            [_codeTimer invalidate];
            _codeTimer = nil;
            self.status = CodeStatusNormal;
            [self refreshSendCode];
            return;
        }
        self.getCodeBtn.alpha = 0.5f;
        self.getCodeBtn.enabled = NO;
        [_getCodeBtn setTitle:[NSString stringWithFormat:LLang(@"重新发送(%li)"),(long)--self.countdownSec] forState:UIControlStateNormal];
        
    }
    [_getCodeBtn sizeToFit];
    
}

-(void) layoutViews {
    self.vercodeFd.lim_height = self.itemView.lim_height;
}

- (UIButton *)okBtn {
    if(!_okBtn) {
        _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 30.0f)];
        [_okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_okBtn setTitle:LLang(@"确定") forState:UIControlStateNormal];
        [[_okBtn titleLabel] setFont:[WKApp.shared.config appFontOfSize:14.0f]];
        _okBtn.backgroundColor = WKApp.shared.config.themeColor;
        _okBtn.layer.masksToBounds = YES;
        _okBtn.layer.cornerRadius = 4.0f;
        
        __weak typeof(self) weakSelf = self;
        [_okBtn lim_addEventHandler:^{
            if([weakSelf.vercodeFd.text isEqualToString:@""]) {
                [weakSelf.view showHUDWithHide:@"验证码不能为空！"];
                return;
            }
            [weakSelf.view showHUD];
            [weakSelf userDestory:weakSelf.vercodeFd.text].then(^{
                [weakSelf.view hideHud];
                [WKApp.shared logout];
            }).catch(^(NSError *error){
                [weakSelf.view hideHud];
                [weakSelf.view showHUDWithHide:error.domain];
            });
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

-(void) okEnabled:(BOOL)enabled {
    if(enabled) {
        self.okBtn.enabled = enabled;
        self.okBtn.backgroundColor = WKApp.shared.config.themeColor;
    }else {
        self.okBtn.enabled = enabled;
        self.okBtn.backgroundColor = [WKApp.shared.config.themeColor colorWithAlphaComponent:0.6f];
    }
}

- (UIView *)itemView {
    if(!_itemView) {
        _itemView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.navigationBar.lim_bottom, WKScreenWidth, 60.0f)];
        _itemView.backgroundColor = WKApp.shared.config.cellBackgroundColor;
    }
    return _itemView;
}

- (UITextField *)vercodeFd {
    if(!_vercodeFd) {
        CGFloat space = 10.0f;
        _vercodeFd = [[UITextField alloc] initWithFrame:CGRectMake(space, 0.0f, WKScreenWidth-space*2, 0.0f)];
        _vercodeFd.placeholder = LLang(@"请输入验证码");
        _vercodeFd.keyboardType = UIKeyboardTypeNumberPad;
        [_vercodeFd addTarget:self action:@selector(vercodeChange:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _vercodeFd;
}

-(void) vercodeChange:(UITextField*)fd {
    if([fd.text isEqualToString:@""]) {
        [self okEnabled:NO];
    }else {
        [self okEnabled:YES];
    }
}

- (UIButton *)getCodeBtn {
    if(!_getCodeBtn) {
        _getCodeBtn = [[UIButton alloc] init];
        [_getCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_getCodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _getCodeBtn.backgroundColor = WKApp.shared.config.themeColor;
        _getCodeBtn.layer.masksToBounds = YES;
        [_getCodeBtn setContentEdgeInsets:UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)];
        _getCodeBtn.layer.cornerRadius = 4.0f;
        [[_getCodeBtn titleLabel] setFont:[WKApp.shared.config appFontOfSize:15.0f]];
        [_getCodeBtn sizeToFit];
        
        
        [_getCodeBtn lim_addEventHandler:^{
            [self requestSendCode];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _getCodeBtn;
}


- (AnyPromise *)sendCode {
    return [[WKAPIClient sharedClient] POST:@"user/sms/destroy" parameters:nil];
}

-(AnyPromise*) userDestory:(NSString*)code {
    return [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"user/destroy/%@",code] parameters:nil];
}

- (void)dealloc {
    if(self.codeTimer) {
        [self.codeTimer invalidate];
        self.codeTimer = nil;
    }
}

@end
