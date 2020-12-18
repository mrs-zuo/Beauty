//
//  AppointmentDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentDoc.h"

@implementation AppointmentDoc


- (id)init{
    self = [super init];
    if(self){
        _accountArray = [NSMutableArray array];
        _Appointment_branchName = @"";
        _Appointment_customer = @"";
        _Appointment_customerID = 0;
        _Appointment_date = @"";
        _Appointment_longID = 0;
        _Appointment_number = 0;
        _Appointment_remark = @"";
        _Appointment_ReservedOrderID = 0;
        _Appointment_ReservedOrderServiceID = 0;
        _Appointment_ReservedOrderType = 0;
        _Appointment_serviceCode = 0;
        _Appointment_servicename = @"";
        _Appointment_servicePersonal = @"";
        _Appointment_servicePersonalID = 0;
        _Appointment_status = 0;
        _Appointment_statusStr = @" ";
        _Appointment_TaskType = 0;
        _Appointment_assignType = 0;
        _Appointment_TaskTypeStr = @"" ;
        _Appointment_taskBackDate = @"" ;
        _Appointment_serviceDate = @"" ;
        _Appointment_ExecutingOrderNumber = 0;
        _Appointment_orderNumber = @"";
        _Appointment_orderID = 0 ;
        _Appointment_orderObjectID = 0 ;
        _Appointment_TaskBackContent = @"" ;
    }
    return self;
}
-(void)setVisit_status:(int)visit_status
{
    _visit_status = visit_status;
    switch (_visit_status) {
        case -1: _visit_statusStr = @"全部";  break;
        case 2: _visit_statusStr = @"待回访";  break;
        case 3: _visit_statusStr = @"已完成";  break;
        default:
            _visit_statusStr = @" ";
            break;
    }
}
-(void)setVisit_Type:(NSInteger)visit_Type
{
    _visit_Type = visit_Type;
    switch (_visit_Type) {
        case 2: _visit_TypeStr = @"订单";  break;
        case 4: _visit_TypeStr = @"生日";  break;
        default:
            _visit_TypeStr = @" ";
            break;
    }
}

- (void)setAppointment_status:(int)status
{
    _Appointment_status = status;
    switch (_Appointment_status) {
        case -1: _Appointment_statusStr = @"全部";  break;
        case 1: _Appointment_statusStr = @"待确认";  break;
        case 2: _Appointment_statusStr = @"已确认";  break;
        case 3: _Appointment_statusStr = @"已开单";  break;
        case 4: _Appointment_statusStr = @"已取消";  break;
        default:
            _Appointment_statusStr = @" ";
            break;
    }
}

-(void)setAppointment_TaskType:(NSInteger)Tasktype
{
    _Appointment_TaskType = Tasktype;
    switch (_Appointment_TaskType) {
        case 0: _Appointment_TaskTypeStr = @"所有任务";   break;
        case 1: _Appointment_TaskTypeStr = @"服务预约";  break;
        case 2: _Appointment_TaskTypeStr = @"订单回访";  break;
        case 3: _Appointment_TaskTypeStr = @"联系任务";  break;
        case 4: _Appointment_TaskTypeStr = @"生日回访";  break;
        default:
            _Appointment_statusStr = @" ";
            break;
    }

}

- (BOOL)isMyAppointment
{
    if (self.Appointment_servicePersonalID == ACC_ACCOUNTID) {
        return YES;
    } else {
        return NO;
    }
}

- (AppointmentEdit)appointEditStatus
{
    if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        if ([self isMyAppointment]) {
            _appointEditStatus = AppointmentEditExist;
        } else {
            if ([[PermissionDoc sharePermission] rule_AllOrder_Write]) {
                _appointEditStatus = AppointmentEditExist;
            } else {
                _appointEditStatus = AppointmentEditNone;
            }
        }
    } else {
        _appointEditStatus = AppointmentEditNone;
    }
    return _appointEditStatus;
}
@end
