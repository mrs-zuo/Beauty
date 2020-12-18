//
//  AppointmentDetail_ViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppointmentDetail_ViewController : BaseViewController

@property(assign,nonatomic)long long LongID;
@property(assign,nonatomic)NSInteger viewFor; //1 预约列表  2 任务列表 3 订单详情
@end
