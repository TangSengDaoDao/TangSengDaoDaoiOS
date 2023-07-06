//
//  WKDeleteAccountTipCell.h
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKFormItemCell.h"
#import "WKFormItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKDeleteAccountTipCellModel : WKFormItemModel

@property(nonatomic,copy) NSString *tip;
@property(nonatomic,assign) CGFloat fontSize;

@end

@interface WKDeleteAccountTipCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
