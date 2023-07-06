//
//  WKSearchMessageCell.m
//  WuKongBase
//
//  Created by tt on 2020/5/10.
//

#import "WKSearchMessageCell.h"
#import <SDWebImage/SDWebImage.h>
#import "WKApp.h"
#import "WuKongBase.h"
@implementation WKSearchMessageModel

- (Class)cell {
    return WKSearchMessageCell.class;
}

- (NSNumber *)showArrow {
    return @(NO);
}

@end

@interface WKSearchMessageCell ()

@property(nonatomic,strong) WKUserAvatar *avatarImgView;
@property(nonatomic,strong) UILabel *nameLbl;
@property(nonatomic,strong) UILabel *contentLbl;

@end

@implementation WKSearchMessageCell

+ (CGSize)sizeForModel:(WKFormItemModel *)model {
    return CGSizeMake(WKScreenWidth, WKDefaultAvatarSize.height + 10.0f + 10.0f);
}

- (void)setupUI {
    [super setupUI];
    
    // avatar
    self.avatarImgView = [[WKUserAvatar alloc] init];
    [self addSubview:self.avatarImgView];
    
    // name
    self.nameLbl = [[UILabel alloc] init];
    [self addSubview:self.nameLbl];
    
    // content
    self.contentLbl = [[UILabel alloc] init];
    [self.contentLbl setFont:[UIFont systemFontOfSize:14.0f]];
    [self.contentLbl setTextColor:[UIColor grayColor]];
    [self addSubview:self.contentLbl];
}

- (void)refresh:(WKSearchMessageModel *)model {
    [super refresh:model];
    
    self.avatarImgView.url = model.avatar;
    self.nameLbl.text = model.name;
    self.contentLbl.attributedText = nil;
    if(model.content && ![model.content isEqualToString:@""]) {
         NSMutableAttributedString *contentAttr = [[NSMutableAttributedString alloc] initWithString:model.content];
        if(model.keyword && ![model.keyword isEqualToString:@""]) {
            NSRange colorRange = [[model.content lowercaseString] rangeOfString:[model.keyword lowercaseString]];
            [contentAttr addAttribute:NSForegroundColorAttributeName value:[WKApp shared].config.themeColor range:colorRange];
        }
        self.contentLbl.attributedText = contentAttr;
    }else {
        self.contentLbl.text = [NSString stringWithFormat:LLang(@"%d 条相关聊天记录"),[model.messageCount intValue]];
    }
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // avatar
    self.avatarImgView.lim_left = 20.0f;
    self.avatarImgView.lim_top = [self lim_centerY:self.avatarImgView];
    
    
    // name
    CGFloat nameLeftSpace = 15.0f;
    CGFloat nameHeight = 20.0f;
    self.nameLbl.lim_width = self.lim_width -( self.avatarImgView.lim_right + nameLeftSpace + 20.0f);
    self.nameLbl.lim_height = nameHeight;
    self.nameLbl.lim_left = self.avatarImgView.lim_right + nameLeftSpace;
    
    self.nameLbl.lim_top = 10.0f;
    
    // content
    self.contentLbl.lim_width = self.nameLbl.lim_width;
    self.contentLbl.lim_height = 15.0f;
    self.contentLbl.lim_left = self.nameLbl.lim_left;
    self.contentLbl.lim_top = self.nameLbl.lim_bottom + 10.0f;
}

@end
