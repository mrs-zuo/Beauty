//
//  getScheduleDetailModal.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/9/6.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getScheduleDetailModal : NSObject

@property (assign, nonatomic)long long TaskID;
@property (assign, nonatomic)long long TaskOwnerID;
@property (copy, nonatomic)NSString *TaskOwnerName;
@property (copy, nonatomic)NSString *BranchName;
@property (copy, nonatomic)NSString *TaskScdlStartTime;
@property (assign, nonatomic)long long ProductCode;
@property (copy, nonatomic)NSString *ProductName;
@property (assign, nonatomic)int AccountID;
@property (copy, nonatomic)NSString *AccountName;
@property (assign, nonatomic)int TaskStatus;
@property (copy, nonatomic)NSString *TaskStatusString;
@property (assign, nonatomic)CGFloat TotalSalePrice;
@property (copy, nonatomic)NSString *OrderNumber;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end
