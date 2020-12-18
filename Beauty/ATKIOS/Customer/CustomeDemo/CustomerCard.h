//
//  CustomerCard.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/7.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerCard : NSObject
@property (copy,nonatomic)NSString *cardName;
@property (assign,nonatomic)long  double cardBalance;
@property (assign,nonatomic)NSInteger isDefault;
@property (copy,nonatomic)NSString *userCardNo;
@property (assign,nonatomic)NSInteger cardTypeID;
@property (strong, nonatomic)NSString *rate;
@property (strong, nonatomic)NSString *presentRate;
@property (strong, nonatomic)NSString *paymentMode;
@end
