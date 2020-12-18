//
//  AboutUsViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-13.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "AboutUsViewController.h"
#import "DEFINE.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
       self.automaticallyAdjustsScrollViewInsets = NO;
       self.edgesForExtendedLayout= UIRectEdgeNone;
    }
	
    _versionLabel.text = [NSString stringWithFormat:@"软件版本:V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
