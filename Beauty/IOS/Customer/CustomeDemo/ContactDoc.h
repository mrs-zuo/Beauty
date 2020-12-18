//
//  ContractDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ScheduleDoc;
@interface ContactDoc : NSObject<NSCopying>
@property (assign, nonatomic) NSInteger cont_ID;
@property (copy, nonatomic) NSString *cont_Remark;
@property (strong, nonatomic) ScheduleDoc *cont_Schedule;



@end
