//
//  DeviceInfoManager.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/31.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DeviceInfoManager.h"
#import <sys/utsname.h>

@implementation DeviceInfoManager

+ (NSString *)DeviceInfoOfType
{
    struct utsname deviceInfo;
    uname(&deviceInfo);
    NSString *info = [NSString stringWithCString:deviceInfo.machine encoding:NSUTF8StringEncoding];
    return info;
}

@end
