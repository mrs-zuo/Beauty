//
//  TGList.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/7.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGList : NSObject
@property (copy, nonatomic) NSString *service_PICName;
@property (copy, nonatomic) NSString *start_time;
@property (copy, nonatomic) NSString  *status_0;

@property (copy, nonatomic) NSString  *order_StatusStrForCommodity;
@property (strong, nonatomic) NSMutableArray *tgListArray;

@end
