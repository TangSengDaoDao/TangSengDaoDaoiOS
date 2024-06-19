//
//  WKDatasource.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/24.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKDatasource.h"
#import "WKAPIClient.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
@implementation WKDatasource


+ (instancetype)shared {
    static WKDatasource *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WKDatasource alloc] init];
    });
    
    return _sharedClient;
}

- (void)setup {
 
    [WKSDK.shared.chatManager setSyncChannelMessageProvider:^(WKChannel * _Nonnull channel, uint32_t startMessageSeq, uint32_t endMessageSeq, NSInteger limit, WKPullMode pullMode, WKSyncChannelMessageCallback  _Nonnull callback) {
        [WKAPIClient.shared POST:@"/channel/messagesync" parameters:@{
            @"login_uid": WKSDK.shared.options.connectInfo.uid,
            @"channel_id": channel.channelId?:@"",
            @"channel_type":@(channel.channelType),
            @"start_message_seq": @(startMessageSeq),
            @"end_message_seq":@(endMessageSeq),
            @"limit":@(limit),
            @"pull_mode":@(pullMode),
        } complete:^(NSDictionary  *dict, NSError * _Nonnull error) {
            if(error) {
                callback(nil,error);
                return;
            }
            WKSyncChannelMessageModel *model = [WKSyncChannelMessageModel new];
            model.startMessageSeq = (uint32_t)[dict[@"start_message_seq"] unsignedLongLongValue];
            model.endMessageSeq = (uint32_t)[dict[@"end_message_seq"] unsignedLongLongValue];
            NSArray<NSDictionary*> *messageDicts = dict[@"messages"];
            if(messageDicts && messageDicts.count>0) {
                NSMutableArray *messages = [NSMutableArray array];
                for (NSDictionary *messageDict in messageDicts) {
                    [messages addObject:[self.class toMessage:messageDict]];
                }
                model.messages = messages;
            }
            callback(model,nil);
        }];
    }];
}


+(WKMessage*) toMessage:(NSDictionary*)messageDict {
    WKMessage *message = [[WKMessage alloc] init];
   NSDictionary *headerDict =  messageDict[@"header"];
    if(headerDict) {
        message.header.showUnread = headerDict[@"red_dot"]?[headerDict[@"red_dot"] integerValue]:0;
        message.header.noPersist = headerDict[@"no_persist"]?[headerDict[@"no_persist"] integerValue]:0;
    }
    
    if(messageDict[@"setting"]) {
        message.setting =   [WKSetting fromUint8:[messageDict[@"setting"] intValue]];
    }
    
    if(messageDict[@"message_id"] && [messageDict[@"message_id"]  isKindOfClass:[NSString class]]) {
        NSDecimalNumber* formatter = [[NSDecimalNumber alloc] initWithString:messageDict[@"message_id"] ];
        message.messageId = formatter.unsignedLongLongValue;
        
    }else{
        message.messageId = [messageDict[@"message_id"] unsignedLongLongValue];
    }
    if(messageDict[@"message_seq"]) {
        message.messageSeq = (uint32_t)[messageDict[@"message_seq"] unsignedLongValue];
    }
    message.clientMsgNo = messageDict[@"client_msg_no"]?:@"";
    
    message.timestamp =messageDict[@"timestamp"]?[messageDict[@"timestamp"] integerValue]:0;
    message.fromUid = messageDict[@"from_uid"]?:@"";
    message.toUid = messageDict[@"to_uid"]?:@"";
    NSNumber *voiceStatus = messageDict[@"voice_status"];
    if(voiceStatus) {
        message.voiceReaded = [voiceStatus boolValue];
    }
    NSInteger  channelType = messageDict[@"channel_type"]?[messageDict[@"channel_type"] integerValue]:0;
    NSString *channelID = messageDict[@"channel_id"]?:@"";
    message.channel = [[WKChannel alloc] initWith:channelID channelType:channelType];
    if([channelID isEqualToString:[WKSDK shared].options.connectInfo.uid]) {
        message.channel = [[WKChannel alloc] initWith:message.fromUid channelType:channelType];
    }
    message.status = WK_MESSAGE_SUCCESS;
    
    NSDictionary *messageExtraDict = messageDict[@"message_extra"];
    if(messageExtraDict) {
        WKMessageExtra *messageExtra =  [self toMessageExtra:messageExtraDict channel:message.channel];
        message.hasRemoteExtra = true;
        message.remoteExtra = messageExtra;
    }

    
    NSData *planPayloadData;
    BOOL signalFail = false;
    NSDictionary *payloadDict;
    
    if(!messageDict[@"payload"] ||  messageDict[@"payload"] == [NSNull null] ) {
        payloadDict = nil;
    }else {
        id payload = messageDict[@"payload"];
        if([payload isKindOfClass:[NSString class]]) {
            NSString *payloadStr = payload;
            NSData *payloadData = [[NSData alloc] initWithBase64EncodedString:payloadStr options:0];
            payloadDict = [self toDic: [[NSString alloc] initWithData:payloadData encoding:NSUTF8StringEncoding]];
        }else {
            payloadDict = payload;
        }
        if(payloadDict && [payloadDict isKindOfClass:[NSDictionary class]]) {
            planPayloadData = [NSJSONSerialization dataWithJSONObject:payloadDict options:kNilOptions error:nil];
        }
       
    }
    
    NSNumber *contentType;
    WKMessageContent *messageContent;
    messageContent = [self decodeMessageContent:payloadDict contentType:&contentType];
    message.contentData = planPayloadData;
    message.content = messageContent;
    message.contentType = contentType.integerValue;

    if(!message.fromUid || [message.fromUid isEqualToString:@""]) { // 如果协议层没有给fromUID 则如果content层有则填充上去
        message.fromUid = messageContent.senderUserInfo?messageContent.senderUserInfo.uid:@"";
    }
    message.isDeleted = messageDict[@"is_deleted"]?[messageDict[@"is_deleted"] integerValue]:0;
    
    if(!message.isDeleted && message.content.visibles && message.content.visibles.count>0) {
        message.isDeleted  =  ![message.content.visibles containsObject:[WKSDK shared].options.connectInfo.uid];
    }
    
    // 回应
    if(messageDict[@"reactions"]) {
        NSArray<NSDictionary*> *reactionDicts = messageDict[@"reactions"];
        if(reactionDicts.count>0) {
            NSMutableArray<WKReaction*> *reactions = [NSMutableArray array];
            for (NSDictionary *reactionDict in reactionDicts) {
                WKReaction *reactionM = [self toReaction:reactionDict];
                reactionM.messageId = message.messageId;
                reactionM.channel = message.channel;
                [reactions addObject:reactionM];
            }
            message.reactions = reactions;
        }
    }
    
    return message;
}


+ (WKMessageExtra*) toMessageExtra:(NSDictionary*)dataDict channel:(WKChannel*)channel{
    WKMessageExtra *messageExtra = [[WKMessageExtra alloc] init];
    messageExtra.messageID =  [dataDict[@"message_id"] unsignedLongLongValue];
    messageExtra.messageSeq =  (uint32_t)[dataDict[@"message_seq"] unsignedLongLongValue];
    messageExtra.channelID = channel.channelId;
    messageExtra.channelType = channel.channelType;
    if(dataDict[@"readed"]) {
        messageExtra.readed = [dataDict[@"readed"] boolValue];
    }
    if(dataDict[@"readed_at"] && [dataDict[@"readed_at"] intValue]>0) {
        messageExtra.readedAt = [NSDate dateWithTimeIntervalSince1970:[dataDict[@"readed_at"] intValue]];
    }
    if(dataDict[@"revoke"]) {
        messageExtra.revoke = [dataDict[@"revoke"] boolValue];
    }
    if(dataDict[@"revoker"]) {
        messageExtra.revoker = dataDict[@"revoker"];
    }
    if(dataDict[@"readed_count"]) {
        messageExtra.readedCount = [dataDict[@"readed_count"] integerValue];
    }
    if(dataDict[@"unread_count"]) {
        messageExtra.unreadCount = [dataDict[@"unread_count"] integerValue];
    }
    if(dataDict[@"extra_version"]) {
        messageExtra.extraVersion = [dataDict[@"extra_version"] unsignedLongLongValue];
    }
    if(dataDict[@"edited_at"]) {
        messageExtra.editedAt = [dataDict[@"edited_at"] integerValue];
    }
    
    NSDictionary *payloadDict;
    NSData *planPayloadData;
    if(!dataDict[@"content_edit"] ||  dataDict[@"content_edit"] == [NSNull null] ) {
        payloadDict = nil;
    }else {
        payloadDict = dataDict[@"content_edit"];
        planPayloadData = [NSJSONSerialization dataWithJSONObject:payloadDict options:kNilOptions error:nil];
    }
   
    if(payloadDict) {
        NSNumber *contentType;
        WKMessageContent *messageContent =  [self decodeMessageContent:payloadDict contentType:&contentType];
        messageExtra.contentEditData = planPayloadData;
        messageExtra.contentEdit = messageContent;
    }
    
    return messageExtra;
}


+(WKReaction*) toReaction:(NSDictionary*)dataDict {
    WKReaction *reaction = [WKReaction new];
    reaction.uid = dataDict[@"uid"]?:@"";
    if(dataDict[@"message_id"]) {
        NSDecimalNumber* messageIDNumber = [[NSDecimalNumber alloc] initWithString:dataDict[@"message_id"]];
        reaction.messageId = [messageIDNumber unsignedLongLongValue];
    }
   
    reaction.emoji = dataDict[@"emoji"]?:@"";
    
    NSString *channelID = dataDict[@"channel_id"]?:@"";
    NSInteger channelType = [dataDict[@"channel_type"] intValue];
    
    reaction.channel = [WKChannel channelID:channelID channelType:channelType];
    
    reaction.version = [dataDict[@"seq"] longLongValue];
    reaction.createdAt = dataDict[@"created_at"];
    reaction.isDeleted = [dataDict[@"is_deleted"] intValue];
    
    return reaction;
}


+(WKMessageContent*) decodeMessageContent:(NSDictionary*)payloadDict contentType:(NSNumber**)contentType{
    if(!payloadDict || ![payloadDict isKindOfClass:[NSDictionary class]]) {
        payloadDict = @{@"type":@(WK_UNKNOWN)};
    }
    NSNumber *contentTpe = payloadDict[@"type"];
    if(!contentTpe) {
        contentTpe = @(WK_UNKNOWN);
    }
    
    WKMessageContent *messageContent;
    if(!contentTpe) {
        messageContent = [[WKUnknownContent alloc] init];
    }else {
        Class contentClass = [[WKSDK shared] getMessageContent:contentTpe.integerValue];
        messageContent = [[contentClass alloc] init];
    }

    NSData *contentData = [NSJSONSerialization dataWithJSONObject:payloadDict options:kNilOptions error:nil];
    // 解码正文内容
    [messageContent decode:contentData];
   
    *contentType = contentTpe;
    
    return messageContent;
}

+ (NSDictionary *)toDic:(NSString *)jsonStr {
  if (!jsonStr || [jsonStr isEqualToString:@""]) {
    return nil;
  }
  NSDictionary *dic = [NSJSONSerialization
      JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]
                 options:NSJSONReadingAllowFragments
                   error:nil];

  return dic;
}

@end
