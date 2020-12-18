//
//  ProgressHistoryDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-7-31.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgressDoc : NSObject
@property (assign, nonatomic) NSInteger customerId;

@property (assign, nonatomic) NSInteger prg_ID;
@property (assign, nonatomic) NSInteger prg_OpportunityID;
@property (assign, nonatomic) NSInteger prg_ProductId;
@property (assign, nonatomic) NSInteger prg_Progress;
@property (assign, nonatomic) NSInteger prg_Count;
@property (copy, nonatomic) NSString *prg_ProgressStr;
@property (copy, nonatomic) NSString *prg_Describle;
@property (copy, nonatomic) NSString *prg_UpdateTime;

@property (assign, nonatomic) CGFloat height_Prg_Describle;
@end
