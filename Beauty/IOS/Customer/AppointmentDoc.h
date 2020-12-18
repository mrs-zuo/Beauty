//
//  AppointmentDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppointmentDoc : NSObject

@property(copy ,nonatomic) NSString * Appointment_customer;//顾客
@property(assign ,nonatomic) NSInteger  Appointment_customerID;//顾客ID
@property(copy ,nonatomic) NSString * Appointment_branchName;
@property(assign ,nonatomic) NSInteger Appointment_branchID;

@property(copy ,nonatomic) NSString * Appointment_date;//预约时间
@property(copy ,nonatomic) NSString * Appointment_remark;
@property(assign, nonatomic)float Appointment_remarkHeight;
@property(assign ,nonatomic) long long Appointment_longID;//预约编号
@property(copy ,nonatomic) NSString * Appointment_taskBackDate;//回访时间
@property(copy ,nonatomic) NSString * Appointment_serviceDate;//服务时间
@property (nonatomic, strong) NSMutableArray *accountArray;

@property(copy ,nonatomic) NSString * Appointment_servicename;//服务名称
@property(assign ,nonatomic) long long Appointment_serviceCode;//服务Code

@property(assign ,nonatomic) int  Appointment_status;
@property(copy ,nonatomic) NSString * Appointment_statusStr;

@property(assign ,nonatomic) NSInteger  Appointment_assignType;//指定 1   到店指定 0
@property(assign ,nonatomic) NSInteger Appointment_servicePersonalID;//预约指定人ID
@property(copy ,nonatomic) NSString * Appointment_servicePersonal;//预约指定人name

//order
@property(copy ,nonatomic) NSString * Appointment_orderNumber;
@property(assign , nonatomic) NSInteger Appointment_orderID;
@property(assign , nonatomic) NSInteger Appointment_orderObjectID;

@property(assign ,nonatomic) NSInteger  Appointment_ReservedOrderID;//预约的存单OrderID,预约新单的时候可以不传)
@property(assign ,nonatomic) NSInteger  Appointment_ReservedOrderServiceID;//(预约存单的OrderObjectID,预约新单的时候可以不传
@property(assign ,nonatomic) NSInteger Appointment_ReservedOrderType;
@property(assign ,nonatomic) NSInteger Appointment_ExecutingOrderNumber;

@end
