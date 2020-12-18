//
//  FirstTopViewController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "FirstTopViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface FirstTopViewController ()
@end

@implementation FirstTopViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    if (kSCREN_BOUNDS.size.height == 548.0f) {
        [_imageView setImage:[UIImage imageNamed:@"WelcomeImg_640x1008"]];
    } else {
        [_imageView setImage:[UIImage imageNamed:@"WelcomeImg"]];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
