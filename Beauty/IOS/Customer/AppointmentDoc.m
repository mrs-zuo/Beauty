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
        _Appointment_date = @"";
        _Appointment_remark = @"";
        _Appointment_servicename = @"";
        _Appointment_servicePersonal = @"";
        _Appointment_statusStr = @" ";
        _Appointment_taskBackDate = @"" ;
        _Appointment_serviceDate = @"" ;

        _Appointment_orderNumber = @"";
        
        

    }
    return self;
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

@end
