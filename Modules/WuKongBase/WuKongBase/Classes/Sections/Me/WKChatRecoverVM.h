//
//  WKChatRecoverVM.h
//  WuKongBase
//
//  Created by tt on 2023/2/3.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKChatRecoverVM : WKBaseTableVM

-(AnyPromise*) recoverMessages;

@end

NS_ASSUME_NONNULL_END
