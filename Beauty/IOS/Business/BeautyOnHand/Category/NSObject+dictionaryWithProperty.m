//
//  NSObject+dictionaryWithProperty.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15-1-29.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "NSObject+dictionaryWithProperty.h"
#import <objc/runtime.h>
@implementation NSObject (dictionaryWithProperty)

- (NSDictionary *)dictionaryWithProperty{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count ; ++i) {
        objc_property_t property = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        if(value) [dict setObject:value forKey:key];
    }
    return dict;
}

-(void)propertyWithDictionary:(NSDictionary *)dict
{
    if (dict.count <= 0) return;
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}
@end
