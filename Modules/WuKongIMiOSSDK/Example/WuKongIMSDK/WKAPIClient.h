//
//  WKAPIClient.h
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKAPIClient : NSObject

+ (instancetype _Nonnull )shared;

-(void) setBaseURL:(NSString*)baseURL;

-(void) GET:(NSString*)path parameters:(nullable id)parameters complete:(void(^)(id respose,NSError *error))complete;

-(void) POST:(NSString*)path parameters:(id)parameters complete:(void(^)(id respose,NSError *error))complete;



@end

NS_ASSUME_NONNULL_END
