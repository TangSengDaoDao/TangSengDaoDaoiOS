//
//  WKConversationTableView.m
//  WuKongBase
//
//  Created by tt on 2019/12/15.
//

#import "WKConversationTableView.h"
#import "UIView+WK.h"
#import "WKConstant.h"

@interface WKConversationTableView ()

@property(nonatomic,strong) UIEvent *beganEvent;

@end

@implementation WKConversationTableView

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.conversationTableDelegate respondsToSelector:@selector(tableViewDidLayoutMessages:)]) {
        [self.conversationTableDelegate tableViewDidLayoutMessages:self];
    }
}

- (void)messagesWillChange {
    if ([self.conversationTableDelegate respondsToSelector:@selector(tableViewMessagesDidChange:)]) {
        [self.conversationTableDelegate tableViewMessagesDidChange:self];
    }
}

- (void)reloadData {
    [self messagesWillChange];
    [super reloadData];
}

- (void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath {
    [self messagesWillChange];
    [super moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super reloadSections:sections withRowAnimation:animation];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super insertSections:sections withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    [self messagesWillChange];
    [super deleteSections:sections withRowAnimation:animation];
}

- (void)moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    [self messagesWillChange];
    [super moveSection:section toSection:newSection];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
       // [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)]];
    }
    return self;
}

-(void) didTap:(UITapGestureRecognizer*)gesture {
    if ([_conversationTableDelegate conformsToProtocol:@protocol(WKConversationTableViewDelegate)] &&
        [_conversationTableDelegate respondsToSelector:@selector(tableView:touchesTime:)]){
        [_conversationTableDelegate tableView:self touchesTime:1.0f];
    }
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    self.beganEvent = event;
    if ([_conversationTableDelegate conformsToProtocol:@protocol(WKConversationTableViewDelegate)] &&
        [_conversationTableDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]){
        [_conversationTableDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if ([_conversationTableDelegate conformsToProtocol:@protocol(WKConversationTableViewDelegate)] &&
        [_conversationTableDelegate respondsToSelector:@selector(tableView:touchesEnd:withEvent:)]){
        [_conversationTableDelegate tableView:self touchesEnd:touches withEvent:event];
    }
    CGFloat btwTime = event.timestamp -  self.beganEvent.timestamp;
    if ([_conversationTableDelegate conformsToProtocol:@protocol(WKConversationTableViewDelegate)] &&
        [_conversationTableDelegate respondsToSelector:@selector(tableView:touchesTime:)]){
        [_conversationTableDelegate tableView:self touchesTime:btwTime];
    }
}

@end
