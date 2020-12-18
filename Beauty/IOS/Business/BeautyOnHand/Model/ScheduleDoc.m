//
//  ScheduleDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "ScheduleDoc.h"

@implementation ScheduleDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.sch_Completed = 0;
    }
    return self;
}

- (void)setSch_Completed:(NSInteger)completed
{
    _sch_Completed = completed;
    
    if (_sch_Completed == 0) {
        _completedStr = @"未完成";
    } else if (_sch_Completed == 1) {
        _completedStr = @"已完成";
    } else if (_sch_Completed == 2){
        _completedStr = @"待顾客确认";
    } else if (_sch_Completed == 4){
        _completedStr = @"过去完成";
    }
}

-(id)copyWithZone:(NSZone *)zone
{
    ScheduleDoc *newSchedule = [[ScheduleDoc allocWithZone:zone] init];
    [newSchedule setSch_ID:_sch_ID];
    [newSchedule setSch_ScheduleTime:_sch_ScheduleTime];
    [newSchedule setSch_Completed:_sch_Completed];
    [newSchedule setCtlFlag:_ctlFlag];
    
    return newSchedule;
}

@end
