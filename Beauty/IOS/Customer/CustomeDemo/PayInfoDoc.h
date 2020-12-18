//
//  PayInfoDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-8-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayInfoDoc : NSObject
@property (nonatomic, copy) NSString *pay_Mode;
@property (nonatomic, assign) long double   pay_Amount;
@property (nonatomic ,assign) long double  cardPay_Amount;
@property (nonatomic ,copy) NSString * card_name;
@property(nonatomic,assign)NSInteger cardType;
@end
