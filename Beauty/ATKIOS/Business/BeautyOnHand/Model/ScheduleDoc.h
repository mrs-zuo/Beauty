//
//  ScheduleDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleDoc : NSObject<NSCopying>

@property (assign, nonatomic) NSInteger sch_ID;
@property (copy, nonatomic) NSString *sch_ScheduleTime;

@property (strong, nonatomic, readonly) NSString *completedStr;
@property (assign, nonatomic) NSInteger sch_Completed;  // 是否完成      0未完成  1已完成  2待确认

@property (assign, nonatomic) NSInteger ctlFlag;   // 默认0 添加1  修改2 删除3

@end
