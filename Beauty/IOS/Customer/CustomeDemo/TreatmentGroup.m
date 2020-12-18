//
//  TreatmentGroup.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/8/25.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "TreatmentGroup.h"
#import "Treatments.h"  

@implementation TreatmentGroup

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"TreatmentList"]) {
        
        NSMutableArray *tmpArray = [NSMutableArray array];
        for (NSDictionary *dic in value) {
            [tmpArray addObject:[[Treatments alloc] initWithDic:dic]];
        }
        self.TreatmentList = [tmpArray copy];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (NSInteger)treatCount
{
    _treatCount = _TreatmentList.count + 2;
    return _treatCount;
}
@end
