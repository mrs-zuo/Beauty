//
//  CourseDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupDoc : NSObject
@property (assign, nonatomic) NSInteger group_Index;
@property (assign, nonatomic) long long group_ID;
@property (assign, nonatomic) NSInteger group_TreatmentCount;

@end

@interface CourseDoc : NSObject<NSCopying>

@property (assign, nonatomic) long long course_ID;
@property (assign, nonatomic) long long course_AccountID;
@property (copy, nonatomic) NSString *course_AccountName;
@property (strong, nonatomic) NSMutableArray *groupOrTreatmentArray;  // 保存着TreatmentDoc  or  GroupDoc对象
@property (assign, nonatomic) NSInteger course_GroupCount;

@property (assign, nonatomic) int ctlFlag; // 0默认 1添加 2修改  3删除
@end
