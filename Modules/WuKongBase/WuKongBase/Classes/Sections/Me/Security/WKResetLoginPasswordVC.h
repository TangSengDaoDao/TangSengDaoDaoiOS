//
//  WKForgetPasswordVC.h
//  WuKongLogin
//
//  Created by tt on 2020/10/27.
//

#import <WuKongBase/WuKongBase.h>
#import "WKResetLoginPasswordVM.h"
NS_ASSUME_NONNULL_BEGIN

@interface WKResetLoginPasswordVC : WKBaseVC<WKResetLoginPasswordVM*>

@property(nonatomic,strong) NSString *country;
@property(nonatomic,copy) NSString *mobile;


@end

NS_ASSUME_NONNULL_END
