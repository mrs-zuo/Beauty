//
//  PaymentHistoryDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PaymentHistoryDoc.h"

@implementation OrderPaymentDoc

@end

@implementation PaymentHistoryDoc
-(instancetype)init
{
    if (self = [super init]) {
        _profitListArrs = [NSMutableArray array];
		_salesConsultantListArrs = [NSMutableArray array];
    }
    return self;
}
@end