//
//  WKRecvPacket.h
//  WuKongIMSDK
//
//  Created by tt on 2019/11/27.
//

#import <Foundation/Foundation.h>
#import "WKPacket.h"
#import "WKPacketBodyCoder.h"
#import "WKSetting.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKRecvPacket : WKPacket<WKPacketBodyCoder>

// 消息设置
@property(nonatomic,strong) WKSetting *setting;
// 消息唯一ID
@property(nonatomic,assign) uint64_t messageId;
// 消息序列号 （用户唯一，有序递增）
@property(nonatomic,assign) uint32_t messageSeq;
// 客户端消息唯一编号（用于消息去重）
@property(nonatomic,copy) NSString *clientMsgNo;
// 服务器时间
@property(nonatomic,assign) uint32_t timestamp;
// 发送者UID
@property(nonatomic,copy) NSString *fromUid;
//频道ID（如果是个人频道ChannelId为个人的UID）
@property(nonatomic,copy) NSString *channelId;
//频道类型（1.个人 2.群组）
@property(nonatomic,assign) uint8_t channelType;
// 话题
@property(nonatomic,copy) NSString *topic;
// 负荷数据
@property(nonatomic,strong) NSData *payload;
@end

NS_ASSUME_NONNULL_END
