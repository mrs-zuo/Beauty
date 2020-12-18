//
//  SalesPromotionModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "SalesPromotionModel.h"
#import "BranchInfoModel.h"

@implementation SalesPromotionModel

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
    if ([key isEqualToString:@"BranchList"]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [array addObject:[[BranchInfoModel alloc] initWithDic:obj]];
        }];
        _BranchList = [array copy];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"forUndefinedKey:%@,Value:%@", key, value);
}

- (NSString *)promotionDate
{
    if (_promotionDate == nil) {
        _promotionDate = [NSString stringWithFormat:@"%@ 至 %@", _StartDate, _EndDate];
    }
    return _promotionDate;
}
@end
