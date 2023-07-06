//
//  WKUserInfoVM.m
//  WuKongBase
//
//  Created by tt on 2020/6/19.
//

#import "WKUserInfoVM.h"
#import "WKLabelItemCell.h"
#import "WKTableSectionUtil.h"
#import "WKMultiLabelItemCell.h"
#import "WKForbiddenSpeakTimeSelectVC.h"
#import "WKCountdownFormItemCell.h"
@interface WKUserInfoVM ()<WKChannelManagerDelegate>

@property(nonatomic,strong) channelInfoCompletion completion;


@property(nonatomic,strong) NSMutableDictionary *contextDict;

@property(nonatomic,copy) NSString *introEndpointID;

@end

@implementation WKUserInfoVM

- (instancetype)init{
    self = [super init];
    if (self) {
        self.introEndpointID = @"user.info.intro";
        [[WKSDK shared].channelManager addDelegate:self];
        
        [self initItems];
        
    }
    return self;
}

-(void) initData {
    if(self.fromChannel) {
        self.memberOfMy = [[WKSDK shared].channelManager getMember:self.fromChannel uid:[WKApp shared].loginInfo.uid];
        self.memberOfUser = [[WKSDK shared].channelManager getMember:self.fromChannel uid:self.uid];
        self.fromChannelInfo = [[WKSDK shared].channelManager getChannelInfo:self.fromChannel];
        if(!self.fromChannelInfo) {
            [[WKSDK shared].channelManager fetchChannelInfo:self.fromChannel];
        }
        [self reloadData];
    }
}

- (void)dealloc{
     [[WKSDK shared].channelManager removeDelegate:self];
}

- (void)loadPersonChannelInfo:(NSString *)uid completion:(channelInfoCompletion)completion {
    self.completion = completion;
    self.uid = uid;
    WKChannel *channel = [[WKChannel alloc] initWith:uid channelType:WK_PERSON];
    WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:channel];
    
    if(channelInfo) {
        self.channelInfo = channelInfo;
        if(completion) {
             completion();
        }
    }
    // 远程提取频道信息
    [[WKSDK shared].channelManager fetchChannelInfo:channel completion:^(WKChannelInfo * channelInfo) {
        if(channelInfo) {
            [[WKSDK shared].channelManager addOrUpdateChannelInfo:channelInfo];
        }
    }];
}

-(AnyPromise*) applyFriend:(NSString*)uid remark:(NSString*)remark vercode:(NSString*)vercode{
    return [[WKAPIClient sharedClient] POST:@"friend/apply" parameters:@{@"to_uid":uid?:@"",@"to_name":self.channelInfo.name?:@"",@"remark":remark?:@"",@"vercode":vercode?:@""}];
}

-(AnyPromise*) updateRemark:(NSString*)remark {
    return [[WKAPIClient sharedClient] PUT:@"friend/remark" parameters:@{@"uid":self.channelInfo.channel.channelId?:@"",@"remark":remark?:@""}];
}

-(AnyPromise*) deleteFriend {
     return [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"friends/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}


-(AnyPromise*) addBlacklist {
    return [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}
-(AnyPromise*) deleteBlacklist {
    return [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"user/blacklist/%@",self.channelInfo.channel.channelId?:@""] parameters:nil];
}


-(void) initItems {
    __weak typeof(self) weakSelf = self;
    // 备注
    [[WKApp shared] setMethod:@"user.info.setRemark" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLangW(@"设置备注",weakSelf),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMUpdateRemark:)]) {
                                [weakSelf.delegate userInfoVMUpdateRemark:weakSelf];
                            }
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:4000];
    
    // 邀请信息
    [[WKApp shared] setMethod:@"user.info.inviteInfo" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        WKChannelMember *memberOfUser = param[@"memberOfUser"];
        if(!memberOfUser) {
            return nil;
        }
        if(!memberOfUser.extra[@"invite_uid"] || [memberOfUser.extra[@"invite_uid"] isEqualToString:@""]) {
            return nil;
        }
        NSString *createdAt = memberOfUser.createdAt;
        if(createdAt.length>10) {
            createdAt = [createdAt substringToIndex:10];
        }
        WKChannelMember *memberOfInvite = [[WKSDK shared].channelManager getMember:weakSelf.fromChannel uid:memberOfUser.extra[@"invite_uid"]];
        if(!memberOfInvite) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLangW(@"进群方式",weakSelf),
                        @"valueFont": [[WKApp shared].config appFontOfSize:12.0f],
                        @"value": [NSString stringWithFormat:@"%@ %@邀请入群",createdAt,memberOfInvite.displayName],
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:3999];
    
    // 个人禁言
    [[WKApp shared] setMethod:@"user.info.forbidden" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        WKChannelInfo *channelInfo = param[@"channel_info"];
        if(!channelInfo) {
            return nil;
        }
        if(!weakSelf.fromChannel || weakSelf.fromChannel.channelType == WK_PERSON) {
            return nil;
        }
        WKChannelMember *memberOfUser = weakSelf.memberOfUser;
        if(!memberOfUser) {
            return nil;
        }
        WKChannelMember *memberOfMy = weakSelf.memberOfMy;
        if(!memberOfMy) {
            return nil;
        }
        if(memberOfMy.role != WKMemberRoleManager && memberOfMy.role != WKMemberRoleCreator) {
            return nil;
        }
        NSInteger forbiddenExpirTime = 0; // 禁言失效时间
        if(memberOfUser.extra[@"forbidden_expir_time"]) {
            forbiddenExpirTime = [memberOfUser.extra[@"forbidden_expir_time"] integerValue];
        }
        
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKCountdownFormItemModel.class,
                        @"label":LLangW(@"群内禁言", weakSelf),
                        @"value": forbiddenExpirTime>0?LLang(@"禁言中"):@"",
                        @"second":@(forbiddenExpirTime),
                        @"onClick":^{
                            
                            WKChannelMember *member = [[WKSDK shared].channelManager getMember:weakSelf.fromChannel uid:uid];
                            if(member && member.extra[@"forbidden_expir_time"] && [member.extra[@"forbidden_expir_time"] intValue]>0) {
                                WKActionSheetView2 *sheet = [WKActionSheetView2 initWithTip:nil];
                                [sheet addItem:[WKActionSheetButtonItem2 initWithTitle:LLangW(@"解除禁言", weakSelf) onClick:^{
                                    UIView *topView = [WKNavigationManager shared].topViewController.view;
                                    [topView showHUD];
                                    [[WKAPIClient sharedClient] POST:[NSString stringWithFormat:@"groups/%@/forbidden_with_member",weakSelf.fromChannel.channelId] parameters:@{
                                        @"member_uid":uid,
                                        @"action":@(0)
                                    }].then(^{
                                        [topView hideHud];
                                        [[WKNavigationManager shared] popViewControllerAnimated:YES];
                                    }).catch(^(NSError *error){
                                        [topView hideHud];
                                        [topView showHUDWithHide:error.domain];
                                    });
                                }]];
                                [sheet show];
                                return;
                            }
                            
                            WKForbiddenSpeakTimeSelectVC *vc = [WKForbiddenSpeakTimeSelectVC new];
                            vc.channel = weakSelf.fromChannel;
                            vc.uid = uid;
                            [[WKNavigationManager shared] pushViewController:vc animated:YES];
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:3990];
    
    // 解除好友关系
    [[WKApp shared] setMethod:@"user.info.freeFriend" handler:^id _Nullable(id  _Nonnull param) {
        WKChannelInfo *channelInfo = param[@"channel_info"];
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLangW(@"解除好友关系",weakSelf),
                        @"hidden": channelInfo.follow == WKChannelInfoFollowFriend?@(false):@(true),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMFreeFriend:)]) {
                                [weakSelf.delegate userInfoVMFreeFriend:weakSelf];
                            }
                        }
                    },
            ]
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:3000];
    
    // 添加黑名单
    [[WKApp shared] setMethod:@"user.info.addBlack" handler:^id _Nullable(id  _Nonnull param) {
        WKChannelInfo *channelInfo = param[@"channel_info"];
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":channelInfo && channelInfo.status == WKChannelStatusBlacklist?LLangW(@"拉出黑名单", weakSelf):LLangW(@"拉入黑名单", weakSelf),
                        @"onClick":^{
                            if(self.channelInfo.status == WKChannelStatusBlacklist) {
                                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMRemoveBlacklist:)]) {
                                    [weakSelf.delegate userInfoVMRemoveBlacklist:weakSelf];
                                }
                            }else {
                                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMAddBlacklist:)]) {
                                    [weakSelf.delegate userInfoVMAddBlacklist:weakSelf];
                                }
                            }
                            
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:2000];
    
    // 投诉
    [[WKApp shared] setMethod:@"user.info.report" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        return  @{
            @"height":@(0.0f),
            @"items":@[
                    @{
                        @"class":WKLabelItemModel.class,
                        @"label":LLangW(@"投诉", weakSelf),
                        @"onClick":^{
                            if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(userInfoVMReport:)]) {
                                [weakSelf.delegate userInfoVMReport:weakSelf];
                            }
                        }
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:1000];
    
    // 来源
    [[WKApp shared] setMethod:@"user.info.source" handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        if([uid isEqualToString:[WKApp shared].loginInfo.uid]) {
            return nil;
        }
        WKChannelInfo *channelInfo = param[@"channel_info"];
        if(!channelInfo || (!channelInfo.extra[@"source_desc"] || [channelInfo.extra[@"source_desc"] isEqualToString:@""])) {
            return  nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKMultiLabelItemModel.class,
                        @"mode": @(WKMultiLabelItemModeLeftRight),
                        @"label":LLang(@"来源"),
                        @"value":channelInfo.extra[@"source_desc"]?:@"",
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:900];
    
    
    // 功能介绍
    [[WKApp shared] setMethod:self.introEndpointID handler:^id _Nullable(id  _Nonnull param) {
        NSString *uid = param[@"uid"];
        
        NSString *intro;
        if([uid isEqualToString:WKApp.shared.config.fileHelperUID]) {
            intro = LLang(@"登录网页版本，向我发送消息，可以在手机与电脑间传输文字、图片、音频、视频等文件");
        }
        if([uid isEqualToString:WKApp.shared.config.systemUID]) {
            intro = [NSString stringWithFormat:@"%@官方用来发送一些通知的账号",WKApp.shared.config.appName];
        }
        if(!intro) {
            return nil;
        }
        return  @{
            @"height":@(10.0f),
            @"items":@[
                    @{
                        @"class":WKMultiLabelItemModel.class,
                        @"mode": @(WKMultiLabelItemModeLeftRight),
                        @"label":LLang(@"功能介绍"),
                        @"value":intro,
                    },
            ],
        };
    } category:WKPOINT_CATEGORY_USER_INFO_ITEM sort:900];
}


- (NSArray<NSDictionary *> *)tableSectionMaps {
    if(!self.channelInfo) {
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionaryWithDictionary:@{@"uid":self.uid?:@"",@"channel_info":self.channelInfo,@"reload":^{
        [weakSelf reloadData];
    },@"context":self.contextDict}];
    if(self.memberOfUser) {
        paramDict[@"memberOfUser"] = self.memberOfUser;
    }
    
    NSMutableArray<NSDictionary*> *items = [NSMutableArray array];
    
    NSArray<WKEndpoint*> *endpoints =  [WKApp.shared getEndpointsWithCategory:WKPOINT_CATEGORY_USER_INFO_ITEM];
    if(endpoints && endpoints.count>0) {
        for (WKEndpoint *endpoint in endpoints) {
            if([self isSystemAccount:self.uid] && ![endpoint.sid isEqualToString:self.introEndpointID]) {
                continue;
            }
            id result = endpoint.handler(paramDict);
            if(result) {
                [items addObject:result];
            }
        }
    }
    return items;
}

-(BOOL) isSystemAccount:(NSString*)uid {
    return [WKApp.shared isSystemAccount:uid];
}

- (NSMutableDictionary *)contextDict {
    if(!_contextDict) {
        _contextDict = [NSMutableDictionary dictionary];
    }
    return _contextDict;
}

- (BOOL)isBlacklist {
    return  self.channelInfo && self.channelInfo.status == WKChannelStatusBlacklist;
}

#pragma mark - 事件
// 频道数据更新
-(void) channelInfoUpdate:(WKChannelInfo*)channelInfo {
    if(channelInfo.channel.channelType == WK_PERSON && [channelInfo.channel.channelId isEqualToString:self.uid] ) {
        self.channelInfo = channelInfo;
        if(self.completion) {
            self.completion();
        }
    }
}

@end
