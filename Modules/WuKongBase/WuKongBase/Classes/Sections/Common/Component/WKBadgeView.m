//
//  WKBadgeView.m
//  WuKongBase
//
//  Created by tt on 2020/1/5.
//

#import "WKBadgeView.h"


@interface WKBadgeView ()



@property (strong) UIColor *badgeTextColor;

@property (nonatomic) UIFont *badgeTextFont;

@property (nonatomic) CGFloat badgeTopPadding; //数字顶部到红圈的距离

@property (nonatomic) CGFloat badgeLeftPadding; //数字左部到红圈的距离

@property (nonatomic) CGFloat whiteCircleWidth; //最外层白圈的宽度

@property (nonatomic) CGFloat circleWidth; //最外层圈的宽度

@end
@implementation WKBadgeView

+ (instancetype)viewWithBadgeTip:(NSString *)badgeValue{
    WKBadgeView *instance = [[WKBadgeView alloc] init];
    instance.badgeValue = badgeValue;
    return instance;
}
+ (instancetype)viewWithoutBadgeTip{
    WKBadgeView *instance = [[WKBadgeView alloc] init];
    instance.badgeTopPadding      = 1.f;
    instance.badgeLeftPadding     = 1.f;
    instance.frame = [instance frameWithStr:nil];
    
    return instance;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor  = [UIColor clearColor];
        _badgeBackgroundColor = [UIColor redColor];
        _badgeTextColor       = [UIColor whiteColor];
        _badgeTextFont        = [UIFont systemFontOfSize:12.0f];
        _whiteCircleWidth     = 0.0f;
        
        _circleWidth = 4.0f;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    if ([[self badgeValue] length]) {
        [self drawWithContent:rect context:context];
    }else{
        [self drawWithOutContent:rect context:context];
    }
    CGContextRestoreGState(context);
}

- (void)setBadgeValue:(NSString *)badgeValue {
    _badgeValue = badgeValue;
    if (_badgeValue && _badgeValue.integerValue > 9) {
        _badgeLeftPadding     = 6.f;
    }else{
        _badgeLeftPadding     = 2.f;
    }
    _badgeTopPadding      = 2.f;
    
    self.frame = [self frameWithStr:badgeValue];
    
    
    [self setNeedsDisplay];
}

- (CGSize)badgeSizeWithStr:(NSString *)badgeValue{
    if (!badgeValue || badgeValue.length == 0) {
        return CGSizeZero;
    }
    CGSize size = [badgeValue sizeWithAttributes:@{NSFontAttributeName:self.badgeTextFont}];
    if (size.width < size.height) {
        size = CGSizeMake(size.height, size.height);
    }
    return size;
}

- (CGRect)frameWithStr:(NSString *)badgeValue{
    CGSize badgeSize = [self badgeSizeWithStr:badgeValue];
    CGRect badgeFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, badgeSize.width + self.badgeLeftPadding * 2 + self.circleWidth * 2, badgeSize.height + self.badgeTopPadding * 2 + self.circleWidth * 2);//8=2*2（红圈-文字）+2*2（白圈-红圈）
    return badgeFrame;
}



#pragma mark - Private
- (void)drawWithContent:(CGRect)rect context:(CGContextRef)context{
    // CGRect bodyFrame = self.bounds;
    CGRect bkgFrame = CGRectInset(self.bounds, self.circleWidth, self.circleWidth);
    CGRect badgeSize = CGRectInset(self.bounds, self.circleWidth + self.badgeLeftPadding, self.circleWidth + self.badgeTopPadding);
    if ([self badgeBackgroundColor]) {//外白色描边
        //        CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
        //        if ([self badgeValue].integerValue > 9) {
        //            CGFloat circleWith = bodyFrame.size.height;
        //            CGFloat totalWidth = bodyFrame.size.width;
        //            CGFloat diffWidth = totalWidth - circleWith;
        //            CGPoint originPoint = bodyFrame.origin;
        //            CGRect leftCicleFrame = CGRectMake(originPoint.x, originPoint.y, circleWith, circleWith);
        //            CGRect centerFrame = CGRectMake(originPoint.x +circleWith/2, originPoint.y, diffWidth, circleWith);
        //            CGRect rightCicleFrame = CGRectMake(originPoint.x +(totalWidth - circleWith), originPoint.y, circleWith, circleWith);
        //            CGContextFillEllipseInRect(context, leftCicleFrame);
        //            CGContextFillRect(context, centerFrame);
        //            CGContextFillEllipseInRect(context, rightCicleFrame);
        //
        //        }else{
        //            CGContextFillEllipseInRect(context, bodyFrame);
        //        }
        // badge背景色
        CGContextSetFillColorWithColor(context, [[self badgeBackgroundColor] CGColor]);
        if ([self badgeValue].integerValue > 9) {
            CGFloat circleWith = bkgFrame.size.height;
            CGFloat totalWidth = bkgFrame.size.width;
            CGFloat diffWidth = totalWidth - circleWith;
            CGPoint originPoint = bkgFrame.origin;
            CGRect leftCicleFrame = CGRectMake(originPoint.x, originPoint.y, circleWith, circleWith);
            CGRect centerFrame = CGRectMake(originPoint.x +circleWith/2, originPoint.y, diffWidth, circleWith);
            CGRect rightCicleFrame = CGRectMake(originPoint.x +(totalWidth - circleWith), originPoint.y, circleWith, circleWith);
            CGContextFillEllipseInRect(context, leftCicleFrame);
            CGContextFillRect(context, centerFrame);
            CGContextFillEllipseInRect(context, rightCicleFrame);
        }else{
            CGContextFillEllipseInRect(context, bkgFrame);
        }
    }
    
    CGContextSetFillColorWithColor(context, [[self badgeTextColor] CGColor]);
    NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [badgeTextStyle setAlignment:NSTextAlignmentCenter];
    
    
    NSDictionary *badgeTextAttributes = @{
                                          NSFontAttributeName: [self badgeTextFont],
                                          NSForegroundColorAttributeName: [self badgeTextColor],
                                          NSParagraphStyleAttributeName: badgeTextStyle,
                                          };
    [[self badgeValue] drawInRect:CGRectMake(self.circleWidth + self.badgeLeftPadding,
                                             self.circleWidth + self.badgeTopPadding,
                                             badgeSize.size.width, badgeSize.size.height)
                   withAttributes:badgeTextAttributes];
}


- (void)drawWithOutContent:(CGRect)rect context:(CGContextRef)context{
    CGRect bodyFrame = self.bounds;
    CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextFillEllipseInRect(context, CGRectMake(bodyFrame.origin.x, bodyFrame.origin.y, bodyFrame.size.width - 1, bodyFrame.size.height - 1));
}

@end