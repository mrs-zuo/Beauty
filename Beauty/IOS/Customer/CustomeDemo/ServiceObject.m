//
//  ServiceObject.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ServiceObject.h"

@implementation SubServiceObject

@end

@implementation ServiceObject

- (NSString *)description
{
    [super description];
    return [NSString stringWithFormat:@"%ld,%ld",(long)_service_courseFrequency,(long)_service_spendTime];
}
@end
