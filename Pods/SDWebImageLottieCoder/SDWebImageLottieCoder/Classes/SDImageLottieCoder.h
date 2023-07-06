/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

#if __has_include(<SDWebImage/SDWebImage.h>)
#import <SDWebImage/SDWebImage.h>
#else
@import SDWebImage;
#endif

static const SDImageFormat SDImageFormatLottie = 16;

/// A Lottie JSON decoder, which can decode vector aniamtion into the bitmap format aniamted image. Backing by Samsung's rlottie framework.
/// You can use this coder to play Lottie Animation right on `SDAnimatedImageView`, not `LOTAnimationView`, which is fater because the aniamted image now pre-decoded and use bitmap form.
@interface SDImageLottieCoder : NSObject <SDAnimatedImageCoder>

@property (nonatomic, class, readonly, nonnull) SDImageLottieCoder *sharedCoder;

@end
