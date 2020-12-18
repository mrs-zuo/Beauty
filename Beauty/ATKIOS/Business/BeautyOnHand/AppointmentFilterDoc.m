//
//  AppointmentFilterDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentFilterDoc.h"

@implementation AppointmentFilterDoc

- (id)init{
    self = [super init];
    if(self){
        _startTime = @"";
        _endTime = @"";
        _status = -1;
        _FilterByTimeFlag = 0;
        _PageIndex = 1;
        _PageSize = 10;
        _CustomerID = 0;
        _ResponsiblePersonsArr = [NSMutableArray array];
        _CustomerName = @"全部";
        _ResponsiblePersonNames = @"";
        _taskTypeArrs = [NSMutableArray array];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_startTime forKey:@"startTime"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
    [aCoder encodeObject:_CustomerName forKey:@"CustomerName"];
    [aCoder encodeInteger:_CustomerID forKey:@"CustomerID"];
    [aCoder encodeInteger:_status forKey:@"status"];
    [aCoder encodeObject:_statusStr forKey:@"statusStr"];
    [aCoder encodeInteger:_FilterByTimeFlag forKey:@"FilterByTimeFlag"];
    [aCoder encodeObject:_ResponsiblePersonsArr forKey:@"ResponsiblePersonsArr"];
    [aCoder encodeObject:_taskTypeArrs forKey:@"taskTypeArrs"];

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        _startTime = [aDecoder decodeObjectForKey:@"startTime"];
        _endTime = [aDecoder decodeObjectForKey:@"endTime"];
        _CustomerName = [aDecoder decodeObjectForKey:@"CustomerName"];
        _CustomerID = [aDecoder decodeIntegerForKey:@"CustomerID"];
        _status = [aDecoder decodeIntegerForKey:@"status"];
        _FilterByTimeFlag = [aDecoder decodeIntegerForKey:@"FilterByTimeFlag"];
        _ResponsiblePersonsArr = [aDecoder decodeObjectForKey:@"ResponsiblePersonsArr"];
        _taskTypeArrs = [aDecoder decodeObjectForKey:@"taskTypeArrs"];
        _statusStr = [aDecoder decodeObjectForKey:@"statusStr"];
    }
    return  self;
}

- (NSString *)account_Name
{
    NSArray *nameArray = [_ResponsiblePersonsArr valueForKeyPath:@"@unionOfObjects.user_Name"];
    _account_Name = [nameArray componentsJoinedByString:@"、"];
    return _account_Name;
}

- (NSString *)account_IDs
{
    _account_IDs = @"";
    NSArray *idArray = [_ResponsiblePersonsArr valueForKeyPath:@"@unionOfObjects.user_Id"];
    if (idArray.count) {
        _account_IDs = [idArray componentsJoinedByString:@","];
    }
    return _account_IDs;
}


- (void)setStatus:(int)status
{
    _status = status;
    switch (status) {
        case 0: _statusStr = @"全部";  break;
        case 1: _statusStr = @"待确认";  break;
        case 2: _statusStr = @"已确认";  break;
        case 4: _statusStr = @"已取消";  break;
        case 3: _statusStr = @"已开单";  break;
        default:
            _statusStr = @" ";
            break;
    }
}

@end
