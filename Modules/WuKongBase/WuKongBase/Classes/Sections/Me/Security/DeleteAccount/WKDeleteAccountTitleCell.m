//
//  WKDeleteAccountTitleCell.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKDeleteAccountTitleCell.h"
#import "WKApp.h"
@implementation WKDeleteAccountTitleCellModel

-(Class) cell {
    return WKDeleteAccountTitleCell.class;
}

- (CGFloat)fontSize {
    if(!_fontSize) {
        _fontSize = 20.0f;
    }
    return _fontSize;
}

@end

@interface WKDeleteAccountTitleCell ()

@property(nonatomic,strong) UILabel *titleLbl;

@property(nonatomic,strong) UILabel *valueLbl;

@end

@implementation WKDeleteAccountTitleCell

- (void)setupUI {
    [super setupUI];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:self.titleLbl];
    [self.contentView addSubview:self.valueLbl];
    
}

- (void)refresh:(WKDeleteAccountTitleCellModel *)model {
    [super refresh:model];
    
    self.titleLbl.text = model.title;
    self.titleLbl.font =  [[WKApp shared].config appFontOfSize:model.fontSize];
    [self.titleLbl sizeToFit];
    
    self.valueLbl.text = model.value;
    self.valueLbl.font =  [[WKApp shared].config appFontOfSize:model.fontSize];
    [self.valueLbl sizeToFit];
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLbl.lim_left = 10.0f;
    self.titleLbl.lim_centerY_parent = self.contentView;
    
    self.valueLbl.lim_centerY_parent = self.contentView;
    self.valueLbl.lim_left = self.titleLbl.lim_right;
}

- (UILabel *)titleLbl {
    if(!_titleLbl) {
        _titleLbl = [[UILabel alloc] init];
    }
    return _titleLbl;
}

- (UILabel *)valueLbl {
    if(!_valueLbl) {
        _valueLbl = [[UILabel alloc] init];
        _valueLbl.textColor = WKApp.shared.config.themeColor;
    }
    return _valueLbl;
}

@end
