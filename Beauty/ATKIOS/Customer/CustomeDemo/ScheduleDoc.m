//
//  ScheduleDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ScheduleDoc.h"

@implementation ScheduleDoc

+ (NSString *)getStrScheduleId:(NSArray *)array
{
    NSMutableString *strScheduleId = [NSMutableString string];
    for (ScheduleDoc *sch in array) {
        [strScheduleId appendFormat:@"%ld,",(long)sch.sch_ID];
    }
    return strScheduleId;
}

+ (NSString *)getStrType:(NSArray *)array
{
    NSMutableString *strType = [NSMutableString string];
    for (ScheduleDoc *sch in array) {
        [strType appendFormat:@"%ld,",(long)sch.sch_Type];
    }
    return strType;
}

+ (NSString *)getStrTime:(NSArray *)array
{
    NSMutableString *strTime = [NSMutableString string];
    for (ScheduleDoc *sch in array) {
        [strTime appendFormat:@"%@,",sch.sch_Time];
    }
    return strTime;
}

+ (NSString *)getStrStatus:(NSArray *)array
{
    NSMutableString *strStatus = [NSMutableString string];
    for (ScheduleDoc *sch in array) {
        [strStatus appendFormat:@"%ld,",(long)sch.sch_Status];
    }
    return strStatus;
}

+ (NSString *)getCtlFlag:(NSArray *)array
{
    NSMutableString *strStatus = [NSMutableString string];
    for (ScheduleDoc *sch in array) {
        [strStatus appendFormat:@"%ld,",(long)sch.ctlFlag];
    }
    return strStatus;
}

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
    } else if (_sch_Completed == 1){
        _completedStr = @"已完成";
    }else if (_sch_Completed == 4){
        _completedStr = @"过去完成";
    }else  {
        _completedStr = @"待确认";
    }
}

-(id)copyWithZone:(NSZone *)zone
{
    ScheduleDoc *newSchedule = [[ScheduleDoc allocWithZone:zone] init];
    [newSchedule setSch_ID:_sch_ID];
    [newSchedule setSch_Type:_sch_Type];
    [newSchedule setSch_ScheduleTime:_sch_ScheduleTime];
    [newSchedule setSch_Reminded:_sch_Reminded];
    [newSchedule setSch_Completed:_sch_Completed];
    [newSchedule setCtlFlag:_ctlFlag];
    
    return newSchedule;
}
@end
