//
//  WKSearchMessageCell.h
//  WuKongBase
//
//  Created by tt on 2020/5/10.
//

#import "WKFormItemCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKSearchMessageModel : WKFormItemModel

@property(nonatomic,copy) NSString *avatar; // 头像
@property(nonatomic,copy) NSString *name;
@property(nonatomic,assign) NSNumber *messageCount; // 消息数量
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *keyword;


@end

@interface WKSearchMessageCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
