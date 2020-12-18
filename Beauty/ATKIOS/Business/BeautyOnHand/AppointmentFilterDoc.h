//
//  AppointmentFilterDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppointmentFilterDoc : NSObject
@property (strong,nonatomic) NSMutableArray *taskTypeArrs;
@property (strong,nonatomic) NSString *startTime;;
@property (strong,nonatomic) NSString *endTime;
@property (assign,nonatomic) int  status;
@property (copy,nonatomic) NSString *statusStr;
@property (assign,nonatomic) NSInteger FilterByTimeFlag;//(是否有时间范围 0:否 1:是)
@property (assign,nonatomic) NSInteger PageIndex;
@property (assign,nonatomic) NSInteger PageSize;
@property (strong,nonatomic) NSMutableArray * ResponsiblePersonsArr;
@property (assign,nonatomic) NSInteger CustomerID;
@property (copy,nonatomic) NSString * CustomerName;
@property (copy,nonatomic) NSString * ResponsiblePersonNames;

@property (assign, nonatomic) NSInteger account_Id;
@property (strong, nonatomic) NSString *account_Name;
@property (nonatomic, strong) NSString *account_IDs;

@end
