//
//  WKSettingView.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKSettingView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface WKSettingView ()

@property(nonatomic,strong) UIView *contentView;

@property(nonatomic,strong) UISegmentedControl *segmentCtl;

@property(nonatomic,strong) UITextField *inputFd;

@property(nonatomic,strong) UIButton *okBtn;

@end

@implementation WKSettingView

- (instancetype)init {
    self = [super init];
    if(self) {
        CGFloat width =  UIScreen.mainScreen.bounds.size.width;
        CGFloat height =  UIScreen.mainScreen.bounds.size.height;
        self.frame = CGRectMake(0.0f, -0.0f, width, height);
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.segmentCtl];
        [self.contentView addSubview:self.inputFd];
        [self.contentView addSubview:self.okBtn];
        
        UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tapGest];
    }
    return  self;
}

-(UIView*) contentView {
    if(!_contentView) {
        CGFloat height = 200.0f;
        CGFloat width = 250.0f;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2.0f - width/2.0f, -height, width, height)];
//        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 4.0f;
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentView.layer.shadowOpacity = 0.5f;
        _contentView.layer.shadowRadius = 2.f;
        _contentView.layer.shadowOffset = CGSizeMake(2,2);
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (BOOL)isShow {
    return self.superview != nil;
}

- (void)setDefaultChannel:(WKChannel *)defaultChannel {
    _defaultChannel = defaultChannel;
    if(defaultChannel) {
        if(defaultChannel.channelType == WK_PERSON) {
            self.segmentCtl.selectedSegmentIndex = 0;
        }else {
            self.segmentCtl.selectedSegmentIndex = 1;
        }
        self.inputFd.text = self.defaultChannel.channelId;
    }
    
}

-(void) show {
    if (self.superview != nil) {
           return;
    }
    UIWindow *window = [self findWindow];
    [window endEditing:true];
    [window addSubview:self];
    CGRect contentFrame = self.contentView.frame;
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(contentFrame.origin.x, 200.0f, contentFrame.size.width, contentFrame.size.height);
    } completion:^(BOOL finished) {
                   
    }];
}

-(void) hide {
    [UIView animateWithDuration:0.2 animations:^{
            CGRect rect = self.contentView.frame;
            rect.origin.y = 0-rect.size.height;
            self.contentView.frame = rect;
           
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(UIWindow*) findWindow {
            
   return UIApplication.sharedApplication.delegate.window;
}

- (UISegmentedControl *)segmentCtl {
    if(!_segmentCtl) {
        _segmentCtl = [[UISegmentedControl alloc] initWithItems:@[@"单聊",@"群聊"]];
        _segmentCtl.selectedSegmentIndex = 0;
        
        [_segmentCtl addTarget:self action:@selector(selectChange:) forControlEvents:UIControlEventValueChanged];
        
       CGRect frame =  _segmentCtl.frame;
        frame.origin.x = self.contentView.frame.size.width/2.0f - frame.size.width/2.0f;
        frame.origin.y = 10.0f;
        _segmentCtl.frame = frame;
    }
    return _segmentCtl;
}

- (UITextField *)inputFd {
    if(!_inputFd) {
        CGRect segmentFrame = self.segmentCtl.frame;
        CGRect contentViewFrame = self.contentView.frame;
        _inputFd = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, segmentFrame.origin.y + segmentFrame.size.height + 20.0f, contentViewFrame.size.width - 40.0f, 40.0f)];
        _inputFd.placeholder = @"请输入对方登录名";
    }
    return _inputFd;
}

- (UIButton *)okBtn {
    if(!_okBtn) {
        CGRect contentViewFrame = self.contentView.frame;
        CGRect inputFrame = self.inputFd.frame;
        _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, inputFrame.origin.y + inputFrame.size.height + 30.0f, contentViewFrame.size.width - 40.0f, 40.0f)];
        [_okBtn setTitle:@"确定" forState:UIControlStateNormal];
        _okBtn.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:99.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
        _okBtn.layer.masksToBounds = YES;
        _okBtn.layer.cornerRadius = 4.0f;
        [_okBtn addTarget:self action:@selector(okPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

-(void) okPressed {
    if([[self.inputFd.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"输入不能为空！";
        [hud hideAnimated:YES afterDelay:1.0f];
        return;
    }
    if(self.onChannelSelct) {
        WKChannel *channel;
        if(self.segmentCtl.selectedSegmentIndex == 0) {
            channel = [WKChannel personWithChannelID:self.inputFd.text];
        }else {
            channel = [WKChannel groupWithChannelID:self.inputFd.text];
        }
        self.onChannelSelct(channel);
    }
}

-(void) selectChange:(UISegmentedControl *)sc {
    if(sc.selectedSegmentIndex == 0) {
        _inputFd.placeholder = @"请输入对方登录名";
    }else {
        _inputFd.placeholder = @"请输入群编号";
    }
}
@end
