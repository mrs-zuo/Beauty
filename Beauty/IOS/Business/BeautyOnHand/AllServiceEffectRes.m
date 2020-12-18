//
//  AllServiceEffectRes.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/22.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "AllServiceEffectRes.h"

@implementation AllServiceEffectRes
-(instancetype)init
{
    if (self = [super init]) {
        _ImageEffects = [NSMutableArray array];
    }
    return self;
}

-(void)setTGStartTime:(NSString *)TGStartTime
{
    if (TGStartTime) {
        _TGStartTime = [TGStartTime substringToIndex:TGStartTime.length - 5];
    }
}
@end
