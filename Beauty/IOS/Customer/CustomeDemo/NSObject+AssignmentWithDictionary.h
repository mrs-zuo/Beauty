//
//  NSObject+AssignmentWithDictionary.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-1-14.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.


//  // 将json赋值给对象的属性      by ZhangWei


#import <Foundation/Foundation.h>

@interface NSObject (AssignmentWithDictionary) //this category is associated object property-name and dictionary-key,

//-(NSArray *)getDictionaryProperties; //array of dicitonary properties, always we need to assignment with our customized properties
//- (void)setDictionaryProperties:(NSArray *)propertiesArray;

//-(NSArray *)getObjectProperties; //array of object properties, always we need to assignment with our customized properties
//- (void)setObjectProperties:(NSArray *)propertiesArray;
//以上函数暂时弃用

//- (void)assignObjectPropertyWithDictionary:(NSDictionary *)originalDictioanry;
- (void)assignObjectPropertyWithDictionary:(NSDictionary *)originalDictioanry andObjectPropertyAssociatedDictionary:(NSDictionary *)assiocation
;
@end
