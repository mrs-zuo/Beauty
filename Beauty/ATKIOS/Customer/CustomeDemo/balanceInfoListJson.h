//
//  balanceInfoListJson.h
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface balanceInfoListJson : NSObject
@property (copy, nonatomic)NSString *actionMode;
@property (copy, nonatomic)NSString *actionModeName;
@property (strong, nonatomic)NSMutableArray *balanceCardList;
@end
