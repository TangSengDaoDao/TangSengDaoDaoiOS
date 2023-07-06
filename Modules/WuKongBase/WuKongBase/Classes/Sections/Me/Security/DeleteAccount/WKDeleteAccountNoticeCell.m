//
//  WKDeleteAccountNoticeCell.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKDeleteAccountNoticeCell.h"
#import "WKBadgeView.h"
#import "WKApp.h"

#define leftSpace 40.0f

#define topSpace 0.0f

#define valueContentWidth WKScreenWidth - leftSpace - 40.0f

@implementation WKDeleteAccountNoticeCellModel

- (Class)cell {
    return WKDeleteAccountNoticeCell.class;
}

- (NSInteger)fontSize {
    if(!_fontSize) {
        _fontSize = 15.0f;
    }
    return _fontSize;
}

@end

@interface WKDeleteAccountNoticeCell ()

@property(nonatomic,strong) WKBadgeView *badgeView;

@property(nonatomic,strong) UILabel *numbLbl;

@property(nonatomic,strong) UILabel *valueLbl;

@end

@implementation WKDeleteAccountNoticeCell

+ (CGSize)sizeForModel:(WKDeleteAccountNoticeCellModel *)model {
    CGSize size = [self getTextSize:model.value maxWidth:valueContentWidth fontSize:model.fontSize];
    return CGSizeMake(WKScreenWidth, MAX(size.height+topSpace, 20.0f));
}

- (void)setupUI {
    [super setupUI];
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self.contentView addSubview:self.badgeView];
    [self.contentView addSubview:self.numbLbl];
    [self.contentView addSubview:self.valueLbl];
    
}

- (void)refresh:(WKDeleteAccountNoticeCellModel *)model {
    [super refresh:model];
    
    self.badgeView.hidden = YES;
    self.numbLbl.hidden = YES;
    if(model.style == WKDeleteAccountNoticeNumStyleBadge) {
        self.badgeView.hidden = NO;
        [self.badgeView setBadgeValue:[NSString stringWithFormat:@"%ld",model.num]];
    }else{
        self.numbLbl.hidden = NO;
        self.numbLbl.text = [NSString stringWithFormat:@"%ld.",model.num];
        self.numbLbl.font = [WKApp.shared.config appFontOfSize:model.fontSize];
        [self.numbLbl sizeToFit];
    }
   
    self.valueLbl.font = [WKApp.shared.config appFontOfSize:model.fontSize];
    self.valueLbl.text = model.value;
    self.valueLbl.lim_width = valueContentWidth;
    [self.valueLbl sizeToFit];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.lim_left = 10.0f;
    self.numbLbl.lim_left = 10.0f;
    self.valueLbl.lim_left = leftSpace;
    self.valueLbl.lim_top = topSpace;
}

- (WKBadgeView *)badgeView {
    if(!_badgeView) {
        _badgeView = [[WKBadgeView alloc] init];
    }
    return _badgeView;
}

- (UILabel *)valueLbl {
    if(!_valueLbl) {
        _valueLbl = [[UILabel alloc] init];
        _valueLbl.numberOfLines = 0;
        _valueLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _valueLbl.textColor = WKApp.shared.config.tipColor;
        _valueLbl.textAlignment = NSTextAlignmentLeft;
    }
    return _valueLbl;
}

- (UILabel *)numbLbl {
    if(!_numbLbl) {
        _numbLbl = [[UILabel alloc] init];
        _numbLbl.textColor = WKApp.shared.config.tipColor;
    }
    return _numbLbl;
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
