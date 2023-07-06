//
//  WKDeviceManagerVC.m
//  WuKongBase
//
//  Created by tt on 2020/10/22.
//

#import "WKDeviceManagerVC.h"

@interface WKDeviceManagerVC ()<WKDeviceManagerVMDelegate>

@end

@implementation WKDeviceManagerVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKDeviceManagerVM new];
        self.viewModel.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"登录设备管理");
}

#pragma mark - WKDeviceManagerVMDelegate

- (void)deviceManagerVMDeviceClick:(WKDeviceManagerVM *)vm device:(WKDeviceModel*)device{
    WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:[NSString stringWithFormat:LLang(@"最后登录时间: %@"),device.lastLogin]];
    __weak typeof(self) weakSelf = self;
    
    [sheet addItem:[WKActionSheetButtonItem2 initWithAlertTitle:LLang(@"删除设备") onClick:^{
        [self.view showHUD];
        [weakSelf.viewModel deleteDevice:device.deviceID].then(^{
            [weakSelf.view hideHud];
            if(device.selfB) { // 如果删除的是本机则需要退出登录
                [[WKApp shared] logout];
                return;
            }
            [weakSelf reloadRemoteData];
        }).catch(^(NSError *error){
            [weakSelf.view switchHUDError:error.domain];
        });
    }]];
    [sheet show];
}


@end
