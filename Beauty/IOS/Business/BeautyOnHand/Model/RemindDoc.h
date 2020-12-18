//
//  RemindDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-9.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, RemindType){
    RemindTypeService,
    RemindTypeBrithday,
    RemindTypeVisit
};
@class AFHTTPRequestOperation;

@interface RemindDoc : NSObject
@property (assign,nonatomic) NSInteger user_ID;

@property(nonatomic)       RemindType remind_Type;
@property(copy, nonatomic) NSString *remind_Time;
@property(copy, nonatomic) NSString *remind_Brith;
@property(copy, nonatomic) NSString *remind_Content;
@property(nonatomic, assign) NSInteger orderID;
@property (nonatomic, assign) CGFloat remind_Height;

+ (AFHTTPRequestOperation *)requestRemindList:(void(^)(NSArray *reminds, NSError *error))block;

@end
