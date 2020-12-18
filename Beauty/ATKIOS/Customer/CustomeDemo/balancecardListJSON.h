//
//  balancecardListJSON.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface balancecardListJSON : NSObject
@property (copy, nonatomic)NSString *actionMode;
@property (copy, nonatomic)NSString *actionModeName;
@property (copy, nonatomic)NSString *cardType;
@property (copy, nonatomic)NSString *cardName;
@property (copy, nonatomic)NSString *amount;
@property (copy, nonatomic)NSString *balance;
@property (copy, nonatomic)NSString *userCardNo;
@property (copy, nonatomic)NSString *cardPaidAmount;
@property (assign, nonatomic) NSInteger  titleMode;

@end
