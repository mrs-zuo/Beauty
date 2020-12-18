//
//  CustomNavigationController.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-2.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]

#import "GPNavigationController.h"
#import "InitialSlidingViewController.h"
#import "MenuViewController.h"
#import "ServerTabBarController.h"
#import "PhotosDetailViewController.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AppointmentList_ViewController.h"

@interface GPNavigationController ()
{
    CGPoint startTouch;
    UIImageView *lastScreenShotView;
}

@property (nonatomic,retain) UIView *backgroundView;
@property (nonatomic,retain) NSMutableArray *screenShotsList;
@property (nonatomic,assign) BOOL isMoving;

@end

@implementation GPNavigationController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
        self.canDragBack = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self showBarButtonWithViewController:[self.viewControllers firstObject] animated:YES];
    [self initMenuViewControllerAndaddGestureRecognizerForView:[self.viewControllers firstObject]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - init

- (void)initMenuViewControllerAndaddGestureRecognizerForView:(UIViewController *)viewController
{
    if (![self.slidingViewController.underRightViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    if (![viewController isKindOfClass:[PhotosDetailViewController class]] && ![viewController isKindOfClass:[AppointmentList_ViewController class]])
        [viewController.view addGestureRecognizer:self.slidingViewController.panGesture];
}

- (void)showBarButtonWithViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [leftBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
//    [leftBtn setHidden:YES];
////    [leftBtn setBackgroundImage:[UIImage imageNamed:@"BackButtonClient"] forState:UIControlStateNormal];
//    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [rightBtn setFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"NavButtonClient"] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
//    
//    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
//    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    
//    if ([viewController class] == [[self.viewControllers firstObject] class]  || [viewController isKindOfClass:[ServerTabBarController class]] ||[viewController isKindOfClass:[AppointmentList_ViewController class]]) {
//        [leftBtn setHidden:YES];
//    } else {
//        [leftBtn setHidden:NO];
//    }    
}

#pragma mark - push & pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.screenShotsList addObject:[self capture]];
    [self configViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    
    return [super popViewControllerAnimated:animated];
}

#pragma mark - configViewController

- (void)configViewController:(UIViewController *)viewController
{
    [self initMenuViewControllerAndaddGestureRecognizerForView:viewController];
    [self showBarButtonWithViewController:viewController animated:YES];
    [self addPanGestureForViewController:viewController];
}

- (void)addPanGestureForViewController:(UIViewController *)viewController
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerEvent:)];
    [viewController.view addGestureRecognizer:panGestureRecognizer];
}

- (void)menuAction
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissKeyboard" object:nil];
}

- (void)goBack
{
    [self popViewControllerAnimated:YES];
}

#pragma mark - Utility Methods -

- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)moveViewWithX:(float)x
{
    x = x > 320 ? 320 : x;
    x = x < 0 ? 0 : x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    lastScreenShotView.transform = CGAffineTransformMakeTranslation(x, 0);
}

#pragma mark - Gesture Recognizer -

- (void)panGestureRecognizerEvent:(UIPanGestureRecognizer *)recoginzer
{
    if (self.viewControllers.count <= 1 || !self.canDragBack) return;
    
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(-frame.size.width, 0, frame.size.width ,frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) {
            [lastScreenShotView removeFromSuperview];
        }
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc] initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:self.view];
        
    }else if (recoginzer.state == UIGestureRecognizerStateEnded){
        if (touchPoint.x - startTouch.x > 50) {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                
                [self popViewControllerAnimated:NO];
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
                
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
        }
        return;
    }else if (recoginzer.state == UIGestureRecognizerStateCancelled){
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        return;
    }
    
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}




@end
