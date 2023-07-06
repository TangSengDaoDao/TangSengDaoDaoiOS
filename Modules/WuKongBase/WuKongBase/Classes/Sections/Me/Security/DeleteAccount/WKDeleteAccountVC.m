//
//  WKDeleteAccountVC.m
//  WuKongBase
//
//  Created by tt on 2022/8/29.
//

#import "WKDeleteAccountVC.h"
#import "WuKongBase.h"
#import "WKMarkdownParser.h"
#import "UILabel+WK.h"
#import "WKDeleteAccountVercodeVC.h"
#define leftSpace 10.0f

@interface WKDeleteAccountVC ()

@property(nonatomic,strong) UIView *footerView;

@property(nonatomic,strong) UILabel *deleteAccountTipLbl;

@property(nonatomic,strong) UIButton *deleteAccountBtn;
@property(nonatomic,strong) UIButton *cancelBtn;

@end

@implementation WKDeleteAccountVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewModel = [WKDeleteAccountVM new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = LLang(@"注销账号");
    
    self.view.backgroundColor = WKApp.shared.config.cellBackgroundColor;
    
    [self.view addSubview:self.footerView];
    [self.footerView addSubview:self.deleteAccountTipLbl];
    [self.footerView addSubview:self.deleteAccountBtn];
    [self.footerView addSubview:self.cancelBtn];
    

    self.tableView.lim_height = self.tableView.lim_height - self.footerView.lim_height;
    
    [self layoutFooterView];
    
}

-(void) layoutFooterView {
    
    self.footerView.lim_top = self.tableView.lim_bottom;
    
    self.deleteAccountTipLbl.lim_left = 10.0f;
    
    self.deleteAccountBtn.lim_top = self.deleteAccountTipLbl.lim_bottom + 10.0f;
    self.deleteAccountBtn.lim_left = 30.0f;
    
    self.cancelBtn.lim_top = self.deleteAccountBtn.lim_top;
    self.cancelBtn.lim_left = self.view.lim_width - self.cancelBtn.lim_width - 30.0f;
}

- (UIView *)footerView {
    if(!_footerView) {
        
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, WKScreenWidth, 100.0f+WKApp.shared.config.visibleEdgeInsets.bottom)];
    }
    return _footerView;
}

- (UILabel *)deleteAccountTipLbl {
    if(!_deleteAccountTipLbl) {
        _deleteAccountTipLbl = [[UILabel alloc] init];
        _deleteAccountTipLbl.font = [WKApp.shared.config appFontOfSize:14.0f];
        _deleteAccountTipLbl.numberOfLines = 0;
        _deleteAccountTipLbl.lineBreakMode = NSLineBreakByWordWrapping;
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        attrs.font = _deleteAccountTipLbl.font;
        
        NSString *content = [NSString stringWithFormat:@"%@(%@://app/userprotocol)",LLang(@"轻按下方\"注销账号\"按钮，即表示你已阅读同意[《用户使用协议》]"),WKApp.shared.config.appSchemaPrefix];
        WKMarkdownParser *markdownParser = [[WKMarkdownParser alloc] init];
        NSArray<id<WKMatchToken>> *tokens = [markdownParser parseMarkdownIntoAttributedString:content];
        [attrs lim_render:content tokens:tokens];
        
        _deleteAccountTipLbl.tokens = tokens;
       
        _deleteAccountTipLbl.attributedText = attrs;
        _deleteAccountTipLbl.lim_size =  [attrs size:WKScreenWidth - leftSpace*2];
        
        [_deleteAccountTipLbl onClick:^(id<WKMatchToken> token) {
            if([token isKindOfClass:[WKLinkToken class]]) {
                WKLinkToken *linkToken = (WKLinkToken*)token;
                [[WKSchemaManager shared] handleURL:[NSURL URLWithString:linkToken.linkContent]];
            }
           
        }];
        
    }
    return _deleteAccountTipLbl;
}

- (UIButton *)deleteAccountBtn {
    if(!_deleteAccountBtn) {
        _deleteAccountBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
        _deleteAccountBtn.backgroundColor = [UIColor colorWithRed:200.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:0.8f];
        _deleteAccountBtn.layer.masksToBounds = YES;
        _deleteAccountBtn.layer.cornerRadius = _deleteAccountBtn.lim_height/2.0f;
        [_deleteAccountBtn setTitle:LLang(@"注销账号") forState:UIControlStateNormal];
        [_deleteAccountBtn setTitleColor:WKApp.shared.config.themeColor forState:UIControlStateNormal];
        [_deleteAccountBtn lim_addEventHandler:^{
            WKDeleteAccountVercodeVC *vc = [WKDeleteAccountVercodeVC new];
            [WKNavigationManager.shared pushViewController:vc animated:YES];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteAccountBtn;
}

- (UIButton *)cancelBtn {
    if(!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 40.0f)];
        _cancelBtn.backgroundColor = WKApp.shared.config.themeColor;
        _cancelBtn.layer.masksToBounds = YES;
        _cancelBtn.layer.cornerRadius = _cancelBtn.lim_height/2.0f;
        
        [_cancelBtn setTitle:LLang(@"再想想") forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn lim_addEventHandler:^{
            [[WKNavigationManager shared] popViewControllerAnimated:YES];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

@end
