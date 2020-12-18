//
//  AppDelegate.h
//  Customers
//
//  Created by ZhongHe on 13-4-23.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "CustomerDoc.h"
#import "ServiceDoc.h"
#import "CommodityDoc.h"
#import "ChatViewController.h"
#import "iConsole.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>


UIKIT_EXTERN NSString * const AppDelegateDidChangeWindowFrameNotification;
UIKIT_EXTERN NSString * const AppDelegateWillEnterImagePickerControllerNotification;
UIKIT_EXTERN NSString * const AppDelegateWillComeOutImagePickerControllerNotification;
UIKIT_EXTERN NSString * const AppDelegateNoChooserCustomerNotification;

@interface AppDelegate : UIResponder <UIApplicationDelegate, iConsoleDelegate,BMKGeneralDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) ChatViewController *chatViewController;
@property (assign, nonatomic) BOOL isNeedGetVersion;
@property (assign, nonatomic) BOOL isLogin;
@property (assign, nonatomic) BOOL userChoice;
@property (assign, nonatomic) NSInteger isShowVersionUpdate;
@property (assign, nonatomic) NSInteger noticeType;
/*
 * 保存选择顾客、服务、商品
 * flag_Selected=0 提交的是服务
 * flag_Selected=1 提交的是商品
 */
@property (strong, nonatomic) CustomerDoc *customer_Selected;
@property (strong, nonatomic) NSMutableArray *serviceArray_Selected;  // 只有一个元素
@property (strong, nonatomic) NSMutableArray *commodityArray_Selected;
@property (strong, nonatomic) NSMutableArray *commodityOrServiceArray_Selected;//收藏页选择
@property (nonatomic, strong) NSMutableArray *paperStorageOfCustomer;
@property (nonatomic, strong) NSMutableArray *awaitOrderArray;
@property (assign, nonatomic) int flag_Selected;

//笔记页从订单进入1是  0 否
@property (nonatomic,assign) NSInteger noteForOrder;

///选中顾客indexPath
@property (nonatomic,strong) NSIndexPath *selCustomerIndexPath;
- (void)testLogoutApp;
@end
