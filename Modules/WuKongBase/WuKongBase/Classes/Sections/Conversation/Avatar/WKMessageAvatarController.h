#import <UIKit/UIKit.h>
@class WKMessageListView;
@class WKChannelInfo;

NS_ASSUME_NONNULL_BEGIN

@interface WKMessageAvatarController : NSObject
@property(nonatomic,assign) BOOL multipleChoice;
- (instancetype)initWithMessageListView:(WKMessageListView *)messageListView;
- (void)invalidateData;
- (void)updateSender:(WKChannelInfo *)channelInfo;
- (void)updateLayout;
@end

NS_ASSUME_NONNULL_END
