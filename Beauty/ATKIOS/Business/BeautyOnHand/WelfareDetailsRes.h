//
//  WelfareDetailsRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/2/24.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WelfareDetailsRes : NSObject

@property (nonatomic,copy) NSString *PolicyID;
@property (nonatomic,copy) NSString *PolicyName;
@property (nonatomic,copy) NSString *PolicyDescription;
@property (nonatomic,copy) NSString *PolicyComments;
@property (nonatomic,copy) NSString *GrantDate;
@property (nonatomic,copy) NSString *ValidDate;
@property (nonatomic,copy) NSString *PRCode;
@property (nonatomic,copy) NSString *PRValue1;
@property (nonatomic,copy) NSString *PRValue2;
@property (nonatomic,copy) NSString *PRValue3;
@property (nonatomic,copy) NSString *PRValue4;
@property (nonatomic,copy) NSString *BenefitStatus;
@property (nonatomic,strong) NSMutableArray *BranchList;
               
@end
