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

/**
 * The asset resource path used for lottie animation to load bitmap images in the animation. If you don't provide this context option, use main bundle's resource path instead.
 * Defaults to nil, means main bundle's resource path. (NSString)
 */
FOUNDATION_EXPORT SDWebImageContextOption _Nonnull const SDWebImageContextLottieResourcePath;

#pragma mark - Coder Options

/**
 * The asset resource path used for lottie animation to load bitmap images in the animation. If you don't provide this context option, use main bundle's resource path instead.
 * Defaults to nil, means main bundle's resource path. (NSString)
*/
FOUNDATION_EXPORT SDImageCoderOption _Nonnull const SDImageCoderDecodeLottieResourcePath;
