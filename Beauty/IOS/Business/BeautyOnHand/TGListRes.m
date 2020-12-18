//
//  TGListRes.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "TGListRes.h"

@implementation TGListRes

-(void)setPaymentStatus:(NSInteger)PaymentStatus
{
    _PaymentStatus = PaymentStatus;
    switch (_PaymentStatus) {
        case 1: _PaymentStatusStr = @"未支付";  break;
        case 2: _PaymentStatusStr = @"部分付";  break;
        case 3: _PaymentStatusStr = @"已支付";  break;
        case 4: _PaymentStatusStr = @"已退款";break;
        case 5: _PaymentStatusStr = @"免支付";break;
        default:
            break;
    }

}
-(void)setStatus:(NSInteger)Status
{
    _Status = Status;
    switch (_Status) {
        case 1: _StatusStr = @"未完成";  break;
        case 5: _StatusStr = @"待确认";  break;
        case 2: _StatusStr = @"已完成";break;
        default:
            break;
    }
}
@end
