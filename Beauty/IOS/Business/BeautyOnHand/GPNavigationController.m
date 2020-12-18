//
//  CustomNavigationController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-1.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

// 作用
// 后期仅仅初始化 MenuViewController

#define KEY_WINDOW  [[UIApplication sharedApplication] keyWindow]

#import "GPNavigationController.h"
#import "InitialSlidingViewController.h"
#import "LeftMenuViewController.h"
#import "RightMenuViewController.h"

#import "OrderListViewController.h"
#import "DEFINE.h"
#import "FirstTopViewController.h"
#import <sys/utsname.h>

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
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
        self.canDragBack = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configViewController:[self.viewControllers firstObject]];
    UIView *statuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    statuView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:statuView];
  
    NSString *iponeType = [self iphoneType];
    
    if ([iponeType isEqualToString:@"iPhone X"]) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top88x320"] forBarMetrics:UIBarMetricsDefault];
    } else {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_bg320" ] forBarMetrics:UIBarMetricsDefault];
    }
}

- (NSString *)iphoneType {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return@"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return@"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return@"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(!self.screenShotsList)
        self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];
    [self.screenShotsList addObject:[self capture]];
    [self configViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    [self.screenShotsList removeLastObject];
    return [super popViewControllerAnimated:animated];
}

-(NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    for (UIViewController *vc in self.viewControllers.reverseObjectEnumerator) {
        if ([vc isEqual:viewController]) {
            break;
        }
        [self.screenShotsList removeLastObject];
    }

    return [super popToViewController:viewController animated:YES];
}

- (void)cleanScreenShotsFromeVC:(Class)currentVCClass ViewController:(Class)skipVCClass
{
    NSMutableArray *muarryVC = [self.viewControllers mutableCopy];

    [muarryVC enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:skipVCClass]) {
            *stop = YES;
        } else if ([obj isKindOfClass:currentVCClass]) {
            
        } else {
            [muarryVC removeObject:obj];
            [self.screenShotsList removeLastObject];
        }
    }];
    [self setViewControllers:[muarryVC copy]];
}

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)configViewController:(UIViewController *)viewController
{
    [self initMenuViewController];
    [self showBarButtonWithViewController:viewController];
    [self addPanGestureForViewController:viewController];
}

- (void)initMenuViewController
{
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[LeftMenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftMenu"];
    }
    
    if (![self.slidingViewController.underRightViewController isKindOfClass:[RightMenuViewController class]]) {
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"RightMenu"];
    }
}

- (void)showBarButtonWithViewController:(UIViewController *)viewController
{
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0.0f, 0.0f, 47.0f, 30.0f)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"button_UserMeun"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(showUserMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setFrame:CGRectMake(0.0f, 0.0f, 47.0f, 30.0f)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"button_Meun"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(menuAction) forControlEvents:UIControlEventTouchUpInside];
    
    viewController.navigationItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    viewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
//    UIButton *middleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    middleBtn.frame = CGRectMake((kSCREN_BOUNDS.size.width - 100) /2, 0, 100, 44);
//    
//    viewController.navigationItem.titleView = middleBtn;
//    
//    [middleBtn addTarget:self action:@selector(firstTop) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addPanGestureForViewController:(UIViewController *)viewController
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerEvent:)];
    [viewController.view addGestureRecognizer:panGestureRecognizer];
}

- (void)firstTop
{
    FirstTopViewController *top = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"FirstTop"];
    GPNavigationController *nav = [[GPNavigationController alloc] initWithRootViewController:top];
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = nav;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
}

//- (void)panGestureRecognizerEvent:(UIPanGestureRecognizer *)panGesture
//{
//    if (panGesture.state == UIGestureRecognizerStateEnded) {
//        CGPoint point = [panGesture translationInView:panGesture.view];
//        if (point.x >= 15.0f) { [self goBack];}
//    }
//}

- (void)panGestureRecognizerEvent:(UIPanGestureRecognizer *)panGesture
{
//    NSLog(@"count           %lu", (unsigned long)self.viewControllers.count);
//    NSLog(@"canDragBack     %d", !self.canDragBack);
//    NSLog(@"push from order %ld", (long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"] integerValue]);
    
    if (self.viewControllers.count <= 1 || !self.canDragBack || [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"] integerValue] == 1 ) return;
    
    CGPoint touchPoint = [panGesture locationInView:KEY_WINDOW];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(-frame.size.width, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:self.view];
        
    }else if (panGesture.state == UIGestureRecognizerStateEnded){
        
        if (touchPoint.x - startTouch.x > 50)
        {
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
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                _isMoving = NO;
                self.backgroundView.hidden = YES;
            }];
            
        }
        return;
        
        // cancal panning, alway move to left side automatically
    }else if (panGesture.state == UIGestureRecognizerStateCancelled){
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
        
        return;
    }
    
    // it keeps move with touch
    if (_isMoving) {
        [self moveViewWithX:touchPoint.x - startTouch.x];
    }
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    
    NSLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    //float scale = (x/6400)+0.95;
    //float alpha = 0.4 - (x/800);
    
    //lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    lastScreenShotView.transform = CGAffineTransformMakeTranslation(x, 0);
}

- (void)showUserMenuAction:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)menuAction
{
    [self.slidingViewController anchorTopViewTo:ECLeft];
    
}

//- (void)goBack
//{
//    NSLog(@"%ld", (long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"] integerValue]);
//    if ([self.viewControllers count] > 1 && ![self.slidingViewController topViewIsOffScreen] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"] integerValue] != 1) {
//        [self popViewControllerAnimated:YES];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
