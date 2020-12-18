//
//  DeviceInfoManager.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/27.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
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
