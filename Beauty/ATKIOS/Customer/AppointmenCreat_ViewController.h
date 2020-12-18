//
//  AppointmenCreat_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppointmentDoc.h"
#import "ZXBaseViewController.h"

@protocol  appointmentCreateViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithCus_ID:(NSInteger)CustomerID;
@end

@interface AppointmenCreat_ViewController : ZXBaseViewController

@property(assign ,nonatomic) NSInteger viewTag;//1、订单详情进来 2、服务情页进来

@property (assign,nonatomic) NSInteger ReservedOrderType;
//存单
@property(assign, nonatomic) NSInteger BranchID;
@property(assign, nonatomic) NSInteger  orderID;
@property (assign,nonatomic) NSInteger serviceID;
//新单
@property (assign, nonatomic) NSString * serviceName;
@property (assign, nonatomic) long long serviceCode;
@property (strong, nonatomic)NSString * branchName;

@property (assign, nonatomic) NSInteger taskSourceType;

@property(strong ,nonatomic)AppointmentDoc * appointmentDoc;
@property (assign, nonatomic) id<appointmentCreateViewControllerDelegate> delegate;
@end
