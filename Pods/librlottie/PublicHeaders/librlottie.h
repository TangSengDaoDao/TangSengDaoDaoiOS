
#import <Foundation/Foundation.h>

//! Project version number for librlottie.
FOUNDATION_EXPORT double librlottieVersionNumber;

//! Project version string for librlottie.
FOUNDATION_EXPORT const unsigned char librlottieVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <librlottie/PublicHeader.h>

#if __has_include(<librlottie/rlottie_capi.h>)
#import <librlottie/rlottie_capi.h>
#import <librlottie/rlottiecommon.h>
#else
#import "rlottie_capi.h"
#import "rlottiecommon.h"
#endif
