//
//  ZXVisitTableViewCell.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/26.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXVisitTableViewCell.h"
#import "AppointmentDoc.h"

@implementation ZXVisitTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(id)data
{
    if ([data isKindOfClass:[AppointmentDoc class]]) {
        AppointmentDoc *doc = (AppointmentDoc *)data;
        switch (doc.visit_status) {
            case 2: //待会放
            {
                _dateLab.textColor = [UIColor lightGrayColor];
                [_statusBtn setBackgroundColor:[UIColor orangeColor]];
            }
                break;
            case 3:
            {
                _dateLab.textColor = [UIColor blackColor];
                [_statusBtn setBackgroundColor:KColor_Blue];
            }
                break;
                
            default:
                break;
        }
        [_statusBtn setTitle:doc.visit_statusStr forState:UIControlStateNormal];
        _dateLab.text = doc.Appointment_date;
        _cusNameLab.text = doc.Appointment_customer;
        _serviceName.text = doc.Appointment_servicename;
        _typeNameLab.text = doc.visit_TypeStr;
    }
}

//
////    cell.dateLable.text = [NSString stringWithFormat:@"%@",appointDoc.Appointment_date];
//
////    cell.dateLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_statusStr,appointDoc.Appointment_date];
//    cell.dateLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.visit_statusStr,appointDoc.Appointment_date];
//
//
//    cell.serviceNameLable.text = appointDoc.Appointment_servicename;
//
////    cell.statusLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_customer,appointDoc.Appointment_TaskTypeStr];
//    cell.statusLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_customer,appointDoc.visit_TypeStr];

@end
