//
//  WKTextCell.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/24.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKTextCell.h"
#import "UIColor+WK.h"

#define messageMaxWidth 250.0f
#define messageFontSize 16.0f
#define contentPadding UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)
#define bubblePadding UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f)

@interface WKTextCell ()

@property(nonatomic,strong) WKMessage *message;

@property(nonatomic,strong) UIView *avatarView;
@property(nonatomic,strong) UILabel *avatarLbl;

@end

@implementation WKTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
   if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       self.selectionStyle = UITableViewCellSelectionStyleNone;
      
       [self initUI];
   }
    return self;
}

+(CGSize) sizeForMessage:(WKMessage*)message {
    NSString *msg = @"";
    if(![message.content isKindOfClass:[WKTextContent class]]) {
        msg = @"未知消息";
    } else {
        WKTextContent *content = (WKTextContent*)message.content;
        msg = content.content;
    }
    
    
    CGSize size = [self getTextSize:msg maxWidth:messageMaxWidth fontSize:messageFontSize];
    return CGSizeMake(size.width + contentPadding.left + contentPadding.right + bubblePadding.left + bubblePadding.right, size.height + contentPadding.top + contentPadding.bottom + bubblePadding.top + bubblePadding.bottom);
}

-(void) initUI {
    [self setBackgroundColor:[UIColor clearColor]];
    self.contentView.userInteractionEnabled = YES;
    
    [self.contentView addSubview:self.bubbleView];
    [self.bubbleView addSubview:self.contentLbl];
    
    [self.contentView addSubview:self.avatarView];
}

-(void) refresh:(WKMessage*)message {
    self.message = message;
    NSString *msg = @"";
    if(![message.content isKindOfClass:[WKTextContent class]]) {
        msg = @"未知消息";
    } else {
        WKTextContent *content = (WKTextContent*)message.content;
        msg = content.content;
    }
    self.contentLbl.text = msg;
    if(message.isSend) {
        self.bubbleView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:99.0f/255.0f blue:66.0f/255.0f alpha:1.0f];
        self.contentLbl.textColor = [UIColor whiteColor];
    }else {
        self.bubbleView.backgroundColor = [UIColor whiteColor];
        self.contentLbl.textColor = [UIColor blackColor];
    }
    
    self.avatarView.backgroundColor = [self.class userColor:message.fromUid];
    if(message.fromUid && message.fromUid.length>0) {
        self.avatarLbl.text = [[message.fromUid substringToIndex:1] uppercaseString];
        [self.avatarLbl sizeToFit];
    }
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat avatarLeft = 5.0f;
    CGFloat avatarToBubble = 5.0f;
    
    
    CGSize messageSize = [self.class sizeForMessage:self.message];
    
    CGRect bubbleFrame = CGRectMake(bubblePadding.left, bubblePadding.top, messageSize.width - bubblePadding.left - bubblePadding.right, messageSize.height - bubblePadding.top - bubblePadding.bottom);
    
    self.contentLbl.frame = CGRectMake(contentPadding.left, contentPadding.top, bubbleFrame.size.width - contentPadding.left - contentPadding.right, bubbleFrame.size.height - contentPadding.top - contentPadding.bottom);
    
    CGRect avatarFrame = self.avatarView.frame;
    if(self.message.isSend) {
        avatarFrame.origin.x = self.contentView.frame.size.width - avatarFrame.size.width - avatarLeft;
        bubbleFrame.origin.x = avatarFrame.origin.x - bubbleFrame.size.width - avatarToBubble;
    } else {
        avatarFrame.origin.x = avatarLeft;
        bubbleFrame.origin.x = avatarFrame.origin.x + avatarFrame.size.width + avatarToBubble;
    }
    self.bubbleView.frame = bubbleFrame;
    self.avatarView.frame = avatarFrame;
    
    CGRect avatarLblFrame = self.avatarLbl.frame;
    avatarLblFrame.origin.x = avatarFrame.size.width /2.0f - avatarLblFrame.size.width/2.0f;
    avatarLblFrame.origin.y = avatarFrame.size.height/2.0f - avatarLblFrame.size.height/2.0f;
    self.avatarLbl.frame = avatarLblFrame;
}

- (UIView *)bubbleView {
    if(!_bubbleView) {
        _bubbleView = [[UIView alloc] init];
        _bubbleView.layer.masksToBounds = YES;
        _bubbleView.layer.cornerRadius = 2.0f;
    }
    return _bubbleView;
}

- (UILabel *)contentLbl {
    if(!_contentLbl) {
        _contentLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, messageMaxWidth, 0.0f)];
        _contentLbl.font = [UIFont systemFontOfSize:messageFontSize];
        _contentLbl.numberOfLines = 0;
        _contentLbl.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLbl.textColor = [UIColor whiteColor];
        
    }
    return _contentLbl;
}
- (UIView *)avatarView {
    if(!_avatarView) {
        _avatarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = _avatarView.frame.size.height/2.0f;
        
        [_avatarView addSubview:self.avatarLbl];
    }
    return _avatarView;
}

- (UILabel *)avatarLbl {
    if(!_avatarLbl) {
        _avatarLbl = [[UILabel alloc] init];
        _avatarLbl.font = [UIFont boldSystemFontOfSize:20.0f];
        _avatarLbl.textColor = [UIColor whiteColor];
    }
    return _avatarLbl;
}

+ (CGSize) getTextSize:(NSString*) text maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByWordWrapping;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize], NSParagraphStyleAttributeName:style}];
    CGSize size =  [string boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    return size;
}

+(UIColor*) userColor:(NSString*)value {
    static NSArray<NSNumber*> *colors;
    if(!colors) {
        colors = @[@0x8C8DFF, @0x7983C2, @0x6D8DDE, @0x5979F0, @0x6695DF, @0x8F7AC5,
                   @0x9D77A5, @0x8A64D0, @0xAA66C3, @0xA75C96, @0xC8697D, @0xB74D62,
                   @0xBD637C, @0xB3798E, @0x9B6D77, @0xB87F7F, @0xC5595A, @0xAA4848,
                   @0xB0665E, @0xB76753, @0xBB5334, @0xC97B46, @0xBE6C2C, @0xCB7F40,
                   @0xA47758, @0xB69370, @0xA49373, @0xAA8A46, @0xAA8220, @0x76A048,
                   @0x9CAD23, @0xA19431, @0xAA9100, @0xA09555, @0xC49B4B, @0x5FB05F,
                   @0x6AB48F, @0x71B15C, @0xB3B357, @0xA3B561, @0x909F45, @0x93B289,
                   @0x3D98D0, @0x429AB6, @0x4EABAA, @0x6BC0CE, @0x64B5D9, @0x3E9CCB,
                   @0x2887C4, @0x52A98B];
    }
    return  [UIColor colorWithRGBHex:colors[[value hash]%colors.count].unsignedIntValue];
}

@end
