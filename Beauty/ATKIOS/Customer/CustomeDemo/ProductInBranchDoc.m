//
//  ProductInBranchDoc.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/16.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ProductInBranchDoc.h"

@implementation ProductInBranchDoc
- (id)init{
    self = [super init];
    if(self){
        _commodityDocArray = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
