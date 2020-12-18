//
//  BranchInfoModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BranchInfoModel : NSObject
@property (nonatomic, copy) NSString *BranchName;
@property (nonatomic, assign) NSInteger BranchID;

- (instancetype)initWithDic:(NSDictionary *)dic;

@end
