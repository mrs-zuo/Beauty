//
//  OrderFilterDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-23.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderFilterDoc : NSObject<NSCoding>

@property (strong,nonatomic) NSString *startTime;;
@property (strong,nonatomic) NSString *endTime;
@property (assign, nonatomic) NSInteger account_Id;
@property (strong, nonatomic) NSString *account_Name;
@property (assign, nonatomic) NSInteger user_Id;
@property (strong, nonatomic) NSString *user_Name;


@property (nonatomic) NSInteger OrderSource;                       //订单来源
@property (nonatomic) NSInteger orderType;                       //订单类型
@property (nonatomic) NSInteger orderStatus;                        //订单状态
@property (nonatomic) NSInteger orderIsPaid;                      //支付状态
@property (nonatomic, strong) NSMutableArray *accountArray;
@property (nonatomic, strong) NSString *account_IDs;

@end
