//
//  TaskModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskModel : NSObject
@property (nonatomic, assign) long long TaskID;
@property (nonatomic, strong) NSString *ResponsiblePersonName;
@property (nonatomic, strong) NSString *TaskScdlStartTime;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
