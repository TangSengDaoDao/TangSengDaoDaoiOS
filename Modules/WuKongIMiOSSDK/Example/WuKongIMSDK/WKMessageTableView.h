//
//  WKMessageTableView.h
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WuKongIMSDK/WuKongIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKMessageTableView : UIView

@property(nonatomic,strong) WKChannel *channel;

-(void) reload;

-(void) sendMessageUI:(WKMessage*)message;

@end



NS_ASSUME_NONNULL_END
