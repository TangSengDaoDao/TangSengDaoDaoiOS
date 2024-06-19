//
//  WKLoginViewController.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 tangtaoit. All rights reserved.
//
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "WKLoginViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "WKAPIClient.h"
#import "WKViewController.h"

@interface WKLoginViewController ()

@property(nonatomic,strong) UILabel *welcomeLbl;
@property(nonatomic,strong) UILabel *subtitleLbl;

// server

@property(nonatomic,strong) UILabel *serverLbl;
@property(nonatomic,strong) UITextField *serverFd;

// uid
@property(nonatomic,strong) UILabel *uidLbl;
@property(nonatomic,strong) UITextField *uidFd;

// token
@property(nonatomic,strong) UILabel *tokenLbl;
@property(nonatomic,strong) UITextField *tokenFd;

// button
@property(nonatomic,strong) UIButton *okBtn;

@end

@implementation WKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.welcomeLbl];
    [self.view addSubview:self.subtitleLbl];
   
    self.welcomeLbl.text = @"欢迎使用";
    
    self.subtitleLbl.text = [NSString stringWithFormat:@"悟空IM演示程序，当前SDK版本[v%@]",WKSDK.shared.sdkVersion];
    
    
    [self.view addSubview:self.serverLbl];
    [self.view addSubview:self.serverFd];
    
    [self.view addSubview:self.uidLbl];
    [self.view addSubview:self.uidFd];
    
    [self.view addSubview:self.tokenLbl];
    [self.view addSubview:self.tokenFd];
    
    [self.view addSubview:self.okBtn];
}

- (UILabel *)serverLbl {
    if(!_serverLbl) {
        CGFloat subtitleBottom = self.subtitleLbl.frame.origin.y + self.subtitleLbl.frame.size.height;
        _serverLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, subtitleBottom + 60.0f, 0.0f, 20.0f)];
        _serverLbl.text = @"API基地址";
        [_serverLbl sizeToFit];
    }
    return _serverLbl;
}

- (UITextField *)serverFd {
    if(!_serverFd) {
        CGRect serverLblFrame = self.serverLbl.frame;
        _serverFd = [[UITextField alloc] initWithFrame:CGRectMake(serverLblFrame.origin.x + serverLblFrame.size.width + 20.0f, serverLblFrame.origin.y - 10.0f, 300.0f, 40.0f)];
        _serverFd.text = @"https://api.githubim.com";
    }
    return _serverFd;
}

- (UILabel *)welcomeLbl {
    if(!_welcomeLbl) {
        CGFloat safeTop = UIApplication.sharedApplication.keyWindow.safeAreaInsets.top;
        _welcomeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, safeTop + 50.0f, self.view.frame.size.width, 40.0f)];
        _welcomeLbl.font = [UIFont boldSystemFontOfSize:20.0f];
        _welcomeLbl.textAlignment = NSTextAlignmentCenter;
    }
    return _welcomeLbl;
}

- (UILabel *)subtitleLbl {
    if(!_subtitleLbl) {
        _subtitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, self.welcomeLbl.frame.origin.y + self.welcomeLbl.frame.size.height + 20.0f, self.view.frame.size.width - 20.0f*2.0f, 20.0f)];
        _subtitleLbl.numberOfLines = 0.0f;
        _subtitleLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLbl.textColor = [UIColor grayColor];
        _subtitleLbl.font = [UIFont systemFontOfSize:15.0f];
        _subtitleLbl.textAlignment = NSTextAlignmentCenter;
        
    }
    return _subtitleLbl;
}

- (UILabel *)uidLbl {
    if(!_uidLbl) {
        CGRect serverLblFrame = self.serverLbl.frame;
        _uidLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, serverLblFrame.origin.y + serverLblFrame.size.height + 30.0f, 0.0f, 20.0f)];
        _uidLbl.text = @"登录账号";
        [_uidLbl sizeToFit];
    }
    return _uidLbl;
}

- (UITextField *)uidFd {
    if(!_uidFd) {
        CGRect uidLblFrame = self.uidLbl.frame;
        _uidFd = [[UITextField alloc] initWithFrame:CGRectMake(uidLblFrame.origin.x + uidLblFrame.size.width + 20.0f, uidLblFrame.origin.y - 10.0f, 300.0f, 40.0f)];
        _uidFd.placeholder = @"演示下，随便输，唯一即可";
    }
    return _uidFd;
}

- (UILabel *)tokenLbl {
    if(!_tokenLbl) {
        CGRect uidLblFrame = self.uidLbl.frame;
        _tokenLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, uidLblFrame.origin.y + uidLblFrame.size.height + 30.0f, 0.0f, 20.0f)];
        _tokenLbl.text = @"登录密码";
        [_tokenLbl sizeToFit];
    }
    return _tokenLbl;
}

- (UITextField *)tokenFd {
    if(!_tokenFd) {
        CGRect tokenLblFrame = self.tokenLbl.frame;
        _tokenFd = [[UITextField alloc] initWithFrame:CGRectMake(tokenLblFrame.origin.x + tokenLblFrame.size.width + 20.0f, tokenLblFrame.origin.y - 10.0f, 300.0f, 40.0f)];
        _tokenFd.placeholder = @"演示下，随便输";
    }
    return _tokenFd;
}

- (UIButton *)okBtn {
    if(!_okBtn) {
        _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, self.tokenLbl.frame.origin.y + 60.0f, self.view.frame.size.width - 40.0f, 50.0f)];
        _okBtn.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:99.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
        _okBtn.layer.masksToBounds = YES;
        _okBtn.layer.cornerRadius = 4.0f;
        [_okBtn addTarget:self action:@selector(okPressed) forControlEvents:UIControlEventTouchUpInside];
        [_okBtn setTitle:@"登录" forState:UIControlStateNormal];
    }
    return _okBtn;
}

-(void) okPressed {
    [WKAPIClient.shared setBaseURL:self.serverFd.text];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if([[self.serverFd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        hud.label.text = @"API基地址不能为空！";
        [hud hideAnimated:YES afterDelay:1.0f];
        return;
    }
    
    if([[self.uidFd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        hud.label.text = @"登录账号不能为空！";
        [hud hideAnimated:YES afterDelay:1.0f];
        return;
    }
    
    hud.label.text = @"登录中...";
    __weak typeof(self) weakSelf = self;
    [WKAPIClient.shared GET:@"/route" parameters:nil complete:^(id  _Nonnull respose, NSError * _Nonnull error) {
        if(error) {
            NSLog(@"error--->%@",error);
            hud.label.text = @"登录失败！";
            [hud hideAnimated:YES afterDelay:1.0f];
            return;
        }
        [hud hideAnimated:YES];
        
        NSString *tcpAddr = respose[@"tcp_addr"];
        NSArray *addrs = [tcpAddr componentsSeparatedByString:@":"];
        WKViewController *vc = [WKViewController new];
        vc.ip = addrs[0];
        vc.port = [addrs[1] integerValue];
        vc.uid = weakSelf.uidFd.text;
        vc.token = weakSelf.tokenFd.text;
        if([vc.token isEqualToString:@""]) {
            vc.token = @"123456";
        }
        
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
    
   
}

@end
