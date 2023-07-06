# SDWebImageLottieCoder

[![CI Status](https://img.shields.io/travis/SDWebImage/SDWebImageLottieCoder.svg?style=flat)](https://travis-ci.org/SDWebImage/SDWebImageLottieCoder)
[![Version](https://img.shields.io/cocoapods/v/SDWebImageLottieCoder.svg?style=flat)](https://cocoapods.org/pods/SDWebImageLottieCoder)
[![License](https://img.shields.io/cocoapods/l/SDWebImageLottieCoder.svg?style=flat)](https://cocoapods.org/pods/SDWebImageLottieCoder)
[![Platform](https://img.shields.io/cocoapods/p/SDWebImageLottieCoder.svg?style=flat)](https://cocoapods.org/pods/SDWebImageLottieCoder)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SDWebImage/SDWebImageLottieCoder)

## What's for

This is a coder plugin for [Lottie Animation format](https://airbnb.design/lottie/).

## Differences

We've already built one Lottie plugin, called [SDWebImageLottiePlugin](https://github.com/SDWebImage/SDWebImageLottiePlugin).

The main difference for these two components, it's `How we play animation`, and `What dependency we use`. In order to reduce the code size for unnecessary dependency, we separate these into 2 different repos.

### SDWebImageLottiePlugin

This lottie framework dependent [lottie-ios](https://github.com/airbnb/lottie-ios), which is maintained by Airbnb.

This plugin can only play animation by using their own `LOTAnimationView`.

+ Pros: It use vector rendering technology like Core Animation Layer, which means you can change your view dynamic size without lossing details or regenerate images.

+ Cons: Vector rendering is much slower than bitmap rendering. For small and massive lottie images, like emojis, small icons, this is not suitable.

### SDWebImageLottieCoder

This lottie framework dependent [rlottie](https://github.com/Samsung/rlottie), which is maintained by Samsung.

This plugin can play animation on both [SDAnimatedImageView](https://github.com/SDWebImage/SDWebImage/wiki/Advanced-Usage#animated-image-50) and `UIImageView/NSImageView`.

+ Pros: It use bitmap rendering, each animation frame are rendered into the rasterized bitmap, not vector images. You can also preload all frames into memory, to get the best performance and 60FPS. This is also easy to integrate to UIKit/AppKit native framework.

+ Cons: Bitmap rendering does not support dynamic size changes. Once you want larger images, you need re-decoding the source lottie JSON, which is time-consuming and RAM consuming.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

+ iOS 9
+ macOS 10.10
+ tvOS 9.0
+ watchOS 2.0

## Installation

#### CocoaPods
SDWebImageLottieCoder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageLottieCoder'
```

#### Carthage

SDWebImageLottieCoder is available through [Carthage](https://github.com/Carthage/Carthage).

```
github "SDWebImage/SDWebImageLottieCoder"
```

#### Swift Package Manager (Xcode 11+)

SDWebImageLottieCoder is available through [Swift Package Manager](https://swift.org/package-manager).

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageLottieCoder.git", from: "0.1")
    ]
)
```

SDWebImageLottieCoder is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SDWebImageLottieCoder'
```

## Usage

### Add Coder

Before using SDWebImage to load Lottie json, you need to register the Lottie Coder to your coders manager. This step is recommended to be done after your App launch (like AppDelegate method).

+ Objective-C

```objective-c
// Add coder
SDImageLottieCoder *lottieCoder = [SDImageLottieCoder sharedCoder];
[[SDImageCodersManager sharedManager] addCoder:lottieCoder];
```

+ Swift

```swift
// Add coder
let lottieCoder = SDImageLottieCoder.shared
SDImageCodersManager.shared.addCoder(lottieCoder)
```

### Loading

+ Objective-C

```objective-c
// Lottie json loading
NSURL *lottieURL;
UIImageView *imageView;
[imageView sd_setImageWithURL:lottieURL];
```

+ Swift

```swift
// Lottie json loading
let lottieURL: URL
let imageView: UIImageView
imageView.sd_setImage(with: lottieURL)
```

### Animation and Size

+ Objective-C

```objective-c
// Lottie json loading on animated image view
NSURL *lottieURL;
SDAnimatedImageView *imageView;
CGSize pixelSize = CGSizeMake(300, 300);
[imageView sd_setImageWithURL:lottieURL placeholderImage:nil options:0 context:@{SDWebImageThumbnailPixelSize:@(pixelSize)}];
```

+ Swift

```swift
// Lottie json loading on animated image view
let lottieURL: URL
let imageView: SDAnimatedImageView
let pixelSize = CGSize(width: 300, height: 300)
imageView.sd_setImage(with: lottieURL, placeholderImage: nil, options: [], contrext: [.thumbnailPixelSize : pixelSize])
```

### Decoding

You can decode lottie image into aniamted UIImage/NSImage as well. If the lottie images have [referenced external image resource](https://airbnb.io/lottie/#/supported-features), you can specify it as well.

+ Objective-C

```objective-c
// Lottie image decoding
NSData *lottieJSONData;
NSBundle *imageBundle; // You can even download the external image from online to local path, then load the lottie animation
UIImage *image = [[SDImageLottieCoder sharedCoder] decodedImageWithData:lottieJSONData options:@{SDImageCoderDecodeLottieResourcePath : imageBundle.resourcePath}];
```

+ Swift

```swift
// Lottie image decoding
let lottieJSONData: Data
let imageBundle: Bundle // You can even download the external image from online to local path, then load the lottie animation
let image = SDImageWebPCoder.shared.decodedImage(with: lottieJSONData, options: [.lottieResourcePath : imageBundle.resourcePath])
```

## Screenshot

<img src="https://raw.githubusercontent.com/SDWebImage/SDWebImageLottieCoder/master/Example/Screenshot/LottieDemo.gif" width="300" />

These Lottie animation stickers are from [lottiefiles-telegram](https://lottiefiles.com/animated-stickers/animated-contest-4-at-tgsticker)

## Author

DreamPiggy, lizhuoli1126@126.com

## License

SDWebImageLottieCoder is available under the MIT license. See the LICENSE file for more info.

## Thanks

+ [rlottie](https://github.com/Samsung/rlottie)