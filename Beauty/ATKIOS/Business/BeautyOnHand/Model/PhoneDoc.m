//
//  PhoneDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "PhoneDoc.h"

@implementation PhoneDoc
@synthesize phoneType;
@synthesize ctlFlag;
@synthesize ph_Type;

- (void)setPh_Type:(NSInteger)newPh_Type
{
    ph_Type = newPh_Type;
    [self setPhoneTypeByType];
}

- (void)setPhoneTypeByType
{
    switch (self.ph_Type) {
        case 0: phoneType = @"手机";  break;
        case 1: phoneType = @"住宅";  break;
        case 2: phoneType = @"工作";  break;
        case 3: phoneType = @"其他";  break;
        default:
            break;
    }
}

@end
