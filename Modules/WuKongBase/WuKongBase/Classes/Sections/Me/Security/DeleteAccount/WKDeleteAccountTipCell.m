//
//  WKDeleteAccountTipCell.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKDeleteAccountTipCell.h"
#import "WKApp.h"
#define leftSpace 10.0f

@implementation WKDeleteAccountTipCellModel

-(Class) cell {
    return WKDeleteAccountTipCell.class;
}

- (CGFloat)fontSize {
    if(!_fontSize) {
        _fontSize = 15.0f;
    }
    return _fontSize;
}

@end

@interface WKDeleteAccountTipCell ()

@property(nonatomic,strong) UILabel *tipLbl;

@end

@implementation WKDeleteAccountTipCell

+ (CGSize)sizeForModel:(WKDeleteAccountTipCellModel *)model {
    CGSize size = [self getTextSize:model.tip maxWidth:WKScreenWidth - leftSpace*2 fontSize:model.fontSize];
    return  CGSizeMake(WKScreenWidth, size.height);
}

- (void)setupUI {
    [super setupUI];
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.tipLbl];
    
}

- (void)refresh:(WKDeleteAccountTipCellModel *)model {
    [super refresh:model];
    
    self.tipLbl.font = [WKApp.shared.config appFontOfSize:model.fontSize];
    self.tipLbl.text = model.tip;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tipLbl.lim_size = CGSizeMake(self.contentView.lim_width - leftSpace*2, self.contentView.lim_height);
    self.tipLbl.lim_left = leftSpace;
    
    
}

- (UILabel *)tipLbl {
    if(!_tipLbl) {
        _tipLbl = [[UILabel alloc] init];
        _tipLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _tipLbl.numberOfLines = 0;
    }
    return _tipLbl;
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[WKApp.shared.config appFontOfSize:fontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

@end
