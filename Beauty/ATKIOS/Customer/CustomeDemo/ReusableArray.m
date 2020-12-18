//
//  ReusableArray.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-20.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ReusableArray.h"
@interface ReusableArray()

@property (strong) NSMutableArray *dequeueArray;  //回收数组，回收不用的object对象
@property (strong) NSMutableDictionary *usingObjects;  //正在使用的object对象，key为tableViewCell对应的indexPath
@property (assign) NSUInteger arrayVirtualCount;
@end

@implementation ReusableArray

-(id)init
{
    self = [super init];
    if (self) {
        _dequeueArray = [NSMutableArray array];
        _usingObjects = [NSMutableDictionary dictionary];
    }
    return self;
}


-(id)getObjectWithClass:(Class)cls indexPath:(NSIndexPath *)indexPath
{
    id obj = nil;
    if (_dequeueArray.count > 0) {
        obj = [_dequeueArray lastObject];
        [_dequeueArray removeLastObject];
    } else {
        [self enqueueObjects];
        if (_dequeueArray.count > 0) {
            obj = [_dequeueArray lastObject];
            [_dequeueArray removeLastObject];
        } else
            obj = [cls new];
    }
    [_usingObjects setObject:obj forKey:indexPath];
    return obj;
}

- (id)getObjectWithIndexPath:(NSIndexPath *)indexPath
{
    return [_usingObjects objectForKey:indexPath];
}

-(void)enqueueObjects
{
    if ([_delegate respondsToSelector:@selector(getObjectsOnShown)]) {
        NSArray *array = [_delegate getObjectsOnShown];
        [_usingObjects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (![array containsObject:key]){
                [_dequeueArray addObject:obj];
                [_usingObjects removeObjectForKey:key];
            }
        }];
    }
}

-(NSUInteger)Count
{
    if ([_delegate respondsToSelector:@selector(vitrualCount)])
        _arrayVirtualCount = [_delegate vitrualCount];
    
    return _arrayVirtualCount;
}

@end

