//
//  getBalanceDetailJSON.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getBalanceDetailJSON : NSObject
@property (copy, nonatomic)NSString *balanceNumber;
@property (copy, nonatomic)NSString *balanceID;
@property (assign, nonatomic)CGFloat amount;
@property (copy, nonatomic)NSString *paymentID;
@property (copy, nonatomic)NSString *changeTypeName;
@property (copy, nonatomic)NSString *remark;
@property (copy, nonatomic)NSString *oPerator;
@property (copy, nonatomic)NSString *createTime;
@property (copy, nonatomic)NSString *targetAccount;
@property (copy, nonatomic)NSString *branchName;
@property (strong, nonatomic)NSMutableArray *balanceInfoList;
//@property (strong, nonatomic)NSMutableArray *orderList;

@end
