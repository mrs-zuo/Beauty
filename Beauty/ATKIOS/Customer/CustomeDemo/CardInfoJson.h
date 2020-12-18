//
//  CardInfoJson.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardInfoJson : NSObject


@property (copy, nonatomic)NSString *cardID;
@property (copy, nonatomic)NSString *cardName;
@property (copy, nonatomic)NSString *userCardNo;
@property (assign, nonatomic)long  double balance;
@property (strong, nonatomic)NSString *currency;
@property (copy, nonatomic)NSString *cardCreatedDate;
@property (copy, nonatomic)NSString *cardExpiredDate;
@property (copy, nonatomic)NSString *cardDescription;
@property (copy, nonatomic)NSString *cardType;
@property (copy, nonatomic)NSString *cardTypeName;
@property (copy, nonatomic)NSString *realCardNo;
@property (strong, nonatomic)NSMutableArray *discountList;
@end
