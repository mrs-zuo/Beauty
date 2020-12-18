//
//  CustomerTGPicRes.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/2.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import "CustomerTGPicRes.h"

@implementation CustomerTGPicRes
- (instancetype)init
{
    if (self = [super init]) {
        _TGPicList = [NSMutableArray array];
        
    }return self;
}
-(void)setTGStartTime:(NSString *)TGStartTime
{
    if (TGStartTime.length > 10) {
        _TGStartTime = [TGStartTime substringToIndex:10];
    }
}
@end
