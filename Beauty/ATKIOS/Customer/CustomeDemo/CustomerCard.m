//
//  CustomerCard.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/7.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "CustomerCard.h"

@implementation CustomerCard
- (instancetype)init
{
    self = [super init];
    if (self) {
        _userCardNo = 0;
    }
    return self;
}

-(void)setCardTypeID:(NSInteger)cardTypeID
{
    _cardTypeID = cardTypeID;
    switch (_cardTypeID) {
        case 1:
            _paymentMode = @"1";
            break;
        case 2:
             _paymentMode = @"6";
            break;
        case 3:
             _paymentMode = @"7";
            break;
            
        default:
            break;
    }
}

@end
