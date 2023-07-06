//
//  WKGlobalSearchResultController.m
//  WuKongBase
//
//  Created by tt on 2020/4/24.
//
#import "WKGlobalSearchVM.h"
#import "WKGlobalSearchResultController.h"
#define searchBarHeight 36.0f
@interface WKGlobalSearchResultController ()<WKChannelManagerDelegate>
@property(nonatomic,strong) WKGlobalSearchVM *vm;
@property(nonatomic,strong) UITextField *searchBarInput;
@property(nonatomic,strong) UIView *searchBarView;



@end

@implementation WKGlobalSearchResultController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.vm = [WKGlobalSearchVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vm.searchType = self.searchType;
    [self.navigationBar addSubview:self.searchBarView];
    [self.searchBarView addSubview:self.searchBarInput];
    
    [self.searchBarInput becomeFirstResponder];
    
    self.searchBarInput.text = self.keyword;
    __weak typeof(self) weakSelf = self;
    if(self.keyword && ![self.keyword isEqualToString:@""]) {
       
        [weakSelf.vm search:weakSelf.keyword callback:^(NSArray<WKFormSection *> * _Nonnull items) {
            weakSelf.items = [NSMutableArray arrayWithArray:items];
            [weakSelf.tableView reloadData];
        }];
    }
    
    [[WKSDK shared].channelManager addDelegate:self];
}

- (void)dealloc {
    [[WKSDK shared].channelManager removeDelegate:self];
}

- (UITextField *)searchBarInput {
    if(!_searchBarInput) {
        _searchBarInput = [[UITextField alloc] initWithFrame:CGRectMake(26.0f, 0.0f, self.searchBarView.lim_width - 26.0f, searchBarHeight)];
        _searchBarInput.placeholder = LLang(@"搜索");
        [_searchBarInput addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        
    }
    return _searchBarInput;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}



- (UIView *)searchBarView {
    if(!_searchBarView) {
        CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.lim_width - 70.0f, searchBarHeight)];
        _searchBarView.lim_left = 45.0f;
        [_searchBarView setBackgroundColor:[WKApp shared].config.cellBackgroundColor];
        _searchBarView.layer.masksToBounds = YES;
        _searchBarView.layer.cornerRadius = 4.0f;
        _searchBarView.lim_top = (self.navigationBar.lim_height-statusHeight)/2.0f - _searchBarView.lim_height/2.0f + statusHeight;
        
        UIImageView *iconImgView = [[UIImageView alloc] initWithImage: [self imageName:@"Common/Index/IconSearch2"]];
        iconImgView.frame = CGRectMake(6.0f, 0.0f, 16.0f, 16.0f);
        iconImgView.lim_top = _searchBarView.lim_height/2.0f - iconImgView.lim_height/2.0f;
        [_searchBarView addSubview:iconImgView];
    }
    return _searchBarView;
}

- (CGRect)tableViewFrame {
    CGRect rect = [self visibleRect];
    return CGRectMake(0.0f, rect.origin.y + 4.0f, rect.size.width, rect.size.height - 4.0f);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

-(void) viewConfigChange:(WKViewConfigChangeType)type {
    [super viewConfigChange:type];
    if(type == WKViewConfigChangeTypeStyle) {
        [_searchBarView setBackgroundColor:[WKApp shared].config.cellBackgroundColor];
    }
}


#pragma mark -- 事件

- (void)textFieldEditingChanged:(UITextField *)textField {
    __weak typeof(self) weakSelf = self;
    [self.vm search:textField.text callback:^(NSArray<WKFormSection *> * _Nonnull items) {
           weakSelf.items = [NSMutableArray arrayWithArray:items];
           [weakSelf.tableView reloadData];
       }];
}

// 重写返回事件
-(void) backPressed {
    [[WKNavigationManager shared] popViewControllerAnimated:NO];
}

#pragma mark -- 其他

-(UIImage*) imageName:(NSString*)name {
    return [WKApp.shared loadImage:name moduleID:@"WuKongBase"];
//    return [[WKResource shared] resourceForImage:name podName:@"WuKongBase_images"];
}

#pragma mark -- WKChannelManagerDelegate

- (void)channelInfoUpdate:(WKChannelInfo *)channelInfo {
    [self reloadData];
}
@end
