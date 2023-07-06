//
//  WKDeleteAccountTitleCell.h
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import <UIKit/UIKit.h>
#import "WKFormItemCell.h"
#import "WKFormItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WKDeleteAccountTitleCellModel : WKFormItemModel

@property(nonatomic,copy) NSString *title;

@property(nonatomic,copy) NSString *value;

@property(nonatomic,assign) CGFloat fontSize;

@end

@interface WKDeleteAccountTitleCell : WKFormItemCell

@end

NS_ASSUME_NONNULL_END
