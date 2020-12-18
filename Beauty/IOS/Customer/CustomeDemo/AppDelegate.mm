//
//  AppDelegate.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-1. 
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountDoc.h"
#import "AFHTTPRequestOperationLogger.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
//#import "WeiboSDK.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "LoginViewController.h"

@interface AppDelegate ()

@property (nonatomic,strong)CLLocationManager *locationManager;
@end

BMKMapManager* _mapManager;

@implementation AppDelegate
@synthesize accounts;
//@synthesize shareType;
@synthesize weiboToken;
@synthesize firstCome,isNeedGetVersion,isLogin,userChoice,isShowVersionUpdate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // 分享
    [WXApi registerApp:@"wxf4db42b90c092bf9"];
//    [WeiboSDK registerApp:@"1405049435"];
    [ShareSDK registerApp:@"6f6eb88f4455"];
    [self initializePlatform];
    
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NarBaClient"] forBarMetrics:UIBarMetricsDefault];
    
    //打开发送和接收数据的debug信息
    [[AFHTTPRequestOperationLogger sharedLogger] setLevel:AFLoggerLevelDebug];
    [[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    
    [[NSNotificationCenter defaultCenter] addObserver:[SVProgressHUD class] selector:@selector(dismiss) name:SVProgressHUDDidReceiveTouchEventNotification object:nil];
    
    //    //登陆类型
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_LOGINTYPE"];
    //设备类型
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_EQUIPMENTTYPE"];
    
    //    // for test
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:6] forKey:@"CUSTOMER_USERID"];
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:2] forKey:@"CUSTOMER_COMPANYID"];
    //    [[NSUserDefaults standardUserDefaults] setObject:@"美丽约定美容院" forKey:@"CUSTOMER_COMPANYNAME"];
    //    [[NSUserDefaults standardUserDefaults] setObject:@"http://172.16.18.197/GetThumbnail.aspx?fn=image/Customer/6/head/20130829132656437581409.jpg&th=40&tw=40&bg=FFFFFF" forKey:@"CUSTOMER_HEADIMAGE"];
    
    if(IOS8)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    }else
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound];
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"Gg5W17pZe2afH2lYy1CcaPPv" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }

       if ([CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)) {
        _locationManager =[[CLLocationManager alloc] init];
        _locationManager.delegate=self;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        _locationManager.distanceFilter= 1;
        if (IOS8) {
            [_locationManager requestWhenInUseAuthorization];//使用程序其间允许访问位置数据（iOS8定位需要）
        }
        [_locationManager startUpdatingLocation];//开启定位
    }else{
        NSLog(@"无法定位");
    }

    return YES;
}

- (void)initializePlatform
{
    /*
     [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
     appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
     redirectUri:@"http://www.sharesdk.cn"];
     
     [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
     appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
     redirectUri:@"http://www.sharesdk.cn"
     weiboSDKCls:[WeiboSDK class]];
     */
    
//    [ShareSDK connectSinaWeiboWithAppKey:@"1405049435"
//                               appSecret:@"6c4adcae0fc34aa023b2a6399e7aa5a2"
//                             redirectUri:@"https://api.weibo.com/oauth2/default.html"];
    
//    [ShareSDK connectSinaWeiboWithAppKey:@"1405049435"
//                               appSecret:@"6c4adcae0fc34aa023b2a6399e7aa5a2"
//                             redirectUri:@"https://api.weibo.com/oauth2/default.html"
//                             weiboSDKCls:[WeiboSDK class]];
    
    /*
     [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
     wechatCls:[WXApi class]];
     
     [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
     appSecret:@"64020361b8ec4c99936c0e3999a9f249"
     wechatCls:[WXApi class]];
     */
    [ShareSDK connectWeChatWithAppId:@"wxf4db42b90c092bf9"
                           wechatCls:[WXApi class]];
    
    [ShareSDK connectWeChatWithAppId:@"wxf4db42b90c092bf9"
                           appSecret:@"863644a2d1f38ec1f304a520b540f451"
                           wechatCls:[WXApi class]];
    
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (isNeedGetVersion && !isLogin && !userChoice )
        [self requestAppVersion];
    
    if (self.noticeType == 1)
        [self goToChatrView];
    
    self.noticeType = -1;
    
    [BMKMapView didForeGround];
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    //app killed的时候，注销注册的微博和微信
    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiFav];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiSession];
    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
    [self resetUserDefaults:0 callBack:nil];
}

- (void)goToChatrView
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"];
    
    UIViewController *topViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"ChatNavigation"];
    CGRect frame = self.window.rootViewController.slidingViewController.topViewController.view.frame;
    self.window.rootViewController.slidingViewController.topViewController = topViewController;
    self.window.rootViewController.slidingViewController.topViewController.view.frame = frame;
    [self.window.rootViewController.slidingViewController resetTopView];
}

-(void)resetUserDefaults:(NSInteger)outID callBack:(void(^)())callBack
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_MUSTUPDATE"];
    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:0] forKey:@"FIRSTCOME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_USERID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHID"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_BRANCHCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYCODE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYABBREVIATION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_SELFNAME"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_HEADIMAGE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DISCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYSCALE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PROMOTION"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_REMINDCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_DATABASE"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_COMPANYLIST"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_PAYCOUNT"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CONFIRMCOUNT"];
    
    //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMUSERNAME"];
    if (outID ==1) {
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"LAST_LOGIN_CUSTOMPASSWORD"];
        
        LoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.window.rootViewController presentViewController:loginVC animated:YES completion:^{
            self.alertView = nil;
            if (callBack) callBack();
        }];
//        [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
//            self.alertView = nil;
//            if (callBack) callBack();
//        }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_CURRENCYTOKEN"];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"CUSTOMER_ADVANCED"];
}
//网络请求返回：需要强制升级时候，账号在其他地方登录的时候，直接调用本函数退出
-(void)logout:(NSString*)message callBack:(void(^)())callBack
{
//    if (self.window.rootViewController.presentedViewController.nibName && !self.alertView){
//        self.alertView = [[UIAlertView alloc] initWithTitle:nil message:message.length > 0 ? message : @"程序即将登出！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [self.alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            
//            [self resetUserDefaults:1 callBack:callBack];
//            
//        }];
//    }
    if (!self.alertView){
        self.alertView = [[UIAlertView alloc] initWithTitle:nil message:message.length > 0 ? message : @"程序即将登出！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [self.alertView showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            [[NSUserDefaults standardUserDefaults]setObject:@"NO" forKey:@"isAutoLogin"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"login_selected_compmay"];

            [self resetUserDefaults:1 callBack:callBack];
            
        }];
    }

}
#pragma mark - RemoteNotifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *tokenStr0 = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *tokenStr1 = [tokenStr0 stringByReplacingOccurrencesOfString:@"<" withString:@""];
    NSString *tokenStr2 = [tokenStr1 stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *tokenStr  = [tokenStr2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:tokenStr forKey:@"DeviceToken"];
    NSLog(@"DeviceToken:%@",tokenStr);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"notification error:%@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSInteger badge = [[aps objectForKey:@"badge"] integerValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber += badge;
    self.noticeType = [[userInfo objectForKey:@"pushType"] integerValue];
    
    if (application.applicationState == UIApplicationStateActive) {
        if (_chatViewController) {
            [_chatViewController requestGetNewMessage];
        }
        if (_verifyPhoneViewController) {
            [_verifyPhoneViewController requestMakeButtonUnenable];
        }
    }
}

#pragma mark - Call Other App

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //if (shareType == ShareTypeWeibo)   return [WeiboSDK handleOpenURL:url delegate:self];
    //if (shareType == ShareTypeWeixin)  return  [WXApi handleOpenURL:url delegate:self];
    //return NO;
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //return  [WXApi handleOpenURL:url delegate:self];
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}


#pragma mark - WeiboSDKDelegate

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
//- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
//{
//    
//}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
//- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
//{
//    if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]) // 发送response
//    {
//        //        NSString *message = [NSString stringWithFormat:@"响应状态: %ld\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
//        //                             (long)response.statusCode, response.userInfo, response.requestUserInfo];
//        //        NSLog(@"weibo resp:%@", response);
//        //        NSLog(@"weibo message:%@", message);
//    }
//    else if ([response isKindOfClass:[WBAuthorizeResponse class]])  // 认证response
//    {
//        //        NSString *message = [NSString stringWithFormat:@"响应状态: %ld\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",
//        //                             (long)response.statusCode, [(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
//        //        
//        //        NSLog(@"weibo resp:%@", response);
//        //        NSLog(@"weibo message:%@",message);
//        
//        
//        [[NSUserDefaults standardUserDefaults] setObject:[(WBAuthorizeResponse *)response accessToken] forKey:@"WEIBO_accessToken"];
//        [[NSUserDefaults standardUserDefaults] setObject:[(WBAuthorizeResponse *)response expirationDate] forKey:@"WEIBO_expirationDate"];
//        weiboToken = [(WBAuthorizeResponse *)response accessToken];
//    }
//}

//#pragma mark - WXApiDelegate
//
///*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
// *
// * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
// * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
// * @param req 具体请求内容，是自动释放的
// */
//-(void) onReq:(BaseReq*)req
//{
//
//}
//
///*! @brief 发送一个sendReq后，收到微信的回应
// *
// * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
// * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
// * @param resp具体的回应内容，是自动释放的
// */
//-(void) onResp:(BaseResp*)resp
//{
//    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
//
//        NSLog(@"weichat resp:%@", resp);
//        if (resp.errCode == WXSuccess)
//        {
//            NSLog(@"chat success");
//        }
//        else if (resp.errCode == WXErrCodeUnsupport)
//        {
//            NSLog(@"chat unsupport");
//        }
//
//    }
//}
// 获取程序最新版本
- (void)requestAppVersion
{
    //    _getVersionOperation = [[GPHTTPClient shareClient] requestAppVersionWithSuccess:^(id xml) {
    //        [GDataXMLDocument parseXML:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData) {
    //            AppDelegate *appDelegate = (AppDelegate * )[[UIApplication sharedApplication ] delegate];
    //            NSString *version = [[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue] == nil ? @"":[[[contentData elementsForName:@"Version"] objectAtIndex:0] stringValue];
    //            NSInteger mustUpgrade = [[[[contentData elementsForName:@"MustUpgrade"] objectAtIndex:0] stringValue] integerValue];
    //            //            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTCOME"] integerValue] == 1){
    //            //appDelegate.isShowVersionUpdate = 0; //需要显示升级提示框（解决不点击升级框，直接切换到后台后再激活程序，会多次弹出升级框）
    //            if ([version compare:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_APPVERSION"]] > 0) {
    //                if (mustUpgrade == 0 && appDelegate.isShowVersionUpdate < 1) {
    //                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"检测到新版本，是否升级？" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
    //                    alert.tag = 0;
    //                    appDelegate.isShowVersionUpdate = 1;
    //                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    //                        if (buttonIndex == 0) {
    //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"]];
    //                        }
    //                        appDelegate.isShowVersionUpdate = 0;
    //                    }];
    //                } else if (appDelegate.isShowVersionUpdate < 1) {
    //                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:1] forKey:@"CUSTOMER_MUSTUPDATE"];
    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件有重大升级，请更新！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    //                    alert.tag = 0;
    //                    appDelegate.isShowVersionUpdate = 1;
    //                    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    //                        if (buttonIndex == 0) {
    //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"]];
    //                        }else
    //                            exit(0);
    //                        appDelegate.isShowVersionUpdate = 0;
    //                    }];
    //                }
    //            } else {
    //                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:0] forKey:@"CUSTOMER_MUSTUPDATE"];
    //            }
    //            //            }
    //        } failure:^{}];
    //    } failure:^(NSError *error) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，\0请检查网络设置" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
    //        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
    //            exit(0);
    //        }];
    //        
    //    }];
}


#pragma mark -  CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    CGFloat longitude = location.coordinate.longitude;
    CGFloat latitude = location.coordinate.latitude;
    [[NSUserDefaults standardUserDefaults]setObject:@(longitude) forKey:@"longitude"];
    [[NSUserDefaults standardUserDefaults]setObject:@(latitude) forKey:@"latitude"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败");
}

@end
