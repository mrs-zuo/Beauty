//
//  NSObject+AssignmentWithDictionary.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-1-14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.


#import "NSObject+AssignmentWithDictionary.h"
#import <objc/runtime.h>

//static NSString *dictionaryProperties = @"dictionaryProperties";
//static NSString *objectProperties = @"objectProperties";

@implementation NSObject (AssignmentWithDictionary)
//
//-(NSArray *)getDictionaryProperties
//{
//    return objc_getAssociatedObject(self, (__bridge const void *)(dictionaryProperties));
//}
//
//- (void)setDictionaryProperties:(NSArray *)propertiesArray
//{
//    objc_setAssociatedObject(self, (__bridge const void *)(dictionaryProperties), propertiesArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//-(NSArray *)getObjectProperties
//{
//    return objc_getAssociatedObject(self, (__bridge const void *)(objectProperties));
//}
//
//- (void)setObjectProperties:(NSArray *)propertiesArray
//{
//    objc_setAssociatedObject(self, (__bridge const void *)(objectProperties), propertiesArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}

- (void)assignObjectPropertyWithDictionary:(NSDictionary *)originalDictioanry andObjectPropertyAssociatedDictionary:(NSDictionary *)assiocation
{
    if ([originalDictioanry isKindOfClass:[NSNull class]] ||
        originalDictioanry.count <= 0)
        return;

    if (assiocation.count <= 0) return;
    
   
    
    [assiocation enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        
        id propertyValue = [originalDictioanry objectForKey:obj];
        if (![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil)
            
            
            [self setValue:propertyValue forKey:key];
        
        else if([propertyValue isKindOfClass:[NSObject class]])
            [self setValue:nil forKey:key];
    }];
}

//- (void)assignObjectPropertyWithDictionary:(NSDictionary *)originalDictioanry
//{
//    if ((NSNull *)originalDictioanry == [NSNull null] ||
//        originalDictioanry.count <= 0)
//        return;
//    
//    NSArray *objectProperty =  nil;
//    if ([self respondsToSelector:@selector(objectPropertyArray)])
//        objectProperty = [self performSelector:@selector(objectPropertyArray) withObject:self];
//    
//    NSArray *dictionaryProperty =  nil;
//    if ([self respondsToSelector:@selector(dictionaryPropertyArray)])
//        dictionaryProperty = [self performSelector:@selector(dictionaryPropertyArray) withObject:self];
//    
//    if (objectProperty.count <= 0 && dictionaryProperty.count <= 0) return;
//    assert(objectProperty.count == dictionaryProperty.count);
//    
//    NSUInteger index = 0;
//    for (NSString *key in objectProperty) {
//        index = [objectProperty indexOfObject:key];
//        id propertyValue = [originalDictioanry valueForKey:[dictionaryProperty objectAtIndex:index]];
//        if (![propertyValue isKindOfClass:[NSNull class]] && propertyValue != nil)
//            [self setValue:propertyValue forKey:key];
//    }
//}
@end
