//
//  OrderDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "OrderDoc.h"
#import "PaymentDoc.h"

@implementation OrderDoc

- (id)init
{
    self = [super init];
    if (self) {
       
       // self.productType = 0;
        self.order_Status = 0;
        self.order_Ispaid = 0;
        self.order_Payment = [[PaymentDoc alloc] init];
        self.courseArray   = [NSMutableArray array];
        self.contractArray = [NSMutableArray array];
        self.productArray  = [NSMutableArray array];
       
    }
    return self;
}

- (void)setOrder_Status:(NSInteger)order_Status
{
    _order_Status = order_Status;
    
    switch (_order_Status) {
        case 1: _order_StatusStr = @"未完成";  break;
        case 2: _order_StatusStr = @"已完成";  break;
        case 3: _order_StatusStr = @"已取消";  break;
        case 4: _order_StatusStr = @"已终止";  break;
        default: break;
    }
    
    switch (_order_Status) {
        case 1: _order_StatusStrForCommodity = @"未完成";  break;
        case 2: _order_StatusStrForCommodity = @"已完成";  break;
        case 3: _order_StatusStrForCommodity = @"已取消";  break;
        case 4: _order_StatusStrForCommodity = @"已终止";  break;
        default: break;
    }
}

- (void)setOrder_Ispaid:(NSInteger)order_Ispaid
{
    _order_Ispaid = order_Ispaid;
    if (_order_Ispaid == 1)
        _order_IspaidStr = @"未支付";
    else if(_order_Ispaid == 3)
        _order_IspaidStr = @"已支付";
    else if(_order_Ispaid == 2)
        _order_IspaidStr = @"部分付";
    else if(_order_Ispaid == 4)
        _order_IspaidStr = @"已退款";
    else if(_order_Ispaid == 5)
        _order_IspaidStr = @"免支付";
}

-(void)setOrder_TGStatus:(int)order_TGStatus
{
    _order_TGStatus = order_TGStatus;
    switch (order_TGStatus) {
        case 1:
            self.order_TGStatusStr = @"进行中";
            break;
        case 2:
            self.order_TGStatusStr = @"已完成";
            break;
        case 3:
            self.order_TGStatusStr = @"已取消";
            break;
        case 4:
            self.order_TGStatusStr = @"已终止";
            break;
        case 5:
            self.order_TGStatusStr = @"待确认";
            break;
        default:
            self.order_TGStatusStr = @"";
            break;
    }
}

- (void)setProductType:(NSInteger)productType
{
    _productType = productType;
    if (_productType == 0) {
        if (_totalCount ==0) {
             _productTypeStatus = [NSString stringWithFormat:@"服务%ld次/不限次",(long)_finisHedCount];
        }else
            _productTypeStatus = [NSString stringWithFormat:@"服务%ld次/共%ld次",(long)_finisHedCount ,(long)_totalCount ];
    }else if (_productType == 1)
        _productTypeStatus = [NSString stringWithFormat:@"交付%ld件/共%ld件",(long)_finisHedCount,(long)_totalCount];
}

- (void)setTGStatus:(NSInteger)tGStatus{
    _tGStatus = tGStatus;
    
    switch (_tGStatus) {
        case 1: _tG_StatusStr = @"进行中";  break;
        case 2: _tG_StatusStr = @"已完成";  break;
        case 3: _tG_StatusStr = @"已取消";  break;
        case 4: _tG_StatusStr = @"已终止";  break;
        case 5: _tG_StatusStr = @"完成待确认";  break;
        default:_tG_StatusStr =@""; break;
    }
    
  
}



@end
