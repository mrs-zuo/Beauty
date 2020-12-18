//
//  ServicePara.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ServicePara.h"
#import "NSDate+Convert.h"
#import "AppDelegate.h"
#import "UserDoc.h"
#import "MJExtension.h"

@implementation ServicePara


-(instancetype)init
{
    if (self = [super init]) {
        _ServicePIC = ACC_ACCOUNTID;
        _ServicePICName = ACC_ACCOUNTName;
        _ProductType = -1;
        _Status = -1;
        _FilterByTimeFlag = 1; //有日期
        _StartTime = [NSDate dateToString:[NSDate date] dateFormat:@"yyyy-MM-dd"];
        _EndTime = [NSDate dateToString:[NSDate date] dateFormat:@"yyyy-MM-dd"];
        _PageIndex = 1;
        _PageSize = 10;
        _TGStartTime = @"";
        _accountArray = [NSMutableArray array];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_ServicePIC) forKey:@"ServicePIC"];
    [aCoder encodeObject:@(_ProductType) forKey:@"ProductType"];
    [aCoder encodeObject:@(_Status) forKey:@"Status"];
    [aCoder encodeObject:@(_FilterByTimeFlag) forKey:@"FilterByTimeFlag"];
    [aCoder encodeObject:@(_PageIndex) forKey:@"PageIndex"];
    [aCoder encodeObject:@(_PageSize) forKey:@"PageSize"];
    [aCoder encodeObject:@(_CustomerID) forKey:@"CustomerID"];
    [aCoder encodeObject:_TGStartTime forKey:@"TGStartTime"];
    [aCoder encodeObject:_StartTime forKey:@"StartTime"];
    [aCoder encodeObject:_EndTime forKey:@"EndTime"];
    [aCoder encodeObject:_ServicePICName forKey:@"ServicePICName"];
    [aCoder encodeObject:_CustomerName forKey:@"CustomerName"];
    [aCoder encodeObject:_accountArray forKey:@"accountArray"];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        _ServicePIC = [[aDecoder decodeObjectForKey:@"ServicePIC"] integerValue];
        _ProductType = [[aDecoder decodeObjectForKey:@"ProductType"] integerValue];
        _Status = [[aDecoder decodeObjectForKey:@"Status"] integerValue];
        _FilterByTimeFlag = [[aDecoder decodeObjectForKey:@"FilterByTimeFlag"] integerValue];
        _PageIndex = [[aDecoder decodeObjectForKey:@"PageIndex"] integerValue];
        _PageSize = [[aDecoder decodeObjectForKey:@"PageSize"] integerValue];
        _CustomerID = [[aDecoder decodeObjectForKey:@"CustomerID"] integerValue];
        
        _TGStartTime = [aDecoder decodeObjectForKey:@"TGStartTime"];
        _StartTime = [aDecoder decodeObjectForKey:@"StartTime"];
        _EndTime = [aDecoder decodeObjectForKey:@"EndTime"];
        _ServicePICName = [aDecoder decodeObjectForKey:@"ServicePICName"];
        _CustomerName = [aDecoder decodeObjectForKey:@"CustomerName"];
        _accountArray = [aDecoder decodeObjectForKey:@"accountArray"];
    }
    return  self;
}

@end
