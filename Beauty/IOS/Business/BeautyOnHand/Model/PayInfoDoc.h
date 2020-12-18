//
//  PayInfoDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-8-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayInfoDoc : NSObject
@property (nonatomic, assign) NSInteger pay_Mode;
@property (nonatomic, assign) double  pay_Amount;
@property (nonatomic ,assign) double  cardPay_Amount;
@property (nonatomic ,copy) NSString * card_name;
@property(nonatomic,assign)NSInteger cardType;
@property (nonatomic ,copy) NSString * userCardNo;
@end
