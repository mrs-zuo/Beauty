//
//  UUID.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-4.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "UUID.h"

@implementation UUID
static id uuid;
+ (NSString *)getUUID{
    if ([uuid length] > 0)
        return uuid;
    else
        return @"";
}

+ (void)setUUID:(NSString *)UUIDString
{

    uuid = [UUIDString copy];
}
@end
