//
//  WKSecuritySettingVM.m
//  WuKongBase
//
//  Created by tt on 2020/6/21.
//

#import "WKSecuritySettingVM.h"
#import "WKBlacklistVC.h"
#import "WKDeviceManagerVC.h"
#import "WKResetLoginPasswordVC.h"
#import "WKConversationPasswordVC.h"
#import "WKScreenPasswordSetVC.h"
#import "WKScreenPasswordVC.h"
#import "WKScreenPasswordSettingVC.h"
#import "WKMySettingManager.h"
#import "WKDeleteAccountVC.h"
@implementation WKSecuritySettingVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    BOOL searchByPhone = [WKMySettingManager shared].searchByPhone; // 是否通过手机号搜索
    BOOL searchByShort = [WKMySettingManager shared].searchByShort; // 是否通过编号搜索
    __weak typeof(self) weakSelf = self;
//    NSNumber *lockAfterMinute =  [WKApp shared].loginInfo.extra[@"lock_after_minute"]?:@(0);
    NSString *lockScreenPwd = [WKApp shared].loginInfo.extra[@"lock_screen_pwd"];
    BOOL lockScreenOn = false;
    if(lockScreenPwd && ![lockScreenPwd isEqualToString:@""]) {
        lockScreenOn = true;
    }
    
    BOOL showUpdatePwd = false;
    NSString *phone = [WKApp shared].loginInfo.extra[@"phone"];
    if(phone && ![phone isEqualToString:@""]) {
        showUpdatePwd = true;
    }
    
    return @[
        @{
            @"height":@(15.0f),
            @"title": LLang(@"可以通过以下方式搜索好友"),
            @"remark": LLang(@"关闭后，其他用户将不能通过上述信息搜索好友"),
            @"items":@[
                    @{
                        @"class":WKSwitchItemModel.class,
                        @"label":LLang(@"允许手机号搜索"),
                        @"on":@(searchByPhone),
                        @"hidden":@(WKApp.shared.remoteConfig.phoneSearchOff),
                        @"onSwitch":^(BOOL on){
                            [weakSelf searchByPhone:on];
                        }
                    },
                    @{
                        @"class":WKSwitchItemModel.class,
                        @"label":[NSString stringWithFormat:LLang(@"允许%@号搜索"),[WKApp shared].config.appName],
                        @"on":@(searchByShort),
                        @"onSwitch":^(BOOL on){
                            [weakSelf searchByShort:on];
                        }
                    },
            ],
        },
        @{
            @"height":@(15.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"登录密码"),
                        @"hidden": @(!showUpdatePwd),
                        @"onClick":^{
                            [[WKNavigationManager shared] pushViewController:[WKResetLoginPasswordVC new] animated:YES];
                        }
                    },
            ],
        },
        @{
            @"height":@(0.01f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"聊天密码"),
                        @"onClick":^{
                            WKConversationPasswordVC *vc = [WKConversationPasswordVC new];
                            [[WKNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        },
        @{
            @"height":@(15.0f),
            @"title":LLang(@"屏幕保护"),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"锁屏密码"),
                        @"value": lockScreenOn?LLang(@"已开启"):LLang(@"已关闭"),
                        @"onClick":^{
                            if(lockScreenOn) {
                                WKScreenPasswordVC *vc = [WKScreenPasswordVC new];
                                vc.allowBack = true;
                                vc.onFinished = ^(NSString * _Nonnull pwd) {
                                    WKScreenPasswordSettingVC *settingVC = [WKScreenPasswordSettingVC new];
                                    [[WKNavigationManager shared] replacePushViewController:settingVC animated:YES];
                                };
                                [[WKNavigationManager shared] pushViewController:vc animated:YES];
                            }else{
                                WKScreenPasswordSetVC *vc = [WKScreenPasswordSetVC new];
                                [[WKNavigationManager shared] pushViewController:vc animated:YES];
                            }
                           
                        }
                    },
                    @{
                        @"class":WKSwitchItemModel.class,
                        @"label":LLang(@"断网屏保"),
                        @"on":@([WKMySettingManager shared].offlineProtection),
                        @"onSwitch":^(BOOL on){
                            [[WKMySettingManager shared] offlineProtection:on];
                        }
                    },
//                    @{
//                        @"class":WKLabelItemModel.class,
//                        @"label":LLang(@"屏保锁定开启间隔"),
//                        @"value": LLang(@"立即"),
//                        @"onClick":^{
//
//                        }
//                    },
                    
            ],
        },
        @{
            @"height":@(15.0f),
            @"remark":LLang(@"查看并管理设备，开启登录保护，保障账号安全。"),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"登录设备管理"),
                        @"value": [self deviceLockOn]?LLang(@"已开启"):LLang(@"已关闭"),
                        @"onClick":^{
                            WKDeviceManagerVC *vc = [WKDeviceManagerVC new];
                            [[WKNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        },
        @{
            @"height":@(15.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"黑名单"),
                        @"onClick":^{
                            [[WKNavigationManager shared] pushViewController:[WKBlacklistVC new] animated:YES];
                        }
                    },
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLang(@"注销账号"),
                        @"onClick":^{
                            WKDeleteAccountVC *vc = [[WKDeleteAccountVC alloc] init];
                            [[WKNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        }
    ];
}

// 设备锁是否开启
-(BOOL) deviceLockOn {
    NSDictionary *settingDict = [WKApp shared].loginInfo.extra[@"setting"];
    if(settingDict && settingDict[@"device_lock"]) {
        return [settingDict[@"device_lock"] boolValue];
    }
    return false;
}

- (AnyPromise *)searchByPhone:(BOOL)on {
    return [[WKMySettingManager shared] searchByPhone:on];
}

- (AnyPromise *)searchByShort:(BOOL)on {
    return [[WKMySettingManager shared] searchByShort:on];
}
@end
