//
//  WKAPIClient.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKAPIClient.h"
#import <AFNetworking/AFNetworking.h>

@interface WKAPIClient ()

@property(nonatomic,strong) AFHTTPSessionManager *sessionManager;

@end

@implementation WKAPIClient


+ (instancetype)shared {
    static WKAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[WKAPIClient alloc] init];
    });
    
    return _sharedClient;
}

- (void)setBaseURL:(NSString *)baseURL {
    _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    if([baseURL hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        _sessionManager.securityPolicy = securityPolicy;
    }
    _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
}

-(void) GET:(NSString*)path parameters:(id)parameters complete:(void(^)(id respose,NSError *error))complete{
    NSLog(@"请求路径：%@",path);
    NSLog(@"请求参数：%@",parameters);
    [self.sessionManager GET:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回结果：%@",responseObject);
        complete(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"返回失败：%@",error);
        complete(nil,error);
    }];
}

-(void) POST:(NSString*)path parameters:(id)parameters complete:(void(^)(id respose,NSError *error))complete{
    NSLog(@"请求路径：%@",path);
    NSLog(@"请求参数：%@",parameters);
    [self.sessionManager POST:path parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回结果：%@",responseObject);
        complete(responseObject,nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"返回失败：%@",error);
        complete(nil,error);
    }];
}

@end
