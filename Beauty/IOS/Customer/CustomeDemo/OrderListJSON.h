//
//  OrderListJSON.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderListJSON : NSObject
@property (copy, nonatomic)NSString*orderID;
@property (copy, nonatomic)NSString*orderNumber;
@property (copy, nonatomic)NSString*productName;
@property (copy, nonatomic)NSString*productType;
@property (copy, nonatomic)NSString*totalSalePrice;
@property (copy, nonatomic)NSString*orderObjectID;

@end
