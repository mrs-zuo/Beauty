//
//  getScheduleDetailModal.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "getScheduleDetailModal.h"

@implementation getScheduleDetailModal

-(instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
        
    }
    return self;
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}


-(void)setTaskStatus:(int)TaskStatus
{
    _TaskStatus = TaskStatus;
    switch (_TaskStatus) {
        case 1:
            _TaskStatusString = @"待确认";
            break;
        case 2:
            _TaskStatusString = @"已确认";
            break;
        case 3:
            _TaskStatusString = @"已执行";
            break;
        case 4:
            _TaskStatusString = @"已取消";
            break;
            
        default:
            _TaskStatusString = @"";
            break;
    }
}

@end
