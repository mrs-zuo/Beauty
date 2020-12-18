//
//  AppointmenCreat_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  appointmentCreateViewControllerDelegate<NSObject>
- (void)dismissViewControllerWithCus_ID:(NSInteger)CustomerID;
@end

@interface AppointmenCreat_ViewController : BaseViewController

@property(assign ,nonatomic) NSInteger viewTag;//1、顾客服务页进来 2、订单详情页进来

@property(assign, nonatomic) NSInteger orderID;
@property(assign, nonatomic) NSInteger orderObjectID;
@property(strong, nonatomic) NSString * serveName;
@property(strong, nonatomic) NSString * cusName;
@property(assign, nonatomic) NSInteger cusID;
@property (assign, nonatomic) id<appointmentCreateViewControllerDelegate> delegate;
@end
