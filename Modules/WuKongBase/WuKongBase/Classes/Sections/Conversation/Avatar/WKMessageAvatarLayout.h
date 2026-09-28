#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

// Independent of cells: a group's last row may be outside the reuse window.
@interface WKMessageAvatarItem : NSObject
@property(nonatomic,copy) NSString *messageID;
@property(nonatomic,copy) NSString *senderID;
@property(nonatomic,assign) NSUInteger section;
@property(nonatomic,assign) BOOL eligible;
@property(nonatomic,assign) BOOL breaksGroup;
@end

@interface WKMessageAvatarGroup : NSObject
@property(nonatomic,assign) NSUInteger key;
@property(nonatomic,copy) NSString *senderID;
@property(nonatomic,assign) NSUInteger firstIndex;
@property(nonatomic,assign) NSUInteger lastIndex;
@end

@interface WKMessageAvatarGeometry : NSObject
@property(nonatomic,assign) NSUInteger index;
@property(nonatomic,assign) CGRect row;
@property(nonatomic,assign) CGFloat contentTop;
@property(nonatomic,assign) CGFloat avatarBottom;
@property(nonatomic,assign) CGFloat avatarLeft;
@end

@interface WKMessageAvatarPlacement : NSObject
@property(nonatomic,strong) WKMessageAvatarGroup *group;
@property(nonatomic,assign) CGRect frame;
@end

@interface WKMessageAvatarLayout : NSObject
- (void)updateItems:(NSArray<WKMessageAvatarItem *> *)items;
- (nullable WKMessageAvatarGroup *)groupAtIndex:(NSUInteger)index;
- (NSArray<WKMessageAvatarPlacement *> *)placementsForGeometry:(NSArray<WKMessageAvatarGeometry *> *)geometry
                                                    viewport:(CGRect)viewport
                                                  avatarSize:(CGSize)size
                                                   bottomGap:(CGFloat)gap
                                                      pinned:(BOOL)pinned;
@end

NS_ASSUME_NONNULL_END
