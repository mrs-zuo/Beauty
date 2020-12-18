//
//  AppointmentBuyModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/12/1.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "AppointmentBuyModel.h"

@implementation AppointmentBuyModel


- (id)init
{
    self = [super init];
    if (self) {
    
        
    }
    return self;
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
@end
