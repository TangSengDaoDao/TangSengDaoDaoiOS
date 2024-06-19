//
//  WKUUIDUtil.m
//  WuKongIMSDK
//
//  Created by tt on 2020/5/28.
//

#import "WKUUIDUtil.h"
#import "WKNOGeneraterUtil.h"
@implementation WKUUIDUtil

+ (NSString*)getUUID{
    CFUUIDRef uuidRef =CFUUIDCreate(NULL);
    CFStringRef uuidStringRef =CFUUIDCreateString(NULL, uuidRef);
    NSString *uniqueId = (__bridge NSString *)(uuidStringRef);
    return [uniqueId stringByReplacingOccurrencesOfString:@"-" withString:@""];

}

+(NSString*) getClientMsgNo:(NSString*)custId toCustId:(NSString*)toCustId chatId:(NSString*)chatId {
    return [NSString stringWithFormat:@"%@%@",[self getUUID],@"2"]; // clientMsgNo后面加一位 表示客户端标识 0.系统 1.android 2.iOS 3.Web
//    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970]*1000*1000*1000;
//    NSString  *msgNoStr = [NSString stringWithFormat:@"%@:%@:%@:%llu",custId,toCustId,chatId,(unsigned long long)timeInterval];
//    uint64_t msgNo = get_sign64([msgNoStr UTF8String], (int)[msgNoStr length]);
//
//       if(msgNo>=LONG_LONG_MAX){
//           msgNo = msgNo%LONG_LONG_MAX;
//       }
//
//       return [NSString stringWithFormat:@"%llu",msgNo];
}
@end
