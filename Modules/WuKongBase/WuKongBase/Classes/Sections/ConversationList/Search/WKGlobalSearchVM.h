//
//  WKGlobalSearchVM.h
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//

#import "WKBaseVM.h"
#import "WKFormSection.h"
#import "WKConstant.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKGlobalSearchVM : WKBaseVM

@property(nonatomic,assign) WKHistoryMessageSearchType searchType;

-(void) search:(NSString*)text callback:(void(^_Nullable)(NSArray<WKFormSection*>*items))callback;

@end

NS_ASSUME_NONNULL_END
