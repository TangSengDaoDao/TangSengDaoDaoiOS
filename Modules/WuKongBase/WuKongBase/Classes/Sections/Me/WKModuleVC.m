//
//  WKModuleVC.m
//  WuKongBase
//
//  Created by tt on 2023/2/23.
//

#import "WKModuleVC.h"

@interface WKModuleVC ()

@end

@implementation WKModuleVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKModuleVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LLang(@"功能模块");
   
}


@end
