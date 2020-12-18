//
//  LoginDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-10-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface BranchDoc: NSObject
@property (assign, nonatomic) NSInteger branchId;
@property (copy, nonatomic) NSString *branchName;
@end


@interface LoginDoc : NSObject
@property (assign,nonatomic) NSInteger accountId;
@property (assign,nonatomic) NSInteger companyId;
@property (assign,nonatomic) NSInteger branchID;  // BranchID == 0 则没有BranchID
@property (assign,nonatomic) NSInteger branchCount;
@property (copy,nonatomic) NSString *userName;
@property (copy,nonatomic) NSString *headImg;
@property (copy,nonatomic)NSString *companyCode;
@property (assign,nonatomic) NSInteger companyScale;  // 0小店  1大店
@property (copy,nonatomic) NSString *moneyIcon;
@property (copy,nonatomic) NSString *companyName;
@property (copy,nonatomic) NSString *advanced;
@property (copy,nonatomic) NSString *companyAbbreviation;//缩写
@property (strong, nonatomic) NSMutableArray *branchList;
///是否使用业绩提成
@property (strong, nonatomic) NSNumber *isComissionCalc;

- (void)loginParameterUserConfig;

@end

