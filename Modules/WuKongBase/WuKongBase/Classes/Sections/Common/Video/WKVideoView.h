//
//  YBIBVideoView.h
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/11.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "WKVideoActionBar.h"
#import "WKVideoTopBar.h"

NS_ASSUME_NONNULL_BEGIN

@class WKVideoView;

@protocol WKVideoViewDelegate <NSObject>
@required

- (BOOL)yb_isFreezingForVideoView:(WKVideoView *)view;

- (void)yb_preparePlayForVideoView:(WKVideoView *)view;

- (void)yb_startPlayForVideoView:(WKVideoView *)view;

- (void)yb_finishPlayForVideoView:(WKVideoView *)view;

- (void)yb_didPlayToEndTimeForVideoView:(WKVideoView *)view;

- (void)yb_playFailedForVideoView:(WKVideoView *)view;

- (void)yb_respondsToTapGestureForVideoView:(WKVideoView *)view;

- (void)yb_cancelledForVideoView:(WKVideoView *)view;

- (CGSize)yb_containerSizeForVideoView:(WKVideoView *)view;

- (void)yb_autoPlayCountChanged:(NSUInteger)count;

@end

@interface WKVideoView : UIView

@property (nonatomic, strong) UIImageView *thumbImageView;

@property (nonatomic, weak) id<WKVideoViewDelegate> delegate;

- (void)updateLayoutWithExpectOrientation:(UIDeviceOrientation)orientation containerSize:(CGSize)containerSize;

@property (nonatomic, strong, nullable) AVAsset *asset;

@property (nonatomic, assign, readonly, getter=isPlaying) BOOL playing;

@property (nonatomic, assign, readonly, getter=isPlayFailed) BOOL playFailed;

@property (nonatomic, assign, readonly, getter=isPreparingPlay) BOOL preparingPlay;

@property (nonatomic, strong, readonly) UITapGestureRecognizer *tapGesture;

- (void)reset;

- (void)hideToolBar:(BOOL)hide;

- (void)hidePlayButton;

- (void)preparPlay;

@property (nonatomic, assign) BOOL needAutoPlay;

@property (nonatomic, assign) NSUInteger autoPlayCount;

@property (nonatomic, strong, readonly) WKVideoTopBar *topBar;
@property (nonatomic, strong, readonly) WKVideoActionBar *actionBar;


@end

NS_ASSUME_NONNULL_END
