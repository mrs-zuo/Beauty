//
//  TreatmentDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScheduleDoc;
@interface TreatmentDoc : NSObject<NSCopying>

@property (assign, nonatomic) NSInteger treat_ID;
@property (copy, nonatomic) NSString *treat_Code;
@property (strong, nonatomic) ScheduleDoc *schedule;
@property (copy, nonatomic) NSString *treat_Remark;

@property (assign, nonatomic) NSInteger treat_AccID;
@property (copy, nonatomic) NSString *treat_AccName;
@property (copy, nonatomic) NSString *treat_SubServiceName;
@property (assign, nonatomic) NSInteger status_RemarkCnt;     // 是否填写了备注
@property (assign, nonatomic) NSInteger status_PictureCnt;      // 是否上传了图片
@property (assign, nonatomic) NSInteger status_AppraiseCnt;   // 是否评价了treatment

@property (assign, nonatomic) CGFloat height_Treat_Remark;

@end
