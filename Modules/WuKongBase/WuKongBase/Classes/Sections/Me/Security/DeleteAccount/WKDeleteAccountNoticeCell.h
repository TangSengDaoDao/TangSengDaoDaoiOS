//
//  WKDeleteAccountNoticeCell.h
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKFormItemCell.h"
#import "WKFormItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    WKDeleteAccountNoticeNumStyleBadge,
    WKDeleteAccountNoticeNumStyleNum,
} WKDeleteAccountNoticeNumStyle;

@interface WKDeleteAccountNoticeCellModel:WKFormItemModel

@property(nonatomic,assign) NSInteger num;

@property(nonatomic,copy) NSString *value;

@property(nonatomic,assign) WKDeleteAccountNoticeNumStyle style;

@property(nonatomic,assign) NSInteger fontSize;

@end

@interface WKDeleteAccountNoticeCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
