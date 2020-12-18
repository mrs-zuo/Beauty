//
//  AboutUsViewController.m
//  CustomeDemo
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
@end

@implementation AboutUsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
  
    if ((IOS7 || IOS8)) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"关于我们";
    _versionLabel.text = [NSString stringWithFormat:@"软件版本:V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
