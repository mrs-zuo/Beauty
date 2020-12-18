//
//  RemindDoc.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-8.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemindDoc : NSObject

//@property(copy, nonatomic) NSString *remind_Type;
//@property(copy, nonatomic) NSString *remind_Time;
//@property(copy, nonatomic) NSString *remind_Name;
//@property(copy, nonatomic) NSString *remind_Counselor;
//@property(copy, nonatomic) NSString *remind_Person;
//@property(assign, nonatomic) NSInteger remind_ExecutorID;
//@property(assign, nonatomic) NSInteger remind_ResponsiblePersonID;
//@property(copy, nonatomic) NSString *remind_ExecutorHeadImage;
//@property(copy, nonatomic) NSString *remind_ResponsiblePersonHeadImage;
//@property(copy, nonatomic) NSString *remind_DapartmentPhone;
//@property(copy, nonatomic) NSString *remind_ExecutorNum;
//@property(copy, nonatomic) NSString *remind_ResponsiblePersonNum;
//@property(assign, nonatomic) BOOL remind_ExecutorChat_Use;
//@property(assign, nonatomic) BOOL remind_ResponsiblePersonChat_Use;

@property(copy, nonatomic) NSString *remind_Type;
@property(nonatomic,assign) NSInteger ResponsiblePersonID;
@property(nonatomic,assign) NSInteger TaskStatus;
@property(nonatomic,assign) NSInteger TaskType;
@property(nonatomic,copy) NSString * ResponsiblePersonName;
@property(nonatomic,copy) NSString * BranchPhone;
@property(nonatomic,copy) NSString * BranchName;
@property(nonatomic,copy) NSString * CustomerName;
@property(nonatomic,copy) NSString * TaskName;
@property(nonatomic,assign) long long TaskID;
@property(nonatomic,copy) NSString * TaskScdlStartTime;
@property(nonatomic,assign) BOOL  ResponsiblePersonChat_Use;
@property(copy, nonatomic) NSString *remind_ExecutorNum;
@property(copy, nonatomic) NSString *HeadImageURL;



@end
