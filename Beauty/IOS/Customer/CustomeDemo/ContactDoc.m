//
//  ContractDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContactDoc.h"
#import "ScheduleDoc.h"

@implementation ContactDoc

- (id)init
{
    self = [super init];
    if (self) {
        _cont_Schedule = [[ScheduleDoc alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ContactDoc *newContact = [[ContactDoc allocWithZone:zone] init];
    [newContact setCont_ID:_cont_ID];
    [newContact setCont_Remark:_cont_Remark];
    [newContact setCont_Schedule:_cont_Schedule];
    
    return newContact;
}

@end
