//
//  WKChatBackupVM.m
//  WuKongBase
//
//  Created by tt on 2023/2/3.
//

#import "WKChatBackupVM.h"
#import "WKDeleteAccountNoticeCell.h"

@implementation WKChatBackupVM

- (NSArray<NSDictionary *> *)tableSectionMaps {
    
    
    return @[
        @{
            @"height":@(20.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(1),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"为了迁移您的本地聊天记录，需要把您的聊天记录上传到服务器以支持新设备下载；"),
                },
            ],
        },
        @{
            @"height":@(5.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(2),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"聊天记录会以不记名加密的方式存储在服务器；"),
                },
            ],
        },
        @{
            @"height":@(5.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(3),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"为了防止信息泄露，服务器将会于每天的00:00删除当天所有用户上传的聊天记录；"),
                },
            ],
        },
        @{
            @"height":@(5.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(4),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"每点击一次备份，将会覆盖前一次备份的聊天记录，请谨慎操作；"),
                },
            ],
        },
        @{
            @"height":@(5.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(5),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"建议用户确认聊天记录迁移完毕后再删除原设备上的聊天记录；"),
                },
            ],
        },
        @{
            @"height":@(5.0f),
            @"items": @[
                @{
                    @"class":WKDeleteAccountNoticeCellModel.class,
                    @"num":@(6),
                    @"style":@(WKDeleteAccountNoticeNumStyleNum),
                    @"value": LLang(@"由此功能造成任何的不良后果由用户自行承担；"),
                },
            ],
        },
    ];
}


-(AnyPromise*) bakcupMessages {
    
    
   NSArray<WKMessage*> *messages = [WKMessageDB.shared getMessages:0 limit:100000];
    
    if(messages.count>0) {
        NSMutableArray *messageDicts = [NSMutableArray array];
        for (WKMessage *message in messages) {
            [messageDicts addObject:@{
                @"channel_id": message.channel.channelId,
                @"channel_type": @(message.channel.channelType),
                @"message_id": @(message.messageId),
                @"message_seq": @(message.messageSeq),
                @"client_msg_no": message.clientMsgNo?:@"",
                @"from_uid": message.fromUid?:@"",
                @"payload":  [[NSString alloc] initWithData:message.contentData  encoding:NSUTF8StringEncoding],
                @"timestamp":@(message.timestamp),
            }];
        }
        NSString *messageJons = [WKJsonUtil toJson:messageDicts];
        
        return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolver) {
            [WKAPIClient.sharedClient fileUpload:@"message/backup" data:[messageJons dataUsingEncoding:NSUTF8StringEncoding] progress:^(NSProgress * _Nonnull progress) {
                
            } completeCallback:^(id  _Nullable resposeObject, NSError * _Nullable error) {
                if(error) {
                    resolver(error);
                    return;
                }
                resolver(resposeObject);
            }];
        }];
    }
    
    return [AnyPromise promiseWithValue:nil];
}

@end
