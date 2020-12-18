//
//  CustomerForPayDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-12-8.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerForPayDoc : NSObject
@property (copy, nonatomic) NSString *customerName;
@property (copy, nonatomic) NSString *listTime;
@property (copy, nonatomic) NSString *customerPhoneNum;
@property (assign, nonatomic) NSInteger unpaidCount;
@property (assign, nonatomic) NSInteger customerId;
@property (nonatomic, strong) NSString *searchPhone;
@end
