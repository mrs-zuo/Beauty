//
//  GPUniqueArray.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "GPUniqueArray.h"
@interface GPUniqueArray()

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) id    keyValue;
@property (nonatomic, strong) NSMutableSet *indexSet;
@end
@implementation GPUniqueArray
- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _container = [[NSMutableArray alloc] init];
    _indexSet = [[NSMutableSet alloc] init];
    return self;
}

- (NSInteger)containerCount
{
    _containerCount = self.container.count;
    return _containerCount;
}

- (instancetype)initWithUniqueKey:(NSString *)key
{
    self = [self init];
    if (!self) {
        return nil;
    }
    _uniqueKey = key;
    return self;
}

- (void)addGPObject:(id)object
{
    NSArray *array = [self.container valueForKeyPath:[NSString stringWithFormat:@"@unionOfObjects.%@", self.uniqueKey]];
    [_indexSet addObjectsFromArray:array];
    
    
    BOOL flag = [self containerGPObject:object];
    if (flag) {
        return;
    } else {
        [self.container addObject:object];
    }
    
/*
    id keyValue = [object valueForKey:self.uniqueKey];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", self.uniqueKey, keyValue];
    NSArray *filterArray = [self.container filteredArrayUsingPredicate:predicate];
    if (filterArray.count > 0) {
        return;
    } else {
    }
 */
}


- (void)removeGPObject:(id)object
{
    
}

- (void)addGPObjectArray:(NSArray *)array
{
    
}

- (BOOL)containerGPObject:(id)object
{
    id keyValue = [object valueForKey:self.uniqueKey];
    BOOL bl = [_indexSet containsObject:keyValue];
    return bl;
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K==%@", self.uniqueKey, keyValue];
//    NSArray *filterArray = [self.container filteredArrayUsingPredicate:predicate];
//    if (filterArray.count > 0) {
//        return bl;
//    } else {
//        return bl;
//    }
}

//- (NSPredicate *)predicate
//{
//    if (_predicate == nil) {
//        _predicate = [NSPredicate predicateWithFormat:@"%@==%@", self.uniqueKey, keyValue];
//    }
//    return _predicate;
//}
@end
