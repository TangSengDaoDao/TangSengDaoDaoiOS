//
//  WKTextCell.h
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/24.
//  Copyright © 2023 3895878. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WuKongIMSDK/WuKongIMSDK.h>
NS_ASSUME_NONNULL_BEGIN

@interface WKTextCell : UITableViewCell

@property(nonatomic,strong) UILabel *contentLbl;
@property(nonatomic,strong) UIView *bubbleView;

+(CGSize) sizeForMessage:(WKMessage*)message;

-(void) refresh:(WKMessage*)message;

@end

NS_ASSUME_NONNULL_END
