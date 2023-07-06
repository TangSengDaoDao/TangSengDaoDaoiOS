//
//  WKDeviceManagerCell.h
//  WuKongBase
//
//  Created by tt on 2020/10/22.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKDeviceManagerModel : WKFormItemModel

@property(nonatomic,copy) NSString *deviceName; // 设备名称
@property(nonatomic,copy) NSString *deviceModel; // 设备型号

@end

@interface WKDeviceManagerCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
