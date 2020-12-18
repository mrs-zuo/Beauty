//
//  NoticeDoc.m
//  CustomeDemo
//
//  Created by MAC_Lion on 13-8-6.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "NoticeDoc.h"

@implementation NoticeDoc

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"the UndefinedKey is %@", key);
}

- (NSString *)EndDate {
    if (_EndDate.length > 10) {
        return  [_EndDate substringToIndex:10];
    } else {
        return _EndDate;
    }
}

- (NSString *)StartDate {
    if (_StartDate.length > 10) {
        return [_StartDate substringToIndex:10];
    } else {
        return _StartDate;
    }
}
@end
