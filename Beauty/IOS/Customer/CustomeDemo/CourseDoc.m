//
//  CourseDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CourseDoc.h"

@implementation GroupDoc


@end

@implementation CourseDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.groupOrTreatmentArray = [NSMutableArray array];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    CourseDoc *newCourse = [[CourseDoc allocWithZone:zone] init];
    [newCourse setCourse_ID:_course_ID];
    [newCourse setCourse_AccountID:_course_AccountID];
    [newCourse setCourse_AccountName:_course_AccountName];
    [newCourse setGroupOrTreatmentArray:[_groupOrTreatmentArray mutableCopy]];
    return newCourse;
}

@end
