//
//  AppDelegate.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-7-1.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "WXApi.h"
//#import "WeiboSDK.h"
#import "ChatViewController.h"
#import "GPHTTPClient.h"
#import "VerifyPhoneViewController.h"
#import "ECSlidingViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

//typedef enum
//{
//    ShareTypeWeibo,
//    ShareTypeWeixin
//} ShareType;

@class AccountDoc;
@interface AppDelegate : UIResponder <UIApplicationDelegate, /*WeiboSDKDelegate, */UIActionSheetDelegate,BMKGeneralDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableArray *accounts;
@property (strong, nonatomic) AccountDoc *account_selected;
@property (assign, nonatomic) NSInteger accountId_temp;
@property (assign, nonatomic) NSInteger firstCome;
@property (strong, nonatomic) NSString *loginMobile;
@property (strong, nonatomic) UIAlertView *alertView;
@property (weak, nonatomic) ChatViewController *chatViewController;
@property (weak, nonatomic) VerifyPhoneViewController *verifyPhoneViewController;
@property (assign, nonatomic) BOOL isNeedGetVersion;
@property (assign, nonatomic) BOOL isLogin;
@property (assign, nonatomic) BOOL userChoice;
@property (assign, nonatomic) NSInteger noticeType;//通知类型
@property (assign, nonatomic) NSInteger isShowVersionUpdate;
// -- 分享
//@property (assign, nonatomic) ShareType shareType;
@property (assign, nonatomic) NSString *weiboToken; // 微博认证token
@property (weak, nonatomic) AFHTTPRequestOperation *getVersionOperation;
//网络请求返回：需要强制升级时候，账号在其他地方登录的时候，直接调用本函数退出
-(void)logout:(NSString*)message callBack:(void(^)())callBack;
@end
