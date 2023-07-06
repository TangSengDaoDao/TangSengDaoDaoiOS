//
//  WKGlobalSearchVM.m
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//

#import "WKGlobalSearchVM.h"
#import "WKTableSectionUtil.h"
#import "WKLabelItemCell.h"
#import "WKSearchHeaderCell.h"
#import "WKSearchContactsCell.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "WKAvatarUtil.h"
#import "WKSearchMessageCell.h"
#import "WKSearchMoreCell.h"
#import "WKChannelMessageSearchResultVC.h"
#import "WKGlobalSearchResultController.h"
#import "WKConversationVC.h"
#define WKSearchMaxCount 4

@implementation WKGlobalSearchVM

- (void)search:(NSString *)text callback:(void (^)(NSArray<WKFormSection *> * _Nonnull))callback {
    if(!text || [text isEqualToString:@""]) {
        callback(@[]);
        return;
    }
    NSMutableArray *items = [NSMutableArray array];
    NSDictionary *result;
    switch (self.searchType) {
        case WKHistoryMessageSearchTypeContacts: {
            // 搜索联系人
            result = [self searchContacts:text];
            if(result) {
                [items addObject:result];
            }
        }
        break;
        case WKHistoryMessageSearchTypeConversation: {
            // 搜索群聊
            result  = [self searchGroup:text preHasData:result&&result.count>0];
            if(result) {
                [items addObject:result];
            }
        }
        break;
        case WKHistoryMessageSearchTypeMessages: {
            // 搜索消息
            result = [self searchMessage:text preHasData:result&&result.count>0];
            if(result) {
                [items addObject:result];
            }
        }
        break;
            
        default:
            break;
    }
    if(self.searchType == WKHistoryMessageSearchTypeAll) {
        // 搜索联系人
        result = [self searchContacts:text];
        if(result) {
            [items addObject:result];
        }
        // 搜索群聊
        result  = [self searchGroup:text preHasData:result&&result.count>0];
        if(result) {
            [items addObject:result];
        }
        // 搜索消息
        result = [self searchMessage:text preHasData:result&&result.count>0];
        if(result) {
            [items addObject:result];
        }
    }
    callback([WKTableSectionUtil toSections:items]);
}

// 搜索联系人
-(NSDictionary*) searchContacts:(NSString*)keyword {
    NSMutableArray *items = [NSMutableArray array];
    [items addObject: @{
               @"class":WKSearchHeaderModel.class,
               @"title":LLang(@"联系人"),
               @"showBottomLine":@(NO),
                        
    }];
    NSInteger limit = self.searchType == WKHistoryMessageSearchTypeAll? WKSearchMaxCount:1000;
   NSArray *channelInfoArray = [[WKChannelInfoDB shared] queryChannelInfoWithFriend:keyword limit:limit];
    if(!channelInfoArray || channelInfoArray.count<=0) {
        return nil;
    }
    for (NSInteger i=0; i<channelInfoArray.count; i++) {
        WKChannelInfo *channelInfo = channelInfoArray[i];
        [items addObject:@{
                  @"class":WKSearchContactsModel.class,
                  @"name":channelInfo.displayName,
                  @"avatar":[WKAvatarUtil getFullAvatarWIthPath:channelInfo.logo],
                  @"keyword": keyword,
                  @"showBottomLine":@(NO),
                  @"showTopLine":@(NO),
                  @"onClick":^{
                    [[WKApp shared] invoke:WKPOINT_USER_INFO param:@{@"uid":channelInfo.channel.channelId}];
                  }
               }];
    }
    if(channelInfoArray.count>=limit) {
           [items addObject:@{
              @"class":WKSearchMoreModel.class,
              @"placeholder":LLang(@"更多联系人"),
              @"showBottomLine":@(NO),
              @"showTopLine":@(NO),
              @"bottomLeftSpace":@(0.0f),
              @"onClick":^{
                   WKGlobalSearchResultController *vc = [WKGlobalSearchResultController new];
                   vc.searchType = WKHistoryMessageSearchTypeContacts;
                    vc.keyword = keyword;
                   [[WKNavigationManager shared] pushViewController:vc animated:YES];
           }
           }];
    }
    return @{
        @"height":@(0.01),
         @"items":items,
    };
}

// 搜索群聊  preHasData:上个section是否有数据
-(NSDictionary*) searchGroup:(NSString*)keyword preHasData:(BOOL)hasData {
    
     NSMutableArray *items = [NSMutableArray array];
       [items addObject: @{
                  @"class":WKSearchHeaderModel.class,
                  @"title":LLang(@"群聊"),
                  @"showBottomLine":@(NO),
                           
       }];
    NSInteger limit = self.searchType == WKHistoryMessageSearchTypeAll? WKSearchMaxCount:1000;
    NSArray *channelInfoArray = [[WKChannelInfoDB shared] searchChannelInfoWithKeyword:keyword channelType:WK_GROUP limit:limit];
        if(!channelInfoArray || channelInfoArray.count<=0) {
            return nil;
        }
        for (NSInteger i=0; i<channelInfoArray.count; i++) {
             WKChannelInfoSearchResult *searchResult = channelInfoArray[i];
            [items addObject:@{
               @"class":WKSearchContactsModel.class,
               @"name":searchResult.channelInfo.displayName,
               @"contain": searchResult.containMemberName?:@"",
               @"avatar":[WKAvatarUtil getFullAvatarWIthPath:searchResult.channelInfo.logo],
               @"keyword": keyword,
               @"showBottomLine":@(NO),
               @"showTopLine":@(NO),
               @"onClick":^{
                [[WKApp shared] pushConversation:searchResult.channelInfo.channel];
            }
            }];
        }
    if(channelInfoArray.count>=limit) {
        [items addObject:@{
           @"class":WKSearchMoreModel.class,
           @"placeholder":LLang(@"更多群聊"),
           @"showBottomLine":@(NO),
           @"showTopLine":@(NO),
           @"bottomLeftSpace":@(0.0f),
           @"onClick":^{
            WKGlobalSearchResultController *vc = [WKGlobalSearchResultController new];
            vc.searchType = WKHistoryMessageSearchTypeConversation;
            vc.keyword = keyword;
            [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }
        }];
    }
       return @{
           @"height":hasData?WKSectionHeight:@(0.01f),
            @"items":items,
       };
}


// 搜索消息
-(NSDictionary*) searchMessage:(NSString*)keyword preHasData:(BOOL)hasData {
    
    NSMutableArray *items = [NSMutableArray array];
     [items addObject: @{
                @"class":WKSearchHeaderModel.class,
                @"title":LLang(@"聊天记录"),
                @"showBottomLine":@(NO),
                         
     }];
    NSInteger limit = self.searchType == WKHistoryMessageSearchTypeAll? WKSearchMaxCount:1000;
    NSArray<WKChannelMessageSearchResult*> *results = [[WKChannelInfoDB shared] searchChannelMessageWithKeyword:keyword limit:limit];
    if(!results || results.count<=0) {
        return nil;
    }
    for (NSInteger i=0; i<results.count; i++) {
        WKChannelMessageSearchResult *searchResult = results[i];
       WKChannelInfo *channelInfo = [[WKSDK shared].channelManager getChannelInfo:searchResult.channel];
        NSString *name = @"";
        NSString *logo = @"";
        NSString *content = @"";
        if(channelInfo) {
            name = channelInfo.displayName;
            logo = [WKAvatarUtil getFullAvatarWIthPath:channelInfo.logo];
        }else {
            [[WKSDK shared].channelManager fetchChannelInfo:searchResult.channel];
        }
        if(searchResult.messageCount == 1) {
            content = searchResult.searchableWord;
        }
        [items addObject:@{
           @"class":WKSearchMessageModel.class,
           @"name":name,
           @"avatar":logo,
           @"keyword": keyword?:@"",
           @"content": content,
           @"messageCount": @(searchResult.messageCount),
           @"showBottomLine":@(NO),
           @"showTopLine":@(NO),
           @"bottomLeftSpace":i==results.count-1 && i<WKSearchMaxCount-1?@(0.0f):@(20.0f),
           @"onClick":^{
                if(searchResult.messageCount == 1) {
                    WKConversationVC *vc = [[WKConversationVC alloc] init];
                    vc.channel = searchResult.channel;
                    vc.locationAtOrderSeq = searchResult.orderSeq;
                    [[WKNavigationManager shared] pushViewController:vc animated:YES];
                }else {
                    WKChannelMessageSearchResultVC *vc = [WKChannelMessageSearchResultVC new];
                    vc.channel = searchResult.channel;
                    vc.keyword = keyword;
                    [[WKNavigationManager shared] pushViewController:vc animated:YES];
                }
            }
        }];
    }
    if(results.count>=limit) {
        [items addObject:@{
           @"class":WKSearchMoreModel.class,
           @"placeholder":LLang(@"更多聊天记录"),
           @"showBottomLine":@(NO),
           @"showTopLine":@(NO),
           @"bottomLeftSpace":@(0.0f),
           @"onClick":^{
                WKGlobalSearchResultController *vc = [WKGlobalSearchResultController new];
                vc.searchType = WKHistoryMessageSearchTypeMessages;
                vc.keyword = keyword;
                [[WKNavigationManager shared] pushViewController:vc animated:YES];
        }
        }];
    }
     return @{
          @"height":hasData?WKSectionHeight:@(0.01f),
          @"items":items,
     };
}
@end
