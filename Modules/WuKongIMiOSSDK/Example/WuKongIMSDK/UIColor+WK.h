
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (WK)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;


+ (UIColor *)colorWithHexString:(NSString *)stringToConvert withAlpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGBHex:(UInt32)hex;

- (NSString *)toHexRGB;


@end

NS_ASSUME_NONNULL_END
