//
//  RecordDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-7-5.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordDoc : NSObject //<NSCoding>

@property (assign, nonatomic) NSInteger customer_Id;
@property (copy, nonatomic) NSString *customer_Name;

@property (assign, nonatomic) NSInteger rec_Id;
@property (assign, nonatomic) NSInteger rec_Type;
@property (copy, nonatomic) NSString *rec_Problem;
@property (copy, nonatomic) NSString *rec_Suggestion;
@property (copy, nonatomic) NSString *rec_Time;
@property (copy, nonatomic) NSString *rec_CreatorName;
@end
