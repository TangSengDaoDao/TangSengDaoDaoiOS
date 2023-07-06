//
//  WKChatBackupVM.h
//  WuKongBase
//
//  Created by tt on 2023/2/3.
//

#import <WuKongBase/WuKongBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKChatBackupVM : WKBaseTableVM

-(AnyPromise*) bakcupMessages;

@end

NS_ASSUME_NONNULL_END
