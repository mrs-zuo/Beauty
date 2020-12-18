//
//  PaymentDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentDoc : NSObject
@property (assign, nonatomic) NSInteger pay_ID;
@property (assign, nonatomic) int pay_OrderNumber;
@property (assign, nonatomic) CGFloat pay_TotalPrice;
@property (copy, nonatomic) NSString *pay_CreateTime;


@end
