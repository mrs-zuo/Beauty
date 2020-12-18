//
//  BranchShopRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/1.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BranchShopRes : NSObject
@property (nonatomic,copy) NSString *TGStartTime;
@property (nonatomic,strong) NSNumber *branchID;
@property (nonatomic,copy) NSString *branchName;
@property (nonatomic,copy) NSString *comments;
@property (nonatomic,copy) NSString *groupNo;
@property (nonatomic,strong) NSMutableArray *imageURLArrs;

// 行数据
@property (nonatomic,strong) NSMutableArray *rowDatas;

@end
