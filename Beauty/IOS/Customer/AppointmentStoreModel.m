//
//  AppointmentStoreModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "AppointmentStoreModel.h"

@implementation AppointmentStoreModel

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"UndefinedKey :%@",key);
}

@end
