//
//  WKViewController.m
//  WuKongIMSDK
//
//  Created by tangtaoit on 11/23/2019.
//  Copyright (c) 2019 tangtaoit. All rights reserved.

#import "WKViewController.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "WKMessageTableView.h"
#import "WKSettingView.h"
#import "WKAPIClient.h"
@interface WKViewController ()<WKConnectionManagerDelegate,UITextFieldDelegate,WKChatManagerDelegate>

@property(nonatomic,copy) NSString *status;

@property(nonatomic,strong) WKMessageTableView *tableView;

@property(nonatomic,strong) WKSettingView *settingView;


@property(nonatomic,strong) UIView *inputView;
@property(nonatomic,strong) UITextField *inputFd;

@property(nonatomic,strong) UIButton *toBtn; // 聊天对象
@property(nonatomic,strong) WKChannel *toChannel;

@property(nonatomic,assign) BOOL hasAlert;

@end

@implementation WKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.status = @"未连接";
    self.view.backgroundColor = [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
    [self refreshTitle];
    
    [WKSDK.shared.chatManager addDelegate:self];
    [WKSDK.shared.connectionManager addDelegate:self];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:self.toBtn];
    
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    [self.view addSubview:self.inputView];
    [self.view addSubview:self.tableView];
    
    
   
    
    
    [self initOptions]; // 初始化配置
    [self connect]; // 连接IM
    
  
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
}

-(void) initOptions {
    WKOptions *options = [[WKOptions alloc] init];
    options.host = self.ip;
    options.port = self.port;
    
    // 设置连接信息
    WKConnectInfo *connectInfo = [WKConnectInfo new];
    connectInfo.uid = self.uid;
    connectInfo.token = self.token;
    connectInfo.name = self.uid;
    
    options.connectInfo = connectInfo;
    WKSDK.shared.options = options;
}

// 连接
-(void) connect {
    [WKSDK.shared.connectionManager addDelegate:self];
    [WKSDK.shared.connectionManager connect];
}

// 断开
-(void) disconnect {
    [WKSDK.shared.connectionManager disconnect:YES];
}


-(void) refreshTitle {
    self.title = [NSString stringWithFormat:@"%@(%@)",self.uid,self.status];
}



#pragma mark -- WKConnectionManagerDelegate

- (void)onConnectStatus:(WKConnectStatus)status reasonCode:(WKReason)reasonCode {
    NSLog(@"连接状态-->%hhu",reasonCode);
    if(reasonCode == WK_REASON_SUCCESS) {
        self.status = @"已连接";
    }else {
        self.status = @"已断开";
    }
    [self refreshTitle];
    
    if(reasonCode == WK_REASON_KICK) { // 被踢
        UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:@"您账号在其他地方登录" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertCtl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        
        [self presentViewController:alertCtl animated:YES completion:nil];
    }
}

#pragma mark -- WKChatManagerDelegate

- (void)onRecvMessages:(WKMessage *)message left:(NSInteger)left {
    if(self.toChannel) {
        return;
    }
    if(message.channel.channelType != WK_PERSON || self.hasAlert) {
        return;
    }
    self.hasAlert = true;
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"%@想跟你聊天",message.channel.channelId] preferredStyle:UIAlertControllerStyleAlert];
    
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.hasAlert = false;
    }]];
    
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.hasAlert = false;
        [self.toBtn setTitle:message.channel.channelId forState:UIControlStateNormal];
        [self reloadChannelMessage:message.channel];
    }]];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
    
}




#pragma mark -- 其他

-(void) settingPressed {
   
    [self showSetting];
}

-(void) showSetting {
    [self.settingView show];
}


- (WKSettingView *)settingView {
    if(!_settingView) {
        _settingView = [[WKSettingView alloc] init];
        __weak typeof(self) weakSelf = self;
        _settingView.onChannelSelct = ^(WKChannel * _Nonnull channel) {
            [weakSelf reloadChannelMessage:channel];
            [weakSelf.toBtn setTitle:channel.channelId forState:UIControlStateNormal];
            [weakSelf.settingView hide];
        };
    }
    return _settingView;
}

-(void) reloadChannelMessage:(WKChannel*)channel {
    self.toChannel = channel;
    self.tableView.channel = self.toChannel;
    self.settingView.defaultChannel = channel;
    [self.tableView reload];
    
    if(channel.channelType == WK_GROUP) {
        [self addSubscriber:WKSDK.shared.options.connectInfo.uid];
    }
    
}

-(void) addSubscriber:(NSString*)uid {
    [WKAPIClient.shared POST:@"/channel/subscriber_add" parameters:@{
        @"channel_id":self.toChannel.channelId,
        @"channel_type":@(self.toChannel.channelType),
        @"subscribers":@[uid]
    } complete:^(id  _Nonnull respose, NSError * _Nonnull error) {
        
    }];
}

-(void) removeSubscriber:(NSString*)uid {
    [WKAPIClient.shared POST:@"/channel/subscriber_remove" parameters:@{
        @"channel_id":self.toChannel.channelId,
        @"channel_type":@(self.toChannel.channelType),
        @"subscribers":@[uid]
    } complete:^(id  _Nonnull respose, NSError * _Nonnull error) {
        
    }];
}

// 键盘显示
- (void)keyboardWillShow:(NSNotification *)notification{
    [self handleKeyboardNotification:notification show:YES];
}

// 键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification{
    [self handleKeyboardNotification:notification show:NO];
}

- (void)handleKeyboardNotification:(NSNotification *)notification show:(BOOL)show{
    
    if(self.settingView.isShow) {
        return;
    }
    
    CGRect keyboardBeginFrame = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardBeginFrameInView = [self.view convertRect:keyboardBeginFrame fromView:nil];
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndFrameInView = [self.view convertRect:keyboardEndFrame fromView:nil];
    CGRect keyboardEndFrameIntersectingView = CGRectIntersection(self.view.bounds, keyboardEndFrameInView);
    
    CGFloat keyboardHeight = CGRectGetHeight(keyboardEndFrameIntersectingView);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGFloat safeBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
    if(keyboardHeight>0) {
        safeBottom = 0.0f;
    }
    self.inputView.frame = CGRectMake(0.0f, self.view.frame.size.height - keyboardHeight - self.inputView.frame.size.height - safeBottom, self.inputView.frame.size.width, self.inputView.frame.size.height);
    CGRect tableFrame = self.tableView.frame;
    self.tableView.frame = CGRectMake(tableFrame.origin.x, tableFrame.origin.y, tableFrame.size.width, self.inputView.frame.origin.y);
    
    [UIView commitAnimations];
}

- (void)dealloc {
    [WKSDK.shared.chatManager removeDelegate:self];
    [self disconnect];
    
    NSLog(@"WKViewController dealloc...");
}

- (UITextField *)inputFd {
    if(!_inputFd) {
        CGFloat height = 50.0f;
        _inputFd = [[UITextField alloc] initWithFrame:CGRectMake(5.0f,5.0f, self.view.frame.size.width - 5.0f*2, height)];
        _inputFd.placeholder = @"请输入消息";
        _inputFd.returnKeyType = UIReturnKeySend;
        _inputFd.delegate = self;
    }
    return _inputFd;
}

-(UIView*) inputView {
    if(!_inputView) {
        CGFloat safeBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        CGFloat height = self.inputFd.frame.size.height + 5.0f*2;
        _inputView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - height - safeBottom, self.view.frame.size.width, height)];
        [_inputView addSubview:self.inputFd];
        _inputView.backgroundColor = [UIColor whiteColor];
    }
    return _inputView;
}

- (WKMessageTableView *)tableView {
    if(!_tableView) {
        CGRect viewFrame = self.view.frame;
        _tableView = [[WKMessageTableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewFrame.size.width, self.inputView.frame.origin.y)];
//        _tableView.backgroundColor = [UIColor redColor];
    }
    return _tableView;
}

- (UIButton *)toBtn {
    if(!_toBtn) {
        _toBtn = [[UIButton alloc] init];
        [_toBtn setTitle:@"与谁会话?" forState:UIControlStateNormal];
        [_toBtn setTitleColor:[UIColor colorWithRed:228.0f/255.0f green:99.0f/255.0f blue:66.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_toBtn sizeToFit];
        [_toBtn addTarget:self action:@selector(settingPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toBtn;
}

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"send---->");
    if(!self.toChannel) {
        [self showSetting];
        return YES;
    }
    NSString *msg = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([msg isEqualToString:@""]) {
        return YES;
    }
    WKTextContent *content = [[WKTextContent alloc] initWithContent:msg];
    WKMessage *message = [WKSDK.shared.chatManager sendMessage:content channel:self.toChannel];
    [self.tableView sendMessageUI:message];
    
    
    textField.text = @"";
    
    return YES;
}
@end
