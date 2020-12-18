//
//  ZXOrderSearchViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXOrderSearchViewController.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "SVProgressHUD.h"


@interface ZXOrderSearchViewController () <UISearchBarDelegate>
{
    UISearchBar *orderSearchBar;
}
@end

@implementation ZXOrderSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}
- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    
    orderSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(5, 5, kSCREN_BOUNDS.size.width -10 - 44 - 10, 44)];
    orderSearchBar.placeholder = @"搜索订单号或者服务名称";
    orderSearchBar.delegate = self;
    orderSearchBar.backgroundColor = kColor_Background_View;
    [self.view addSubview:orderSearchBar];
    
    UIButton *searchButton = [UIButton buttonWithTitle:@"搜索" target:self selector:@selector(searchButton:) frame:CGRectMake(kSCREN_BOUNDS.size.width -10 - 44,5,44 + 5, 44) titleColor:kColor_White backgroudColor:nil];
    searchButton.layer.cornerRadius = 5;
    searchButton.backgroundColor = [UIColor colorWithRed:22.0 / 255.0 green:171.0 / 255.0 blue:255.0 / 255.0 alpha:1];
    [self.view addSubview:searchButton];
    
}
#pragma mark - 按钮事件
- (void)goBack
{
    [self.view endEditing:YES];
    orderSearchBar.text = @"";
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)searchButton:(UIButton *)butt
{
    if ([orderSearchBar.text isEqualToString:@""] || orderSearchBar.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus2:@"请输入要查询的订单编号或服务商品名称!" touchEventHandle:^{
            
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ZXOrderSearchViewController:searchBar:)]) {
        [self.delegate ZXOrderSearchViewController:self searchBar:orderSearchBar];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark -  UISearchBar 代理
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if ([self.delegate respondsToSelector:@selector(ZXOrderSearchViewController:searchBar:)]) {
        [self.delegate ZXOrderSearchViewController:self searchBar:orderSearchBar];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
