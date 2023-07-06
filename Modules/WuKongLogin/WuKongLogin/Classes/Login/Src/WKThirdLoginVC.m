//
//  WKThirdLoginVC.m
//  WuKongLogin
//
//  Created by tt on 2023/6/25.
//

#import "WKThirdLoginVC.h"
#import "WKAuthWebViewVC.h"
#import "WKLoginVC.h"

@interface WKThirdLoginVC ()

@property(nonatomic,strong) UIImageView *bgImgView;

@property(nonatomic,strong) UILabel *titleLbl;

@property(nonatomic,strong) UILabel *tipLbl;

@property(nonatomic,strong) UIButton *giteeBtn;
@property(nonatomic,strong) UIButton *githubBtn;

@end

@implementation WKThirdLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.titleLbl];
    [self.view addSubview:self.tipLbl];
    [self.view addSubview:self.giteeBtn];
    [self.view addSubview:self.githubBtn];
    
    [self layout];
}

-(void) layout {
    self.titleLbl.lim_top = 138.0f;
    self.titleLbl.lim_centerX_parent = self.view;
    
    self.tipLbl.lim_top = self.titleLbl.lim_bottom + 250.0f;
    self.tipLbl.lim_centerX_parent = self.view;
    
    self.giteeBtn.lim_top = self.tipLbl.lim_bottom + 40.0f;
    self.githubBtn.lim_top = self.giteeBtn.lim_top;
    
    CGFloat btw = 80.0f;
    
    CGFloat contentWidth = self.giteeBtn.lim_width + btw + self.githubBtn.lim_width;
    self.giteeBtn.lim_left = self.view.lim_width/2.0f - contentWidth/2.0f;
    self.githubBtn.lim_left= self.giteeBtn.lim_right + btw;

}

- (UIImageView *)bgImgView {
    if(!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithImage:[self image:@"ThirdLogin"]];
        _bgImgView.lim_size = self.view.lim_size;
    }
    return _bgImgView;
}

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [WKApp.shared.config appFontOfSizeMedium:30.0f];
        _titleLbl.text = [NSString stringWithFormat:@"欢迎登录%@",WKApp.shared.config.appName];
        _titleLbl.textColor = [UIColor whiteColor];
        [_titleLbl sizeToFit];
        
        _titleLbl.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(titleLongPressed:)];
        
        [_titleLbl addGestureRecognizer:longPress];
    }
    return _titleLbl;
}

- (UILabel *)tipLbl {
    if(!_tipLbl) {
        _tipLbl = [[UILabel alloc] init];
        _tipLbl.font = [WKApp.shared.config appFontOfSize:14.0f];
        _tipLbl.text = @"—  第三方登录  —";
        _tipLbl.textColor = [UIColor whiteColor];
        [_tipLbl sizeToFit];
    }
    return _tipLbl;
}

-(UIButton*) giteeBtn {
    if(!_giteeBtn) {
        _giteeBtn = [[UIButton alloc] init];
        [_giteeBtn setImage:[self image:@"gitee"] forState:UIControlStateNormal];
        [_giteeBtn sizeToFit];
        
        [_giteeBtn addTarget:self action:@selector(giteeLoginPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _giteeBtn;
}

- (UIButton *)githubBtn {
    if(!_githubBtn) {
        _githubBtn = [[UIButton alloc] init];
        [_githubBtn setImage:[self image:@"github"] forState:UIControlStateNormal];
        [_githubBtn sizeToFit];
        [_githubBtn addTarget:self action:@selector(githubLoginPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _githubBtn;
}

-(void) titleLongPressed:(UILongPressGestureRecognizer*)gestureRecognizer {
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        WKLoginVC *vc = [[WKLoginVC alloc] init];
        [WKNavigationManager.shared pushViewController:vc animated:YES];
    }
}

-(void) giteeLoginPressed {
    __weak typeof(self) weakself = self;
    [WKAPIClient.sharedClient GET:@"user/thirdlogin/authcode" parameters:nil].then(^(NSDictionary *resultDict){
        NSString *authcode = resultDict[@"authcode"];
        if(authcode) {
            WKAuthWebViewVC *vc = [[WKAuthWebViewVC alloc] init];
            vc.authcode = authcode;
            vc.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/gitee?authcode=%@",WKAPIClient.sharedClient.config.baseUrl,authcode]];
            [WKNavigationManager.shared pushViewController:vc animated:YES];
        }
    }).catch(^(NSError *error){
        [weakself.view showHUDWithHide:error.domain];
    });
   
}

-(void) githubLoginPressed {
    __weak typeof(self) weakself = self;
    [WKAPIClient.sharedClient GET:@"user/thirdlogin/authcode" parameters:nil].then(^(NSDictionary *resultDict){
        NSString *authcode = resultDict[@"authcode"];
        if(authcode) {
            WKAuthWebViewVC *vc = [[WKAuthWebViewVC alloc] init];
            vc.authcode = authcode;
            vc.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@user/github?authcode=%@",WKAPIClient.sharedClient.config.baseUrl,authcode]];
            [WKNavigationManager.shared pushViewController:vc animated:YES];
        }
    }).catch(^(NSError *error){
        [weakself.view showHUDWithHide:error.domain];
    });
}


-(UIImage*) image:(NSString*)name {
    return [[WKApp shared] loadImage:name moduleID:@"WuKongLogin"];
}
@end
