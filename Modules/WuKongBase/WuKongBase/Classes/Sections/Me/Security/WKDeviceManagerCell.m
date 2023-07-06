//
//  WKDeviceManagerCell.m
//  WuKongBase
//
//  Created by tt on 2020/10/22.
//

#import "WKDeviceManagerCell.h"

@implementation WKDeviceManagerModel

- (Class)cell {
    return WKDeviceManagerCell.class;
}

@end

@interface WKDeviceManagerCell ()

@property(nonatomic,strong) UILabel *deviceNameLbl;
@property(nonatomic,strong) UILabel *deviceModelLbl;

@end

@implementation WKDeviceManagerCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, 60.0f);
}

- (void)setupUI {
    [super setupUI];
    [self.contentView addSubview:self.deviceNameLbl];
    [self.contentView addSubview:self.deviceModelLbl];
}

- (void)refresh:(WKDeviceManagerModel *)model {
    [super refresh:model];
    
    self.deviceNameLbl.text = model.deviceName;
    [self.deviceNameLbl sizeToFit];
    
    self.deviceModelLbl.text = model.deviceModel;
    [self.deviceModelLbl sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat deviceModelTopSpace = 5.0f;
    
    self.deviceNameLbl.lim_top =self.contentView.lim_height/2.0f - (self.deviceNameLbl.lim_height+self.deviceModelLbl.lim_height+deviceModelTopSpace)/2.0f;
    self.deviceNameLbl.lim_left = 15.0f;
    
    self.deviceModelLbl.lim_top = self.deviceNameLbl.lim_bottom + deviceModelTopSpace;
    self.deviceModelLbl.lim_left = self.deviceNameLbl.lim_left;
}

- (UILabel *)deviceNameLbl {
    if(!_deviceNameLbl) {
        _deviceNameLbl = [[UILabel alloc] init];
        _deviceNameLbl.font = [[WKApp shared].config appFontOfSize:16.0f];
        _deviceNameLbl.textColor = [WKApp shared].config.defaultTextColor;
    }
    return _deviceNameLbl;
}

- (UILabel *)deviceModelLbl {
    if(!_deviceModelLbl) {
        _deviceModelLbl = [[UILabel alloc] init];
        _deviceModelLbl.font = [[WKApp shared].config appFontOfSize:14.0f];
        _deviceModelLbl.textColor = [WKApp shared].config.tipColor;
    }
    return _deviceModelLbl;
}

@end
