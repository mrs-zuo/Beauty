//
//  AppointmentStoreRecommendModel.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "AppointmentStoreRecommendModel.h"
#import "BranchInfoModel.h"
@implementation AppointmentStoreRecommendModel
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

@end
