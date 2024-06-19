//
//  WKMessageTableView.m
//  WuKongIMSDK_Example
//
//  Created by tt on 2023/5/23.
//  Copyright © 2023 3895878. All rights reserved.
//

#import "WKMessageTableView.h"
#import <WuKongIMSDK/WuKongIMSDK.h>
#import "WKTextCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>


@interface WKMessageTableView ()<WKChatManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *tableView;

@property(nonatomic,strong) NSMutableArray<WKMessage*> *items;

@end

@implementation WKMessageTableView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if(self) {
        [self addSubview:self.tableView];
        
        [WKSDK.shared.chatManager addDelegate:self];
    }
    return self;
}

-(void) sendMessageUI:(WKMessage*)message {
    [self.items addObject:message];
    [self.tableView reloadData];
    [self scrollToBttom];
}

- (void)reload {
    [self.items removeAllObjects];
    [self.tableView reloadData];
    if(!self.channel) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    __weak typeof(self) weakSelf = self;
    
    [WKSDK.shared.chatManager pullLastMessages:self.channel limit:15  complete:^(NSArray<WKMessage *> * _Nonnull messages, NSError * _Nonnull error) {
        if(error) {
            NSLog(@"加载消息失败！->%@",error);
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"加载消息失败！";
            [hud hideAnimated:YES afterDelay:1.0f];
            return;
        }
        [hud hideAnimated:YES];
        [weakSelf.items addObjectsFromArray:messages];
        [weakSelf.tableView reloadData];
        [weakSelf scrollToBttom];
    }];
}

-(void) scrollToBttom {
    if(self.items.count == 0) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.items.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark -- WKChatManagerDelegate

- (void)onRecvMessages:(WKMessage*)message left:(NSInteger)left {
    if(self.channel && [self.channel isEqual:message.channel]) {
        [self.items addObject:message];
        [self.tableView reloadData];
        [self scrollToBttom];

    }
}

#pragma mark -- UITableViewDelegate & UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WKMessage *message = self.items[indexPath.row];
    NSString *identifier = NSStringFromClass(WKTextCell.class);
    WKTextCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    [cell refresh:message];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    WKMessage *message = self.items[indexPath.row];
    CGSize size = [WKTextCell.class sizeForMessage:message];
    return MAX(size.height, 0.1f);
}


#pragma mark -- other

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor blueColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView setTableFooterView:[UIView new]];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        [_tableView registerClass:WKTextCell.class forCellReuseIdentifier:@"WKTextCell"];
        
        __weak typeof(self) weakSelf = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf pulldown];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        header.stateLabel.hidden = YES;
        header.arrowView.alpha = 0.0f;
        CGRect headrFrame = header.frame;
        headrFrame.size.height = 30.0f;
        header.frame = headrFrame;
        _tableView.mj_header =  header;
       
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf pullup];
        }];
        footer.refreshingTitleHidden = YES;
        footer.stateLabel.hidden  = YES;
        _tableView.mj_footer = footer;
        _tableView.mj_footer.hidden = YES;
//        _tableView.contentInset = UIEdgeInsetsMake(0.01f, 0, 0, 0); // TODO: 这里要整个0.01
//        _tableView.scrollIndicatorInsets = _tableView.contentInset;
    }
    return _tableView;
}

-(void) pullup{
    if(self.items.count == 0 ){
        return;
    }
    __weak typeof(self) weakSelf = self;
    int limit = 15;
    uint32_t starOrderSeq = self.items[self.items.count - 1].orderSeq;
    [WKSDK.shared.chatManager pullUp:self.channel startOrderSeq:starOrderSeq limit:limit complete:^(NSArray<WKMessage *> * _Nonnull messages, NSError * _Nonnull error) {
        if(error) {
            NSLog(@"上拉请求接口失败！->%@",error);
            return;
        }
        if(messages.count<limit) {
            [weakSelf enablePullDown:NO];
        }
        [weakSelf.items addObjectsFromArray:messages];
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

-(void) pulldown {
    if(self.items.count == 0 ){
        return;
    }
    int limit = 15;
    WKMessage *firstMsg = self.items[0];
    uint32_t starOrderSeq = firstMsg.orderSeq;
    __weak typeof(self) weakSelf = self;
    [WKSDK.shared.chatManager pullDown:self.channel startOrderSeq:starOrderSeq limit:limit complete:^(NSArray<WKMessage *> * _Nonnull messages, NSError * _Nonnull error) {
        if(error) {
            NSLog(@"下拉请求接口失败！->%@",error);
            return;
        }
        if(messages.count<limit) {
            [weakSelf enablePullDown:NO];
        }
        if(messages && messages.count>0) {
            NSArray<WKMessage*> *newMessages = [messages.reverseObjectEnumerator allObjects];
            for (WKMessage *message in newMessages) {
                [weakSelf.items insertObject:message atIndex:0];
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }
        for (NSInteger i=0; i<weakSelf.items.count; i++) {
            WKMessage *m = weakSelf.items[i];
            if([m.clientMsgNo isEqualToString:firstMsg.clientMsgNo]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [weakSelf.tableView endUpdates];
            }
        }
        
        
        
    }];
}

-(void) enablePullDown:(BOOL)enable {
    self.tableView.mj_header.hidden = !enable;
}
-(void) enablePullup:(BOOL) enable {
    self.tableView.mj_footer.hidden = !enable;
}

- (NSMutableArray *)items {
    if(!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (void)dealloc {
    [WKSDK.shared.chatManager removeDelegate:self];
}

@end



