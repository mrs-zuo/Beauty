//
//  TreatmentDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "TreatmentDoc.h"
#import "ScheduleDoc.h"

@implementation TreatmentDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.schedule = [[ScheduleDoc alloc] init];
        self.treat_Remark = @"";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TreatmentDoc *newTreatment = [[TreatmentDoc allocWithZone:zone] init];
    [newTreatment setTreat_ID:_treat_ID];
    [newTreatment setSchedule:[_schedule copy]];
    [newTreatment setTreat_Remark:_treat_Remark];
    
    return newTreatment;
}

- (void)setTreat_Remark:(NSString *)treat_Remark
{
    _treat_Remark = treat_Remark;
    CGFloat currentHeight = [treat_Remark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    _height_Treat_Remark = currentHeight;
}

@end
