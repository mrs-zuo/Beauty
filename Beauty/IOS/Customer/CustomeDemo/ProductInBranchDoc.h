//
//  ProductInBranchDoc.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/16.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductInBranchDoc : NSObject
@property (assign, nonatomic) BOOL select;
@property (strong, nonatomic) NSMutableArray *commodityDocArray;
@property (copy, nonatomic) NSString *branchName;
@property (assign, nonatomic) NSInteger branchId;
@property (assign, nonatomic) BOOL isAvaible;
@end
