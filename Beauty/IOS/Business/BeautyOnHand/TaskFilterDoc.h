//
//  TaskFilterDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/19.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskFilterDoc : NSObject

@property (nonatomic,strong) NSMutableArray *TaskTypeArrs;

@property (assign,nonatomic) NSInteger TaskType;//0:所有任务 1:服务预约 2:订单回访 3:联系任务
@property (copy, nonatomic) NSString * TaskTypeStr;

@property (strong,nonatomic) NSMutableArray * ResponsiblePersonsArr;
@property (copy,nonatomic) NSString * ResponsiblePersonNames;

@property (assign,nonatomic) int  status;
@property (copy,nonatomic) NSString *statusStr;

@property (assign,nonatomic) NSInteger PageIndex;
@property (assign,nonatomic) NSInteger PageSize;
@property(copy ,nonatomic) NSString * customerName;//顾客
@property(assign ,nonatomic) NSInteger customerID;//顾客ID

@property (assign, nonatomic) NSInteger account_Id;
@property (strong, nonatomic) NSString *account_Name;
@property (nonatomic, strong) NSString *account_IDs;

@end

