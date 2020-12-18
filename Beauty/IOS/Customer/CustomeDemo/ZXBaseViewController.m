//
//  ZXBaseViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/28.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "ZXBaseViewController.h"

@interface ZXBaseViewController ()

@end

@implementation ZXBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor * color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:UITextAttributeTextColor];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    [self.navigationController.navigationBar setBarTintColor:KColor_NavBarTintColor];
}
-(void)setIsOnlyShowBackButton:(BOOL)isOnlyShowBackButton
{
    _isOnlyShowBackButton = isOnlyShowBackButton;
    [self initNavView];
}
-(void)setIsShowButton:(BOOL)isShowButton
{
    _isShowButton = isShowButton;
    [self initNavView];
}
- (void)initNavView
{
    if (_isShowButton) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setFrame:CGRectMake(0, 20.0f, 30.0f, 30.0f)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(kSCREN_BOUNDS.size.width - 50.0f,20.0f , 30.0f, 30.0f)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"home_right"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    
    if (_isOnlyShowBackButton) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setFrame:CGRectMake(0, 20.0f, 30.0f, 30.0f)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }

}

-(void)setIsShow_tab_nav_tab_vcButton:(BOOL)isShow_tab_nav_tab_vcButton
{
    _isShow_tab_nav_tab_vcButton = isShow_tab_nav_tab_vcButton;

    if (_isShow_tab_nav_tab_vcButton) {
        UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn setFrame:CGRectMake(0, 20.0f, 30.0f, 30.0f)];
        [leftBtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setFrame:CGRectMake(kSCREN_BOUNDS.size.width - 50.0f,20.0f , 30.0f, 30.0f)];
        [rightBtn setBackgroundImage:[UIImage imageNamed:@"home_right"] forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(homeAction) forControlEvents:UIControlEventTouchUpInside];
        
        self.tabBarController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
        self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    
}
- (void)homeAction
{
    self.tabBarController.selectedIndex = 0 ;
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
