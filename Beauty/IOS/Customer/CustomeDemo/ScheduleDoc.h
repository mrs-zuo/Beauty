//
//  ScheduleDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-8-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleDoc : NSObject
@property (assign, nonatomic) NSInteger sch_TempID;  //在修改订单时  临时添加schedule时sch_ID=0此时sch_TempID 当做临时唯一ID
@property (assign, nonatomic) NSInteger sch_ID;
@property (assign, nonatomic) NSInteger sch_Type;    // 0疗程 1回诊 2联系
@property (assign, nonatomic) NSInteger sch_Status;  // 0未完成  1已完成 2待确认
@property (copy, nonatomic) NSString *sch_Time;
@property (assign, nonatomic) NSInteger ctlFlag; // 默认0 更改和添加1  删除2
@property (copy, nonatomic) NSString *sch_ScheduleTime;
@property (assign, nonatomic) NSInteger sch_Reminded;   // 0未提醒  1已提醒
@property (assign, nonatomic) NSInteger sch_Completed;  // 0未完成  1已完成 2待确认
@property (strong, nonatomic, readonly) NSString *completedStr;

@property (assign, nonatomic) NSInteger sch_RemarkCnt;
@property (assign, nonatomic) NSInteger sch_ImageCnt;

+ (NSString *)getStrScheduleId:(NSArray *)array;
+ (NSString *)getStrType:(NSArray *)array;
+ (NSString *)getStrTime:(NSArray *)array;
+ (NSString *)getStrStatus:(NSArray *)array;
+ (NSString *)getCtlFlag:(NSArray *)array;
@end
