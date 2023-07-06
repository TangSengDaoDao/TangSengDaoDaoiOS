//
//  WKSecuritySettingVC.m
//  WuKongBase
//
//  Created by tt on 2020/6/21.
//

#import "WKSecuritySettingVC.h"
#import "WKSecuritySettingVM.h"
@interface WKSecuritySettingVC ()

@end

@implementation WKSecuritySettingVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKSecuritySettingVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)langTitle {
    return LLang(@"安全与隐私");
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
}

@end
