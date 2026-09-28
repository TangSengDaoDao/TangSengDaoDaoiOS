// Runs the production grouping/geometry code on macOS without a simulator or network.
#import "WKMessageAvatarLayout.h"
#include <assert.h>
#include <math.h>

static WKMessageAvatarItem *Item(NSString *identity, NSString *sender, NSUInteger section, BOOL eligible, BOOL breaksGroup) {
    WKMessageAvatarItem *item = [WKMessageAvatarItem new];
    item.messageID = identity;
    item.senderID = sender;
    item.section = section;
    item.eligible = eligible;
    item.breaksGroup = breaksGroup;
    return item;
}

static WKMessageAvatarGeometry *Geometry(NSUInteger index, CGFloat top, CGFloat bottom) {
    WKMessageAvatarGeometry *rect = [WKMessageAvatarGeometry new];
    rect.index = index;
    rect.row = CGRectMake(0, top, 320, bottom - top);
    rect.contentTop = top + 20;
    rect.avatarBottom = bottom - 14;
    rect.avatarLeft = 10;
    return rect;
}

static NSArray<WKMessageAvatarPlacement *> *Place(WKMessageAvatarLayout *layout,
        NSArray<WKMessageAvatarGeometry *> *geometry, CGFloat height, BOOL pinned) {
    return [layout placementsForGeometry:geometry viewport:CGRectMake(0, 0, 320, height)
                             avatarSize:CGSizeMake(40, 40) bottomGap:10 pinned:pinned];
}

static void Near(CGFloat actual, CGFloat expected) {
    assert(fabs(actual - expected) < 0.001);
}

int main(void) {
    @autoreleasepool {
        WKMessageAvatarLayout *layout = [WKMessageAvatarLayout new];
        NSArray *original = @[Item(@"a1", @"alice", 0, YES, YES), Item(@"a2", @"alice", 0, YES, YES),
                              Item(@"a3", @"alice", 0, YES, YES), Item(@"b1", @"bob", 0, YES, YES)];
        [layout updateItems:original];
        WKMessageAvatarGroup *alice = [layout groupAtIndex:0];
        assert(alice == [layout groupAtIndex:2] && alice.firstIndex == 0 && alice.lastIndex == 2);
        assert(alice != [layout groupAtIndex:3]);
        NSUInteger stableKey = alice.key;

        // The last cell is not instantiated: still show one avatar at the viewport bottom.
        NSArray *placements = Place(layout, @[Geometry(0, -200, 200), Geometry(1, 200, 800)], 600, YES);
        assert(placements.count == 1);
        Near(((WKMessageAvatarPlacement *)placements[0]).frame.origin.y, 550);

        // One exceptionally tall message must also pin before its bottom appears.
        [layout updateItems:@[Item(@"tall", @"alice", 0, YES, YES)]];
        Near(Place(layout, @[Geometry(0, -200, 1000)], 600, YES)[0].frame.origin.y, 550);
        [layout updateItems:original];

        // When the group tail enters the viewport, follow its bubble, excluding row padding.
        WKMessageAvatarGeometry *tail = Geometry(2, 300, 550);
        Near(Place(layout, @[tail], 600, YES)[0].frame.origin.y, 496);
        tail.avatarBottom = 506; // reactions below the bubble must not pull down the avatar
        Near(Place(layout, @[tail], 600, YES)[0].frame.origin.y, 466);

        // Keyboard/input resizing changes the pin boundary immediately.
        Near(Place(layout, @[Geometry(1, -100, 800)], 350, YES)[0].frame.origin.y, 300);

        // A new group enters from below; its avatar cannot jump above its first bubble.
        Near(Place(layout, @[Geometry(0, 570, 800)], 600, YES)[0].frame.origin.y, 590);
        assert(Place(layout, @[Geometry(0, 600, 800)], 600, YES).count == 0);
        assert(Place(layout, @[Geometry(2, -200, -10)], 600, YES).count == 0);

        // Multiple visible groups retain their own avatars; no single global sticky avatar.
        placements = Place(layout, @[Geometry(2, 100, 250), Geometry(3, 260, 900)], 600, YES);
        assert(placements.count == 2);
        Near(((WKMessageAvatarPlacement *)placements[0]).frame.origin.y, 196);
        Near(((WKMessageAvatarPlacement *)placements[1]).frame.origin.y, 550);

        // Selection mode uses the natural position, and preserves the checkbox's horizontal offset.
        assert(Place(layout, @[Geometry(1, 100, 800)], 600, NO).count == 0);
        tail = Geometry(2, 300, 550);
        tail.avatarLeft = 46;
        WKMessageAvatarPlacement *selected = Place(layout, @[tail], 600, NO)[0];
        Near(selected.frame.origin.y, 496);
        Near(selected.frame.origin.x, 46);

        // Prepending history and appending live messages must preserve an existing group's view identity.
        [layout updateItems:original];
        stableKey = [layout groupAtIndex:0].key;
        [layout updateItems:@[Item(@"a0", @"alice", 0, YES, YES), original[0], original[1], original[2],
                              Item(@"a4", @"alice", 0, YES, YES), original[3]]];
        assert([layout groupAtIndex:0].key == stableKey && [layout groupAtIndex:0].lastIndex == 4);
        // Deleting the oldest anchor still reuses the group through another surviving message.
        [layout updateItems:@[original[1], original[2], original[3]]];
        assert([layout groupAtIndex:0].key == stableKey);

        // An intervening sender splits the same person's messages into distinct groups/keys.
        [layout updateItems:@[original[0], original[3], original[1]]];
        assert([layout groupAtIndex:0].key != [layout groupAtIndex:2].key);
        // Removing that sender merges them back into one avatar.
        [layout updateItems:@[original[0], original[1]]];
        assert([layout groupAtIndex:0] == [layout groupAtIndex:1]);

        // Date boundaries and revoked/system/self rows terminate groups.
        [layout updateItems:@[original[0], Item(@"day2", @"alice", 1, YES, YES),
                              Item(@"system", @"", 1, NO, YES), Item(@"after", @"alice", 1, YES, YES)]];
        assert([layout groupAtIndex:0] != [layout groupAtIndex:1]);
        assert([layout groupAtIndex:1] != [layout groupAtIndex:3]);
        assert([layout groupAtIndex:2] == nil);
        // Optional loading/spacer rows may be transparent to grouping.
        [layout updateItems:@[original[0], Item(@"spacer", @"", 0, NO, NO), original[1]]];
        assert([layout groupAtIndex:0] == [layout groupAtIndex:2]);

        // Empty/missing message IDs must never reuse another sender's identity.
        [layout updateItems:@[Item(@"", @"alice", 0, YES, YES), Item(@"", @"bob", 0, YES, YES)]];
        assert([layout groupAtIndex:0].key != [layout groupAtIndex:1].key);
        NSUInteger old = [layout groupAtIndex:0].key;
        [layout updateItems:@[Item(@"", @"bob", 0, YES, YES)]];
        assert([layout groupAtIndex:0].key != old);
        [layout updateItems:@[]];
        assert(Place(layout, @[Geometry(0, 0, 100)], 600, YES).count == 0);
        assert(Place(layout, @[], 0, YES).count == 0);

        // Continuous scrolling: no jump when the tail crosses the pin boundary, in either direction.
        [layout updateItems:original];
        for (int offset = 0; offset <= 650; offset++) {
            NSArray *rects = @[Geometry(0, -offset, 300 - offset), Geometry(1, 300 - offset, 600 - offset),
                               Geometry(2, 600 - offset, 900 - offset)];
            CGFloat expected = MIN(846 - offset, 550);
            Near(Place(layout, rects, 600, YES)[0].frame.origin.y, expected);
        }
        puts("Avatar layout: grouping, reuse, pinning, clipping, selection and scrolling passed.");
    }
    return 0;
}
