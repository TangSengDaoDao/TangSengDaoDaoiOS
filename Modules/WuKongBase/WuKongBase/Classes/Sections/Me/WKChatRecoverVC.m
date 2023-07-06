//
//  WKChatRecoverVC.m
//  WuKongBase
//
//  Created by tt on 2023/2/3.
//

#import "WKChatRecoverVC.h"

@interface WKChatRecoverVC ()

@property(nonatomic,strong) UIButton *okBtn;

@end

@implementation WKChatRecoverVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKChatRecoverVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"聊天记录恢复");
    
    self.view.backgroundColor = WKApp.shared.config.cellBackgroundColor;
    
    [self.view addSubview:self.okBtn];
}


- (UIButton *)okBtn {
    if(!_okBtn) {
        CGFloat height = 44.0f;
        CGFloat safeBottom = UIApplication.sharedApplication.keyWindow.safeAreaInsets.bottom;
        _okBtn = [[UIButton alloc] initWithFrame:CGRectMake(20.0f,self.view.lim_height - height - safeBottom, self.view.lim_width - 40.0f, height)];
        _okBtn.backgroundColor = WKApp.shared.config.themeColor;
        _okBtn.layer.masksToBounds = YES;
        _okBtn.layer.cornerRadius = _okBtn.lim_height/2.0f;
        [_okBtn setTitle:LLang(@"确认") forState:UIControlStateNormal];
        
        [_okBtn addTarget:self action:@selector(okPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

-(void) okPressed {
    __weak typeof(self) weakSelf = self;
    [self.view showHUD:LLang(@"恢复中...")];
    [self.viewModel recoverMessages].then(^{
        [weakSelf.view switchHUDSuccess:LLang(@"恢复成功！")];
    }).catch(^(NSError *err){
        NSLog(@"恢复失败！->%@",err);
        [weakSelf.view switchHUDError:LLang(@"恢复失败！")];
    });
}


@end
