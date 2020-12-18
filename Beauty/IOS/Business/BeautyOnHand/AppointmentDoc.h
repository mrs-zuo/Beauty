//
//  AppointmentDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, AppointmentEdit) {
    AppointmentEditNone,
    AppointmentEditExist
};
@interface AppointmentDoc : NSObject

@property(copy ,nonatomic) NSString * Appointment_date;//预约时间
@property(copy ,nonatomic) NSString * Appointment_taskBackDate;//回访时间
@property(copy ,nonatomic) NSString * Appointment_serviceDate;//服务时间

@property(copy ,nonatomic) NSString * Appointment_orderNumber;
@property(assign , nonatomic) NSInteger Appointment_orderID;
@property(assign , nonatomic) NSInteger Appointment_orderObjectID;

@property(copy ,nonatomic) NSString * Appointment_servicename;//服务名称
@property(assign ,nonatomic) long long Appointment_serviceCode;//服务Code


@property (assign, nonatomic) long long Appointment_number;//预约编号
@property(assign ,nonatomic) int  Appointment_status;
@property(copy ,nonatomic) NSString * Appointment_statusStr;


///回访状态
@property(assign ,nonatomic) int  visit_status;
@property(copy ,nonatomic) NSString * visit_statusStr;

///回访类型
@property(assign ,nonatomic) NSInteger  visit_Type;
@property(copy ,nonatomic) NSString * visit_TypeStr;

@property(copy ,nonatomic) NSString * Appointment_customer;//顾客
@property(assign ,nonatomic) NSInteger  Appointment_customerID;//顾客ID
@property(copy ,nonatomic) NSString * Appointment_branchName;

@property(assign ,nonatomic) NSInteger  Appointment_assignType;//指定 1   到店指定 0
@property(assign ,nonatomic) NSInteger Appointment_servicePersonalID;//预约指定人ID

@property(copy ,nonatomic) NSString * Appointment_servicePersonal;//预约指定人name
@property(copy ,nonatomic) NSString * Appointment_remark;
@property(assign ,nonatomic) long long Appointment_longID;//预约编号
@property (nonatomic, strong) NSMutableArray *accountArray;

@property(assign ,nonatomic) NSInteger  Appointment_ReservedOrderType;
@property(assign ,nonatomic) NSInteger  Appointment_TaskType;//1:服务预约 2:订单回访 3:联系任务
@property(copy ,nonatomic) NSString * Appointment_TaskTypeStr;

@property(assign ,nonatomic) NSInteger  Appointment_ReservedOrderID;//预约的存单OrderID,预约新单的时候可以不传)
@property(assign ,nonatomic) NSInteger  Appointment_ReservedOrderServiceID;//(预约存单的OrderObjectID,预约新单的时候可以不传
@property(assign ,nonatomic) NSInteger Appointment_ExecutingOrderNumber;

@property (copy, nonatomic)NSString * Appointment_TaskBackContent;
@property (nonatomic, assign) AppointmentEdit appointEditStatus;
@end
