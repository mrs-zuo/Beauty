//
//  AppDelegate.m
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "AppDelegate.h"
#import "AFHTTPRequestOperationLogger.h"
#import "ChatViewController.h"
#import "LoginViewController.h"
#import "DEFINE.h"
#import "SDWebImageManager.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SVProgressHUD.h"
#import "NSDate+Convert.h"
#import "GPHookObject.h"
#import "UIAlertView+AddBlockCallBacks.h"
#include <limits.h>
#include <float.h>
#import "GPBHTTPClient.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <Bugly/Bugly.h>



NSString * const AppDelegateDidChangeWindowFrameNotification = @"AppDelegateDidChangeWindowFrameNotification";
NSString * const AppDelegateWillEnterImagePickerControllerNotification = @"AppDelegateWillEnterImagePickerControllerNotification";
NSString * const AppDelegateWillComeOutImagePickerControllerNotification = @"AppDelegateWillComeOutImagePickerControllerNotification";
NSString * const AppDelegateNoChooserCustomerNotification = @"AppDelegateNoChooserCustomerNotification";

BMKMapManager* _mapManager;

@implementation AppDelegate
@synthesize window;
@synthesize chatViewController;
@synthesize customer_Selected, commodityArray_Selected, serviceArray_Selected;
@synthesize isNeedGetVersion,isLogin,userChoice,isShowVersionUpdate;
@synthesize paperStorageOfCustomer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
    

//    NSLog(@"the didFinishLaunchingWithOptions %d", [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_INDATE"] intValue]);
    
    /// --Display layer
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:kColor_Editable];
    [[UILabel appearanceWhenContainedIn:[UISegmentedControl class], nil] setTextColor:kColor_DarkBlue];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:kColor_DarkBlue];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_last"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    if ((IOS7 || IOS8)) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        /*
         self.window.clipsToBounds =YES;
         self.window.frame  = CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height - 20);
         self.window.bounds = CGRectMake(0,20,self.window.frame.size.width,self.window.frame.size.height);*/
    } else if (IOS6) {
        [application setStatusBarStyle:UIStatusBarStyleDefault];
    }

    /// -- Notification
    // Hook for sendEvent in UIWindow
    [GPHookObject initialize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overtimeAction) name:GPHookObjectTouchEvnentNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[SVProgressHUD class] selector:@selector(dismiss) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeWindowFrame) name:AppDelegateDidChangeWindowFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterImageViewController) name:AppDelegateWillEnterImagePickerControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeOutImageViewController) name:AppDelegateWillComeOutImagePickerControllerNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nonChooserCustomer) name:AppDelegateNoChooserCustomerNotification object:nil];
    if (IOS8) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
    }
    /// -- request
    [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    /// --init data
    commodityArray_Selected = [NSMutableArray array];
    serviceArray_Selected   = [NSMutableArray array];
    commodityArray_Selected   = [NSMutableArray array];
    paperStorageOfCustomer = [NSMutableArray array];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"VERSION_UPDATE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"Account_TouchEvent"];
    [[NSUserDefaults standardUserDefaults] setObject:kGPBaseURLString forKey:@"Account_GPBasicURLString"];
    
    
#ifdef ThirdPush
    [Parse setApplicationId:@"2IV2y7Ond8zWoCis5ePT8WPqojLHRSElEKZFpvOO"
                  clientKey:@"AW7rDN9XMshuUHTiwRtWr8lNrcGgMZSkS8BJOYGI"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
#endif
    
#ifdef AFHTTPClientLog
    [[AFHTTPRequestOperationLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
#endif
    
    
    //#ifdef IConsole
    //    [iConsole sharedConsole].delegate = self;
    //    [iConsole sharedConsole].logLevel = iConsoleLogLevelInfo;
    //    [iConsole sharedConsole].deviceTouchesToShow = 3;
    //    [iConsole sharedConsole].deviceShakeToShow = YES;
    //    [iConsole sharedConsole].simulatorTouchesToShow = 2;
    //    [iConsole sharedConsole].simulatorShakeToShow = YES;
    //    [iConsole sharedConsole].logSubmissionEmail = @"1163712623@qq.com";
    //    [iConsole sharedConsole].infoString =  [NSString stringWithFormat:@"《美丽约定》测试版 %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    //    [[iConsole sharedConsole] setMaxLogItems:10];
    //    [[iConsole sharedConsole] setTextColor:[UIColor greenColor]];
    //    [[iConsole sharedConsole] setBackgroundColor:[UIColor blackColor]];
    //    self.window = [[iConsoleWindow alloc] initWithFrame:[self.window bounds]];
    //
    //    LoginViewController *loginController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateInitialViewController];
    //    self.window.rootViewController = loginController;
    //#endif
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    //wugang->
    //BOOL ret = [_mapManager start:@"GdhQXbDis0WkCr9diTa2FgQi" generalDelegate:self];
    BOOL ret = [_mapManager start:@"Sm6mQEOReVR7bheWj6bWWZq1nUGZaQSL" generalDelegate:self];
    //<-wugang
    if (!ret) {
        NSLog(@"manager start failed!");
    }

    [Bugly startWithAppId:@"84f3318d48"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   // [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:1] forKey:@"FIRSTCOME"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if (isNeedGetVersion && !isLogin && !userChoice )
        [self requestGetVersion];
    //    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTCOME"] integerValue] == 1) {
    //        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_MUSTUPDATE"] integerValue] == 1 && [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_MUSTUPDATE"] != nil) {
    ////            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大更新，请升级。" message:nil delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    ////            alert.tag = 0;
    ////            [alert show];
    //        }
    //    }
    
    
    if(self.noticeType == 1)
       [self goToChatrView];
    else if(self.noticeType == 2)
        [self goToOrderListView];
    
    self.noticeType = -1;
    
    [BMKMapView didForeGround];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_MUSTUPDATE"];
 //   [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:0] forKey:@"FIRSTCOME"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"ACCOUNT_PUSHFROMORDERCONFIRMTOPAY"];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  mark - goToViewController

- (void)goToChatrView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"];
    
    UIViewController *topViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ChatNavigation"];
    CGRect frame = self.window.rootViewController.slidingViewController.topViewController.view.frame;
    self.window.rootViewController.slidingViewController.topViewController = topViewController;
    self.window.rootViewController.slidingViewController.topViewController.view.frame = frame;
    [self.window.rootViewController.slidingViewController resetTopView];
}

- (void)goToOrderListView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"];
    
    UIViewController *topViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MyOrderNavigation"];
    CGRect frame = self.window.rootViewController.slidingViewController.topViewController.view.frame;
    self.window.rootViewController.slidingViewController.topViewController = topViewController;
    self.window.rootViewController.slidingViewController.topViewController.view.frame = frame;
    [self.window.rootViewController.slidingViewController resetTopView];
}
#pragma mark -
#pragma mark - Remote Notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    NSMutableString *valueString = [NSMutableString string];
    const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
    NSInteger count = deviceToken.length;
    for (int i = 0; i < count; i++) {
        [valueString appendFormat:@"%02x", tokenBytes[i]&0x000000FF];
    }
    
    //NSString *tokenStr0 = [NSString stringWithFormat:@"%@",deviceToken];
    //NSString *tokenStr1 = [tokenStr0 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    //NSString *tokenStr2 = [tokenStr1 stringByReplacingOccurrencesOfString:@">" withString:@""];
    //NSString *tokenStr  = [tokenStr2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:valueString forKey:@"DeviceToken"];
    DLOG(@"DeviceToken:%@", deviceToken.description);
    
#ifdef ThirdPartyPush_Enable
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
#endif
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    DLOG(@"notification error:%@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSInteger badge = [[aps objectForKey:@"badge"] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber += badge;
    self.noticeType = [[userInfo objectForKey:@"pushType"] integerValue];
    
    if (application.applicationState == UIApplicationStateActive) {
        if (chatViewController) {
            [chatViewController requestGetNewMessage];
        }
    }
}

#pragma mark -
#pragma mark - Notification

- (void)overtimeAction
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *prevDateStr = [userDefaults objectForKey:@"Account_TouchEvent"];
    [userDefaults setObject:[NSDate dateToString:[NSDate date] dateFormat:@"yyyy-MM-dd HH:mm:ss"] forKey:@"Account_TouchEvent"];
    NSDate *preveDate = [NSDate stringToDate:prevDateStr dateFormat:@"yyyy-MM-dd HH:mm:ss"];
    int indate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_INDATE"] intValue];
    
    if (preveDate && (indate > 0)) {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:preveDate];
        
        if (time > indate * 60 && self.window.rootViewController.presentedViewController.nibName != nil) {
            customer_Selected = nil;
            [serviceArray_Selected removeAllObjects];
            [commodityArray_Selected removeAllObjects];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"操作超时，请重新登录!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
                [self comeOutImageViewController];
            }];
        }
    }
}


- (void)testLogoutApp {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"登录异常，请重新登录!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_USERID"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_COMPANTID"];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate setCustomer_Selected:nil];
        [appDelegate.serviceArray_Selected removeAllObjects];
        [appDelegate.commodityArray_Selected removeAllObjects];
        [appDelegate.paperStorageOfCustomer removeAllObjects];
        
        [[GPBHTTPClient sharedClient] requestUrlPath:@"/Login/Logout" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
            
        } failure:^(NSError *error) {
            
        }];

        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{}];
        [self comeOutImageViewController];
    }];
}
- (void)nonChooserCustomer
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未选中顾客，不能操作数据！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}

- (void)changeWindowFrame
{
    if ((IOS7 || IOS8)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        /*
         self.window.clipsToBounds = YES;
         self.window.frame  = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height);
         self.window.bounds = CGRectMake(0, 20, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height);
         */
    } else if (IOS6) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    DLOG(@"%@", self.window);
}

- (void)enterImageViewController
{
    // if (IOS7) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
    // }
}

- (void)comeOutImageViewController
{
    //if (IOS7) {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavBar_last"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    // }
}

#pragma mark -
#pragma mark - iConsoleDelegate

- (void)handleConsoleCommand:(NSString *)command
{
    if ([command isEqualToString:@"version"]) {
		[iConsole info:@"%@ version: %@",
         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
		 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	} else if ([command isEqualToString:@"mark"]) {
        [iConsole info:@"mark time:%@", [NSDate date]];
    } else if ([command isEqualToString:@"server"]) {
        [iConsole info:@"server:%@", kGPBaseURLString];
    } else {
		[iConsole error:@"unrecognised command, try 'version' instead"];
	}
}

#pragma mark -
#pragma mark - 接口

//- (void)requestGetVersion
//{
//   [[GPHTTPClient shareClient] requestGetVersionWithSuccess:^(id xml) {
//       [GDataXMLDocument parseXML2:xml viewController:Nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
//           float current_version = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] floatValue];
//           float service_version = [[[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue] floatValue];
//           int  mustUpgrad = [[[[contentData elementsForName:@"MustUpgrade"] objectAtIndex:0] stringValue] intValue];
//
//           if (mustUpgrad != 0) {
//               [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"VERSION_UPDATE"];
//
//               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"版本发生重大改变,请下载更新" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//               [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
//               }];
//           }
//           if (service_version > current_version) {
//               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"版本更新" message:@"版本更新,现在更新?" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
//               [alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//
//                   if (buttonIndex == 0) {
//                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
//                   }
//               }];
//           }
//
//       } failure:^{}];
//   } failure:^(NSError *error) {}];
//}


// 获取程序最新版本
- (void)requestGetVersion
{
    
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Version/getServerVersion" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            BOOL mustUpFlag = [[data objectForKey:@"MustUpgrade"] boolValue];
            NSString *version = [data objectForKey:@"Version"];
            
            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                if (mustUpFlag == NO && isShowVersionUpdate < 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                    alert.tag = 0;
                    isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                        isShowVersionUpdate = 0;
                    }];
                } else if(isShowVersionUpdate < 1 ){
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_MUSTUPDATE"];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                    alert.tag = 0;
                    isShowVersionUpdate = 1;
                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 0) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:AppleStoreURL]];
                        }
                        isShowVersionUpdate = 0;
                    }];
                }
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
            }
            
        } failure:^(NSInteger code, NSString *error) {}];
        
    } failure:^(NSError *error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        }];

    }];
    
    /*
    [[GPHTTPClient shareClient] requestGetVersionWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:Nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            NSString *version = [[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue] == nil ? @"":[[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue];
            NSInteger mustUpgrade = [[[[contentData elementsForName:@"MustUpgrade"] objectAtIndex:0] stringValue] integerValue];
//            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTCOME"] integerValue] == 1){
                if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
                    if (mustUpgrade == 0 && isShowVersionUpdate < 1) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
                        alert.tag = 0;
                        isShowVersionUpdate = 1;
                        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                            }
                            isShowVersionUpdate = 0;
                        }];
                    } else if(isShowVersionUpdate < 1 ){
                        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_MUSTUPDATE"];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
                        alert.tag = 0;
                        isShowVersionUpdate = 1;
                        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/安缔克商家版/id1321225111?mt=8"]];
                            }
                            isShowVersionUpdate = 0;
                        }];
                    }
                } else {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
                }
            //}
        } failure:^{}];
    } failure:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
    }];
     
     */
    
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}


@end

