//
//  CourseDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TreatmentDoc.h"

@interface CourseDoc : NSObject<NSCopying>

@property (assign, nonatomic) NSInteger course_ID;
//@property (assign, nonatomic) NSInteger course_AccountID;
//@property (copy, nonatomic) NSString *course_AccountName;
@property (strong, nonatomic) NSMutableArray *treatmentArray;  // 保存着TreatmentDoc对象
@property (nonatomic, assign) NSInteger group_count;

@property (assign, nonatomic) int ctlFlag; // 0默认 1添加 2修改  3删除
@end
