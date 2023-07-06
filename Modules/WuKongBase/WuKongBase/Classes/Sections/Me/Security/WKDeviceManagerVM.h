//
//  WKDeviceManagerVM.h
//  WuKongBase
//
//  Created by tt on 2020/10/22.
//

#import "WuKongBase.h"
@class WKDeviceModel;
@class WKDeviceManagerVM;
NS_ASSUME_NONNULL_BEGIN

@protocol WKDeviceManagerVMDelegate <NSObject>

@optional

// 设备被点击
-(void) deviceManagerVMDeviceClick:(WKDeviceManagerVM*)vm device:(WKDeviceModel*)device;




@end

@interface WKDeviceManagerVM : WKBaseTableVM

@property(nonatomic,weak) id<WKDeviceManagerVMDelegate> delegate;


/// 删除设备
/// @param deviceID <#deviceID description#>
-(AnyPromise*) deleteDevice:(NSString*)deviceID;

@end

@interface WKDeviceModel : WKModel

@property(nonatomic,copy) NSString *deviceID; // 设备唯一ID
@property(nonatomic,copy) NSString *deviceName; // 设备名称
@property(nonatomic,copy) NSString *deviceModel; // 设备型号
@property(nonatomic,copy) NSString *lastLogin; // 最后一次登录时间
@property(nonatomic,assign) BOOL selfB; // 是否是本机

@end

NS_ASSUME_NONNULL_END
