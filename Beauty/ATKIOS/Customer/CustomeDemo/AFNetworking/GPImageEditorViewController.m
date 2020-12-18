//
//  GPImageEditorViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 13-12-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "GPImageEditorViewController.h"
#import "GPImageEditorView.h"
#import "DEFINE.h"

@interface GPImageEditorViewController ()
@end

@implementation GPImageEditorViewController
@synthesize delegate;
@synthesize imageEditorView;
@synthesize editImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.title = @"裁剪图片";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    imageEditorView = [[GPImageEditorView alloc] initWithImage:editImage];
    imageEditorView.viewController = self;
    [self.view addSubview:imageEditorView];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
