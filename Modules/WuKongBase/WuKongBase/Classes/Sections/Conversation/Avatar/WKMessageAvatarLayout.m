#import "WKMessageAvatarLayout.h"

@implementation WKMessageAvatarItem
@end
@implementation WKMessageAvatarGroup
@end
@implementation WKMessageAvatarGeometry
@end
@implementation WKMessageAvatarPlacement
@end

@interface WKMessageAvatarLayout ()
@property(nonatomic,copy) NSDictionary<NSString *, WKMessageAvatarGroup *> *groupsByMessage;
@property(nonatomic,copy) NSDictionary<NSNumber *, WKMessageAvatarGroup *> *groupsByIndex;
@property(nonatomic,assign) NSUInteger nextKey;
@end

@implementation WKMessageAvatarLayout

- (void)updateItems:(NSArray<WKMessageAvatarItem *> *)items {
    NSMutableDictionary *byMessage = [NSMutableDictionary dictionary];
    NSMutableDictionary *byIndex = [NSMutableDictionary dictionary];
    NSMutableSet *usedKeys = [NSMutableSet set];
    NSMutableArray<WKMessageAvatarGroup *> *groups = [NSMutableArray array];
    WKMessageAvatarGroup *group = nil;
    NSUInteger section = NSNotFound;
    for (NSUInteger index = 0; index < items.count; index++) {
        WKMessageAvatarItem *item = items[index];
        if (item.section != section) group = nil;
        section = item.section;
        if (!item.eligible || item.senderID.length == 0) {
            if (item.breaksGroup) group = nil;
            continue;
        }
        if (!group || ![group.senderID isEqualToString:item.senderID]) {
            group = [WKMessageAvatarGroup new];
            group.senderID = item.senderID;
            group.firstIndex = index;
            [groups addObject:group];
        }
        group.lastIndex = index;
        WKMessageAvatarGroup *previous = item.messageID.length ? self.groupsByMessage[item.messageID] : nil;
        if (!group.key && previous && [previous.senderID isEqualToString:item.senderID]
            && ![usedKeys containsObject:@(previous.key)]) {
            group.key = previous.key;
            [usedKeys addObject:@(group.key)];
        }
        if (item.messageID.length) byMessage[item.messageID] = group;
        byIndex[@(index)] = group;
    }
    for (WKMessageAvatarGroup *value in groups) {
        if (!value.key) value.key = ++self.nextKey;
    }
    self.groupsByMessage = byMessage;
    self.groupsByIndex = byIndex;
}

- (WKMessageAvatarGroup *)groupAtIndex:(NSUInteger)index {
    return self.groupsByIndex[@(index)];
}

- (NSArray<WKMessageAvatarPlacement *> *)placementsForGeometry:(NSArray<WKMessageAvatarGeometry *> *)geometry
                                                    viewport:(CGRect)viewport
                                                  avatarSize:(CGSize)size
                                                   bottomGap:(CGFloat)gap
                                                      pinned:(BOOL)pinned {
    if (CGRectIsEmpty(viewport) || size.width <= 0 || size.height <= 0) return @[];
    NSMutableDictionary<NSNumber *, WKMessageAvatarGeometry *> *measured = [NSMutableDictionary dictionary];
    NSMutableOrderedSet<WKMessageAvatarGroup *> *visible = [NSMutableOrderedSet orderedSet];
    NSMutableDictionary<NSNumber *, NSNumber *> *leftByGroup = [NSMutableDictionary dictionary];
    for (WKMessageAvatarGeometry *rect in geometry) {
        if (CGRectIsEmpty(rect.row)) continue;
        measured[@(rect.index)] = rect;
        WKMessageAvatarGroup *group = [self groupAtIndex:rect.index];
        if (group && CGRectIntersectsRect(rect.row, viewport)) {
            [visible addObject:group];
            leftByGroup[@(group.key)] = @(rect.avatarLeft);
        }
    }
    NSMutableArray *placements = [NSMutableArray array];
    for (WKMessageAvatarGroup *group in visible) {
        WKMessageAvatarGeometry *first = measured[@(group.firstIndex)];
        WKMessageAvatarGeometry *last = measured[@(group.lastIndex)];
        if (!pinned && !last) continue;
        CGFloat naturalTop = last ? last.avatarBottom - size.height : CGFLOAT_MAX;
        CGFloat top = pinned ? MIN(naturalTop, CGRectGetMaxY(viewport) - size.height - gap) : naturalTop;
        // A group entering from below must bring its avatar with it, not draw over the preceding group.
        if (pinned && first) top = MIN(naturalTop, MAX(top, first.contentTop));
        if (top >= CGRectGetMaxY(viewport) || top + size.height <= CGRectGetMinY(viewport)) continue;
        WKMessageAvatarPlacement *placement = [WKMessageAvatarPlacement new];
        placement.group = group;
        placement.frame = CGRectMake(last ? last.avatarLeft : leftByGroup[@(group.key)].doubleValue,
                                     top, size.width, size.height);
        [placements addObject:placement];
    }
    return placements;
}
@end
