//
//  Tag.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-13.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "Tags.h"

@implementation Tags


- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    //    [record ]
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
    
    
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@"ID"]) {
        self.tagID = [value integerValue];
    }

    NSLog(@"the UndefinedKey is %@", key);
}

- (id)copyWithZone:(NSZone *)zone
{
    Tags *newTag = [Tags allocWithZone:zone];
    newTag.Name = _Name;
    newTag.tagID = _tagID;
    newTag.isChoose = _isChoose;
    return newTag;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_tagID forKey:@"tagID"];
    [aCoder encodeObject:_Name forKey:@"Name"];
    [aCoder encodeInteger:_isChoose forKey:@"isChoose"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.tagID = [aDecoder decodeIntegerForKey:@"tagID"];
        self.Name = [aDecoder decodeObjectForKey:@"Name"];
        self.isChoose = [aDecoder decodeIntegerForKey:@"isChoose"];
    }
    return self;
}

@end
