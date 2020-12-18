//
//  RecordDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordDoc : NSObject //<NSCoding>

@property (assign, nonatomic) NSInteger CustomerID;
@property (copy, nonatomic) NSString *CustomerName;

@property (assign, nonatomic) NSInteger RecordID;
@property (assign, nonatomic) NSInteger rec_Type;
@property (copy, nonatomic) NSString *Problem;
@property (copy, nonatomic) NSString *Suggestion;
@property (copy, nonatomic) NSString *RecordTime;
@property (assign, nonatomic) NSInteger CreatorID;
@property (copy, nonatomic) NSString *CreatorName;
@property (assign, nonatomic) BOOL IsVisible;
@property (strong, nonatomic) NSString *ResponsiblePersonName;
@property (nonatomic, strong) NSString *tagIDs;
@property (nonatomic, strong) NSString *TagName;
@property (assign, nonatomic) float height_Problem;
@property (assign, nonatomic) float height_Suggestion;

- (id)initWithDic:(NSDictionary *)dic;

@end
