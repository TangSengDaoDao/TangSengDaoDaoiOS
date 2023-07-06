//
//  WKDeleteAccountVM.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKDeleteAccountVM.h"
#import "WKDeleteAccountTitleCell.h"
#import "WKDeleteAccountTipCell.h"
#import "WKDeleteAccountNoticeCell.h"
@interface WKDeleteAccountVM ()

@end

@implementation WKDeleteAccountVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
   NSDictionary *loginExtra = WKApp.shared.loginInfo.extra;
    NSString *phone = loginExtra[@"phone"]?:@"";
    if(phone && phone.length>7) {
        phone = [NSString stringWithFormat:@"%@****%@",[phone substringToIndex:3],[phone substringWithRange:NSMakeRange(phone.length - 4, 4)]];
    }
    return @[
        @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountTitleCellModel.class,
                        @"title":LLang(@"注销账号："),
                        @"value":phone,
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountTipCellModel.class,
                        @"tip":[NSString stringWithFormat:LLang(@"账号注销是不可恢复的操作，请您仔细考虑，谨慎操作，操作前务必审慎阅读，充分理解以下内容。如您有任何疑问、意见和建议，可联系客服咨询，%@客服将给予您必要的协助。"),WKApp.shared.config.appName],
                    },
            ],
        },
        @{
            @"height":@(20.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountTitleCellModel.class,
                        @"title":LLang(@"注销须知："),
                        @"fontSize":@(16.0f),
                    },
            ],
        },
        @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(1),
                        @"value": LLang(@"账号处于安全状态：\r您的账号未被他人盗取，账号不存在被封禁等风险。"),
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(2),
                        @"value": LLang(@"全部财产均已结清：\n账号内不存在已充值的相关财产。"),
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(3),
                        @"value": LLang(@"绑定目前可用的安全手机：\n用于确认当前账号的身份归属情况。"),
                    },
            ],
        },
        @{
            @"height":@(20.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountTitleCellModel.class,
                        @"title":LLang(@"特别说明："),
                        @"fontSize":@(16.0f),
                    },
            ],
        },
        @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(1),
                        @"style":@(WKDeleteAccountNoticeNumStyleNum),
                        @"value": [NSString stringWithFormat:LLang(@"账号注销申请时即放弃该账号在%@聊天软件所有涉及相关数据，包括但不限于该账号的资产，权益，记录等一切内容，将视为你自愿放弃。"),WKApp.shared.config.appName],
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(2),
                        @"style":@(WKDeleteAccountNoticeNumStyleNum),
                        @"value": LLang(@"账号成功注销后，你将无法登录"),
                    },
            ],
        },
        @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKDeleteAccountNoticeCellModel.class,
                        @"num":@(3),
                        @"style":@(WKDeleteAccountNoticeNumStyleNum),
                        @"value":LLang(@"已成功注销的账号无法进行找回。"),
                    },
            ],
        }
    ];
}

@end
