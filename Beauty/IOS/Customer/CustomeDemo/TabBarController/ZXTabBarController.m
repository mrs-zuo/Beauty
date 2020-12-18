//
//  ZXTabBarController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/18.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "ZXTabBarController.h"

@interface ZXTabBarController ()

@end

@implementation ZXTabBarController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self initStyleWithTabBar:self.tabBar];
}

#pragma mark - UITabBar 设置背景颜色 和 字体颜色
-(void)initStyleWithTabBar:(UITabBar *)tabbar
{
    //背景
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    [tabbar insertSubview:bgView atIndex:0];
    tabbar.opaque = YES;
    
    //图标
    UITabBarItem *item0 = [tabbar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabbar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabbar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabbar.items objectAtIndex:3];
    UITabBarItem *item4 = [tabbar.items objectAtIndex:4];

    item0.selectedImage = [[UIImage imageNamed:@"index11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.image = [[UIImage imageNamed:@"index12"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.selectedImage = [[UIImage imageNamed:@"appointment11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.image = [[UIImage imageNamed:@"appointment12"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.selectedImage = [[UIImage imageNamed:@"shopcar11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item2.image = [[UIImage imageNamed:@"shopcar12"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.selectedImage = [[UIImage imageNamed:@"chart11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item3.image = [[UIImage imageNamed:@"chart12"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.selectedImage = [[UIImage imageNamed:@"person11"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item4.image = [[UIImage imageNamed:@"person12"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //字体颜色
    [[UITabBarItem appearance]setTitleTextAttributes:@{UITextAttributeTextColor:kMainLightGrayColor} forState:UIControlStateNormal];
    [[UITabBarItem appearance]setTitleTextAttributes:@{UITextAttributeTextColor:KColor_NavBarTintColor} forState:UIControlStateSelected];
}


@end
