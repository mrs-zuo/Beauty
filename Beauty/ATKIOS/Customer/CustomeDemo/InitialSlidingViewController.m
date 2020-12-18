//
//  InitialSlidingViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "InitialSlidingViewController.h"
#import "GPNavigationController.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"

@implementation InitialSlidingViewController
@synthesize tagetView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:tagetView];
    self.topViewController.view.layer.shadowOpacity = 1.0f;
    self.topViewController.view.layer.shadowRadius = 10.0f;
    self.topViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
