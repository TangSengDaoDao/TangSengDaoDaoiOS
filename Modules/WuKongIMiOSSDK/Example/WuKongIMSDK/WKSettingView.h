//
//  WKSettingView.h
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKSettingView : UIView

@property(nonatomic,copy) void(^onChannelSelct)(WKChannel*channel);

@property(nonatomic,assign,readonly) BOOL isShow;

@property(nonatomic,strong) WKChannel *defaultChannel;

-(void) show;

-(void) hide;

@end

NS_ASSUME_NONNULL_END
