//
//  TreatmentDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScheduleDoc.h"


typedef NS_ENUM(NSInteger, GROUPTREATCOMPLETE)
{
    GROUPTREATCOMPLETENONE = -1,
    GROUPTREATCOMPLETENOTALL = 0,
    GROUPTREATCOMPLETEALL = 1
};
typedef NS_ENUM(NSInteger, GROUPTREATREPLY)
{
    GROUPTREATREPLYNONE = -1,
    GROUPTREATREPLYNOTALL = 0,
    GROUPTREATREPLYALL = 1
};
typedef NS_ENUM(NSInteger, GROUPSTATUS)
{
    GROUPSTATUSNONE = -1,
    GROUPSTATUSDELETE = 0,
    GROUPSTATUSCOMLETE = 1,
    GROUPSTATUSALL = 2
};


@interface TreatmentGroup : NSObject
@property (nonatomic, assign) NSInteger groupNumber;
@property (nonatomic, assign) NSInteger groupCount;
@property (nonatomic, assign) NSInteger memberState;

@property (nonatomic, strong) NSString *treatList;
@property (nonatomic, strong) NSString *groupList;

@property (nonatomic, assign) long long groupID;

@property (nonatomic, assign) GROUPTREATCOMPLETE COMPLETE;

@property (nonatomic, assign) GROUPTREATREPLY   REPLY;

@property (nonatomic, assign) GROUPSTATUS STATUS;
@end



@interface TreatmentDoc : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger treat_Number;
@property (assign, nonatomic) NSInteger treat_ID;
@property (copy, nonatomic) NSString *treat_Remark;
@property (strong, nonatomic) ScheduleDoc *treat_Schedule;

@property (nonatomic, copy) NSString *treat_CodeString;
@property (assign, nonatomic) NSInteger treat_AccID;
@property (copy, nonatomic) NSString *treat_AccName;
@property (nonatomic, strong) NSString *treatGroup;

@property (assign, nonatomic) NSInteger status_RemarkCnt;     // 是否填写了备注
@property (assign, nonatomic) NSInteger status_PictureCnt;    // 是否上传了图片
@property (assign, nonatomic) NSInteger status_AppraiseCnt;   // 是否评价了treatment
@property (nonatomic, assign) BOOL status_Designated;  //是否指定
@property (copy, nonatomic) NSString *treat_SubServiceName;
@property (assign, nonatomic) CGFloat height_Treat_Remark;

@property (assign, nonatomic) NSInteger ctlFlag;   // 默认0 添加1  修改2 删除3
@end


