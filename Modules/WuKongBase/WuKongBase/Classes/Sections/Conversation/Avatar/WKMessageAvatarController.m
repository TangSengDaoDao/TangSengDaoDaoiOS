#import "WKMessageAvatarController.h"
#import "WKMessageAvatarLayout.h"
#import "WKMessageListView.h"
#import "WKMessageCell.h"
#import "WKAvatarUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>

// Inside the table view so its pan recognizer also receives drags that start on an avatar.
// Empty areas pass through to cells, section headers and the scroll indicators.
@interface WKMessageAvatarLayer : UIView
@end
@implementation WKMessageAvatarLayer
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    return hit == self ? nil : hit;
}
@end

@interface WKMessageAvatarNode : WKUserAvatar
@property(nonatomic,strong) WKMessageModel *message;
@property(nonatomic,copy) NSString *sourceSignature;
@end
@implementation WKMessageAvatarNode
@end

@interface WKMessageAvatarController ()
@property(nonatomic,weak) WKMessageListView *messageListView;
@property(nonatomic,strong) WKMessageAvatarLayer *layer;
@property(nonatomic,strong) WKMessageAvatarLayout *layout;
@property(nonatomic,strong) NSMutableDictionary<NSNumber *, WKMessageAvatarNode *> *nodes;
@property(nonatomic,copy) NSArray<WKMessageModel *> *messages;
@property(nonatomic,copy) NSDictionary<NSIndexPath *, NSNumber *> *indices;
@property(nonatomic,assign) BOOL dataDirty;
@property(nonatomic,assign) BOOL updating;
@end

@implementation WKMessageAvatarController

- (instancetype)initWithMessageListView:(WKMessageListView *)messageListView {
    if ((self = [super init])) {
        _messageListView = messageListView;
        _layout = [WKMessageAvatarLayout new];
        _nodes = [NSMutableDictionary dictionary];
        _layer = [WKMessageAvatarLayer new];
        _layer.clipsToBounds = YES;
        [messageListView.tableView addSubview:_layer];
        _dataDirty = YES;
    }
    return self;
}

- (void)invalidateData {
    self.dataDirty = YES;
    [self.messageListView.tableView setNeedsLayout];
}

- (void)updateSender:(WKChannelInfo *)channelInfo {
    if (channelInfo.channel.channelType != WK_PERSON) return;
    for (WKMessageModel *message in self.messages) {
        if ([message.fromUid isEqualToString:channelInfo.channel.channelId]) message.from = channelInfo;
    }
    [self.messageListView.tableView setNeedsLayout];
}

- (void)setMultipleChoice:(BOOL)multipleChoice {
    _multipleChoice = multipleChoice;
    self.layer.userInteractionEnabled = !multipleChoice;
    self.layer.accessibilityElementsHidden = multipleChoice;
    // Disabling cancels any press that began before entering selection mode.
    for (WKMessageAvatarNode *node in self.nodes.allValues) {
        for (UIGestureRecognizer *gesture in node.gestureRecognizers) gesture.enabled = !multipleChoice;
    }
    [self.messageListView.tableView setNeedsLayout];
}

- (void)rebuildGroups {
    id<WKMessageListDataProvider> provider = self.messageListView.dataProvider;
    NSMutableArray *messages = [NSMutableArray array];
    NSMutableArray *items = [NSMutableArray array];
    NSMutableDictionary *indices = [NSMutableDictionary dictionary];
    for (NSInteger section = 0; section < provider.dateCount; section++) {
        NSArray<WKMessageModel *> *rows = [provider messagesAtSection:section];
        for (NSUInteger row = 0; row < rows.count; row++) {
            WKMessageModel *message = rows[row];
            WKMessageAvatarItem *item = [WKMessageAvatarItem new];
            item.messageID = message.clientMsgNo ?: @"";
            item.senderID = message.fromUid ?: @"";
            item.section = section;
            Class cellClass = [[WKApp shared].messageRegitry getMessageCell:message.contentType];
            item.eligible = [cellClass isSubclassOfClass:WKMessageCell.class]
                && [WKMessageCell showsSenderAvatarForMessage:message];
            item.breaksGroup = YES;
            indices[[NSIndexPath indexPathForRow:row inSection:section]] = @(messages.count);
            [messages addObject:message];
            [items addObject:item];
        }
    }
    [self.layout updateItems:items];
    self.messages = messages;
    self.indices = indices;
    self.dataDirty = NO;
}

- (void)updateLayout {
    if (self.updating) return;
    self.updating = YES;
    WKMessageListView *list = self.messageListView;
    UITableView *table = list.tableView;
    if (self.dataDirty) [self rebuildGroups];
    // The table is shifted above the input/keyboard by adjustTableWithOffset:.
    // Intersect in the table's coordinate space, including the host's top clipping.
    CGRect viewport = CGRectIntersection(table.bounds, [list convertRect:list.bounds toView:table]);
    if (CGRectIsNull(viewport)) viewport = CGRectZero;
    self.layer.frame = viewport;
    if (table.subviews.lastObject != self.layer) [table bringSubviewToFront:self.layer];
    NSMutableArray *geometry = [NSMutableArray array];
    for (UITableViewCell *baseCell in table.visibleCells) {
        if (![baseCell isKindOfClass:WKMessageCell.class]) continue;
        WKMessageCell *cell = (WKMessageCell *)baseCell;
        cell.avatarManagedByList = YES;
        NSIndexPath *indexPath = [table indexPathForCell:cell];
        NSNumber *index = indexPath ? self.indices[indexPath] : nil;
        if (!index || index.unsignedIntegerValue >= self.messages.count) continue;
        // An animated deletion/reload may briefly leave an outgoing cell at the same index path.
        if (cell.messageModel != self.messages[index.unsignedIntegerValue]) continue;
        if (![self.layout groupAtIndex:index.unsignedIntegerValue]) continue;
        [cell layoutIfNeeded];
        WKMessageAvatarGeometry *rect = [WKMessageAvatarGeometry new];
        rect.index = index.unsignedIntegerValue;
        rect.row = [cell convertRect:cell.bounds toView:self.layer];
        CGRect bubble = [cell.bubbleBackgroundView convertRect:cell.bubbleBackgroundView.bounds toView:self.layer];
        CGRect avatar = [cell.avatarImgView convertRect:cell.avatarImgView.bounds toView:self.layer];
        rect.contentTop = CGRectGetMinY(bubble);
        rect.avatarBottom = CGRectGetMaxY(bubble);
        rect.avatarLeft = CGRectGetMinX(avatar);
        [geometry addObject:rect];
    }
    NSArray<WKMessageAvatarPlacement *> *placements = [self.layout placementsForGeometry:geometry
        viewport:self.layer.bounds avatarSize:[WKApp shared].config.messageAvatarSize bottomGap:10.0f pinned:!self.multipleChoice];
    NSMutableSet *retained = [NSMutableSet set];
    for (WKMessageAvatarPlacement *placement in placements) {
        NSNumber *key = @(placement.group.key);
        WKMessageAvatarNode *node = self.nodes[key];
        if (!node) {
            node = [[WKMessageAvatarNode alloc] initWithFrame:placement.frame];
            node.isAccessibilityElement = YES;
            node.accessibilityTraits = UIAccessibilityTraitButton;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTapped:)];
            UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(avatarLongPressed:)];
            [tap requireGestureRecognizerToFail:press];
            [node addGestureRecognizer:tap];
            [node addGestureRecognizer:press];
            [self.layer addSubview:node];
            self.nodes[key] = node;
        }
        node.frame = placement.frame;
        WKMessageModel *message = self.messages[placement.group.lastIndex];
        node.message = message;
        NSString *url = message.from.logo.length ? [WKAvatarUtil getFullAvatarWIthPath:message.from.logo] : @"";
        NSString *signature = [NSString stringWithFormat:@"%@\n%@", message.fromUid, url];
        if (![node.sourceSignature isEqualToString:signature]) {
            node.sourceSignature = signature;
            node.url = url;
        }
        node.accessibilityLabel = [WKMessageCell getFromName:message];
        [retained addObject:key];
    }
    for (NSNumber *key in self.nodes.allKeys) {
        if (![retained containsObject:key]) {
            WKMessageAvatarNode *node = self.nodes[key];
            [node.avatarImgView sd_cancelCurrentImageLoad];
            [node removeFromSuperview];
            [self.nodes removeObjectForKey:key];
        }
    }
    self.updating = NO;
}

- (BOOL)canInteractWithNode:(WKMessageAvatarNode *)node {
    return !self.multipleChoice && !self.dataDirty && node.superview == self.layer
        && !self.messageListView.tableView.dragging && !self.messageListView.tableView.decelerating;
}

- (void)avatarTapped:(UITapGestureRecognizer *)gesture {
    WKMessageAvatarNode *node = (WKMessageAvatarNode *)gesture.view;
    if ([self canInteractWithNode:node]) [WKMessageCell openSenderInfoForMessage:node.message];
}

- (void)avatarLongPressed:(UILongPressGestureRecognizer *)gesture {
    WKMessageAvatarNode *node = (WKMessageAvatarNode *)gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan && [self canInteractWithNode:node]) {
        [[self.messageListView.dataProvider conversationContext] addMention:node.message.fromUid];
    }
}

- (void)dealloc {
    for (WKMessageAvatarNode *node in _nodes.allValues) [node.avatarImgView sd_cancelCurrentImageLoad];
    [_layer removeFromSuperview];
}
@end
