#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "librlottie.h"
#import "LottieInstance.h"
#import "rlottie_capi.h"
#import "rlottiecommon.h"

FOUNDATION_EXPORT double librlottieVersionNumber;
FOUNDATION_EXPORT const unsigned char librlottieVersionString[];

