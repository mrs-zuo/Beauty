//
//  FindPasswordNavigationController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-13.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "FindPasswordNavigationController.h"
#import "InitialSlidingViewController.h"
#import "MenuViewController.h"
#import "ServerTabBarController.h"
#import "PhotosDetailViewController.h"
#import "SVProgressHUD.h"

@interface FindPasswordNavigationController ()

@end

@implementation FindPasswordNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)showBarButtonWithViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
//    [leftBtn setHidden:YES];
//    [leftBtn setBackgroundImage:[UIImage imageNamed:@"BackButtonClient"] forState:UIControlStateNormal];
//    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    
//    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
//    
//    if ([viewController class] == [[self.viewControllers firstObject] class]  || [viewController isKindOfClass:[ServerTabBarController class]]) {
//        [leftBtn setHidden:YES];
//    } else {
//        [leftBtn setHidden:NO];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    
    [self showBarButtonWithViewController:[self.viewControllers firstObject] animated:YES];
    
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"CUSTOMER_DATABASE"];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self showBarButtonWithViewController:viewController animated:animated];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

- (void)goBack
{
    [self popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 状态栏颜色，状态

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
