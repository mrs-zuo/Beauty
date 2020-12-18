//
//  ComputerSginViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/1.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ComputerSginViewController.h"
#import "UIImage+MW.h"
#import "UIButton+InitButton.h"
#import "ColorImage.h"

@interface ComputerSginViewController ()

@end

@implementation ComputerSginViewController

- (void)initView
{
    [self btnStyleWithButton:self.canceBtn theStyle:ButtonStyleRed];
    [self btnStyleWithButton:self.clearBtn theStyle:ButtonStyleRed];
    [self btnStyleWithButton:self.confirmBtn theStyle:ButtonStyleBlue];
}
- (void)btnStyleWithButton:(UIButton *)button theStyle:(ButtonStyle)theStyle
{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
    switch (theStyle) {
        case ButtonStyleRed:
        {
            [button setBackgroundImage:[ColorImage redBackgroudImage] forState:UIControlStateNormal];
        }
            break;
        case ButtonStyleBlue:
        {
            [button setBackgroundImage:[ColorImage blueBackgroudImage] forState:UIControlStateNormal];
        }
            break;
            
        default:
            break;
    }
    [button setAdjustsImageWhenDisabled:NO];
    [button setAdjustsImageWhenHighlighted:YES];
    [button setShowsTouchWhenHighlighted:NO];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 6.0f;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self initView];
    [self deviceOrientationDidChange];
}
- (void)deviceOrientationDidChange
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat startRotation = [[self.view valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.transform = CGAffineTransformMakeRotation(-startRotation + M_PI * 270.0 / 180.0);
    }
}

#pragma mark - 按钮事件

- (IBAction)confirm:(UIButton *)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
     UIImage *image = [UIImage captureWithView:self.drawView];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5f);
    NSString *imgString  = [imageData base64Encoding];
    self.computerConfirmSignBlock(imgString);
}

- (IBAction)cance:(UIButton *)sender {
     [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)clear:(UIButton *)sender {
    [self.drawView clear];
}

@end