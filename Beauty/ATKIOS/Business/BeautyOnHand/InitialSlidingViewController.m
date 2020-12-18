//
//  InitialSlidingViewController.m
//  BeautyPromise02
//
//  Created by ZhongHe on 13-5-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "InitialSlidingViewController.h"

@implementation InitialSlidingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        UIView *state = (UIView *)[self.view viewWithTag:100];
        if (state == nil) {
            UIView *stateView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 20.0f)];
            stateView.tag = 100;
            [stateView setBackgroundColor:[UIColor blackColor]];
            [self.view addSubview:stateView];
        }
    }

    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstNavigation"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
