//
//  WKSyncService.m
//  WuKongBase
//
//  Created by tt on 2019/12/7.
//

#import "WKSyncService.h"
#import "UIView+WKCommon.h"
#import "WKApp.h"
#import "WKConstant.h"
#import "WKSync.h"
@implementation WKSyncService

static WKSyncService *_instance = nil;
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone ];
    });
    return _instance;
}

+(instancetype) shared{
    if (_instance == nil) {
        _instance = [[super alloc]init];
    }
    return _instance;
}

-(void) sync {
    [self sync:nil];
}

- (void)sync:(void (^)(NSError *))callback {
    MBProgressHUD *hub = [[self rootViewController].view showHUDWithDim];
       hub.hidden = YES;
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           
           NSArray<id<WKSync>> *syncServices = [[WKApp shared] invokes:WKPOINT_CATEGORY_SYNC param:nil];
           if(syncServices) {
               dispatch_semaphore_t sema = dispatch_semaphore_create(0);
               for (id<WKSync> syncService in syncServices) {
                   if([syncService needSync]) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if(syncService.title) {
                               hub.hidden = NO;
                               hub.label.text = syncService.title;
                           }
                          
                       });
                       
                       [syncService sync:^(NSError *error) {
                           dispatch_semaphore_signal(sema);
                       }];
                   }
               }
               dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
               
           }
           dispatch_async(dispatch_get_main_queue(), ^{
               
               [hub hideAnimated:YES];
               if(callback) {
                   callback(nil);
               }
           });
       });
}

-(void) syncContacts:(void (^)(NSError  * __nullable error))callback {
   id<WKSync> syncService = [WKApp.shared invoke:WKPOINT_SYNC_CONTACTS param:nil];
    if(syncService) {
        [syncService sync:callback];
    }
}

-(UIViewController*) rootViewController{
    return  [[UIApplication sharedApplication].delegate window].rootViewController;
}

@end
