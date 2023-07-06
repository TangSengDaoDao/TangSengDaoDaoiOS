//
//  WKDeviceManagerVM.m
//  WuKongBase
//
//  Created by tt on 2020/10/22.
//

#import "WKDeviceManagerVM.h"
#import "WKDeviceManagerCell.h"

@interface WKDeviceManagerVM ()

@property(nonatomic,strong) NSArray<WKDeviceModel*> *devices;

@end

@implementation WKDeviceManagerVM

- (NSArray<NSDictionary *> *)tableSectionMaps{
    
    // 设备items
    NSMutableArray *deviceItems = [NSMutableArray array];
    
    BOOL deviceLock = [self deviceLockOn];
    __weak typeof(self) weakSelf = self;
    if(self.devices && self.devices.count>0) {
        for (WKDeviceModel *deviceModel in self.devices) {
            [deviceItems addObject: @{
                @"class":WKDeviceManagerModel.class,
                @"deviceName":deviceModel.deviceName?:@"",
                @"deviceModel": deviceModel.deviceModel?:@"",
                @"onClick":^{
                    if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(deviceManagerVMDeviceClick:device:)]) {
                        [weakSelf.delegate deviceManagerVMDeviceClick:weakSelf device:deviceModel];
                    }
                }
            }];
        }
    }
    
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@{
        @"height":@(15.0f),
        @"remark":[NSString stringWithFormat:LLang(@"开启登录保护后，在陌生设备登录%@需要进行安全验证。推荐开启，保障你的账号安全"),[WKApp shared].config.appName],
        @"items":@[
                @{
                    @"class":WKSwitchItemModel.class,
                    @"label":LLang(@"登录保护"),
                    @"on": @(deviceLock),
                    @"onSwitch":^(BOOL on){
                        [weakSelf setDeviceLockOn:on];
                        [weakSelf reloadData];
                    }
                },
        ],
    }];
    if(deviceLock && deviceItems.count>0) {
        [items addObject:@{
            @"height":@(15.0f),
            @"title":LLang(@"通过安全验证的设备"),
            @"remark":[NSString stringWithFormat:LLang(@"你可以查看列表中设备的“最后登录时间”，或删除设备。删除后在该设备登录%@需要重新进行安全验证。"),[WKApp shared].config.appName],
            @"items":deviceItems,
        }];
    }
    
    return items;
}

// 设备锁是否开启
-(BOOL) deviceLockOn {
    NSDictionary *settingDict = [WKApp shared].loginInfo.extra[@"setting"];
    if(settingDict && settingDict[@"device_lock"]) {
        return [settingDict[@"device_lock"] boolValue];
    }
    return false;
}

-(void) setDeviceLockOn:(BOOL)on {
    [self setting:@"device_lock" on:on];
}

- (void)requestData:(void (^)(NSError * _Nullable))complete {
    __weak typeof(self) weakSelf = self;
    [self getDevices].then(^(NSArray *devices){
        weakSelf.devices = devices;
        complete(nil);
    }).catch(^(NSError *error){
        complete(error);
    });
}

-(AnyPromise*) getDevices {
    return [[WKAPIClient sharedClient] GET:@"user/devices" parameters:nil model:WKDeviceModel.class];
}

-(AnyPromise*) deleteDevice:(NSString*)deviceID {
    return [[WKAPIClient sharedClient] DELETE:[NSString stringWithFormat:@"user/devices/%@",deviceID] parameters:nil];
}


-(AnyPromise*) setting:(NSString*)key on:(BOOL)on{
    __weak typeof(self) weakSelf = self;
   return [[WKAPIClient sharedClient] PUT:@"user/my/setting" parameters:@{key:(on?@(1):@(0))}].then(^{
       NSDictionary *settingDict = [WKApp shared].loginInfo.extra[@"setting"];
       NSMutableDictionary *settingMap = [NSMutableDictionary dictionaryWithDictionary:settingDict];
        settingMap[key] = on?@(1):@(0);
        [WKApp shared].loginInfo.extra[@"setting"] =settingMap;
        [[WKApp shared].loginInfo save];
       [weakSelf reloadData];
    }).catch(^(NSError*error){
        WKLogError(@"设置失败！->%@",error);
    });
}
@end

@implementation WKDeviceModel

+ (WKModel *)fromMap:(NSDictionary *)dictory type:(ModelMapType)type {
    WKDeviceModel *model = [WKDeviceModel new];
    model.deviceID = dictory[@"device_id"];
    model.deviceName = dictory[@"device_name"];
    model.deviceModel = dictory[@"device_model"];
    model.lastLogin = dictory[@"last_login"];
    model.selfB = [dictory[@"self"] boolValue];
    return model;
}

@end
