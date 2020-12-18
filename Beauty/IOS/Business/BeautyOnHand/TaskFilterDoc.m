//
//  TaskFilterDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/19.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TaskFilterDoc.h"
@interface TaskFilterDoc () <NSCopying>

@end;
@implementation TaskFilterDoc

- (id)init{
    self = [super init];
    if(self){
        _TaskType = -1;
        _TaskTypeStr = @"";
        _PageIndex = 1;
        _PageSize = 10;
        _customerName = @"";
        _customerID = 0;
        _ResponsiblePersonsArr = [[NSMutableArray alloc] init];
        _TaskTypeArrs = [[NSMutableArray alloc]init];
    }
    return self;
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


-(void)setTaskType:(NSInteger)Tasktype
{
    _TaskType = Tasktype;
    switch (_TaskType) {
        case 0: _TaskTypeStr = @"所有任务";   break;
        case 1: _TaskTypeStr = @"服务预约";  break;
        case 2: _TaskTypeStr = @"订单回访";  break;
        case 3: _TaskTypeStr = @"联系任务";  break;
        case 4: _TaskTypeStr = @"生日回访";  break;
        default:
            _TaskTypeStr = @" ";
            break;
    }
    
}



;



-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_PageIndex forKey:@"PageIndex"];
    [aCoder encodeInteger:_PageSize forKey:@"PageSize"];
    [aCoder encodeInteger:_customerID forKey:@"customerID"];
    [aCoder encodeInteger:_account_Id forKey:@"account_Id"];
    [aCoder encodeObject:_customerName forKey:@"customerName"];
    [aCoder encodeObject:_account_Name forKey:@"account_Name"];
    [aCoder encodeObject:_account_IDs forKey:@"account_IDs"];
    [aCoder encodeInt:_status forKey:@"status"];
    [aCoder encodeObject:_statusStr forKey:@"statusStr"];
    [aCoder encodeInteger:_TaskType forKey:@"TaskType"];
    [aCoder encodeObject:_TaskTypeStr forKey:@"TaskTypeStr"];
    [aCoder encodeObject:_ResponsiblePersonsArr forKey:@"ResponsiblePersonsArr"];
    [aCoder encodeObject:_ResponsiblePersonNames forKey:@"ResponsiblePersonNames"];

    [aCoder encodeObject:_TaskTypeArrs forKey:@"TaskTypeArrs"];

}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]){
        _PageIndex = [aDecoder decodeIntegerForKey:@"PageIndex"];
        _PageSize = [aDecoder decodeIntegerForKey:@"PageSize"];
        _customerID = [aDecoder decodeIntegerForKey:@"customerID"];
        _account_Id = [aDecoder decodeIntegerForKey:@"account_Id"];
        _customerName = [aDecoder decodeObjectForKey:@"customerName"];
        _account_Name = [aDecoder decodeObjectForKey:@"account_Name"];
        _account_IDs = [aDecoder decodeObjectForKey:@"account_IDs"];
        _ResponsiblePersonNames = [aDecoder decodeObjectForKey:@"ResponsiblePersonNames"];        
        _status = [aDecoder decodeIntForKey:@"status"];
        _statusStr = [aDecoder decodeObjectForKey:@"statusStr"];
        _ResponsiblePersonsArr = [aDecoder decodeObjectForKey:@"ResponsiblePersonsArr"];
        _TaskTypeArrs = [aDecoder decodeObjectForKey:@"TaskTypeArrs"];
        _TaskType = [aDecoder decodeIntegerForKey:@"TaskType"];
        _TaskTypeStr = [aDecoder decodeObjectForKey:@"TaskTypeStr"];
        
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

@end
