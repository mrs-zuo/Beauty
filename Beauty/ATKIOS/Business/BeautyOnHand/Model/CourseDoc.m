//
//  CourseDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CourseDoc.h"

@implementation CourseDoc

- (id)init
{
    self = [super init];
    if (self) {
        self.treatmentArray = [NSMutableArray array];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    CourseDoc *newCourse = [[CourseDoc allocWithZone:zone] init];
    [newCourse setCourse_ID:_course_ID];
    [newCourse setTreatmentArray:[_treatmentArray mutableCopy]];
    return newCourse;
}

@end
