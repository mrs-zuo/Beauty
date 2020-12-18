//
//  NoticeDoc.h
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-6.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoticeDoc : NSObject

@property (assign,nonatomic) NSInteger company_ID;

@property(copy,nonatomic) NSString *notice_Id;
@property(copy,nonatomic) NSString *NoticeTitle;//notice_Title;
@property(copy,nonatomic) NSString *NoticeContent;//notice_Content;
@property(copy,nonatomic) NSString *StartDate;//notice_StartDate;
@property(copy,nonatomic) NSString *EndDate;//notice_EndDate;
@property(copy,nonatomic) NSString *notice_Available;
@property(copy,nonatomic) NSString *notice_CreaterId;
@property(copy,nonatomic) NSString *notice_CreaterTime;
@property(copy,nonatomic) NSString *notice_UpdaterId;
@property(copy,nonatomic) NSString *notice_UpdaterTime;

- (id)initWithDictionary:(NSDictionary *)dictionary;
@end
