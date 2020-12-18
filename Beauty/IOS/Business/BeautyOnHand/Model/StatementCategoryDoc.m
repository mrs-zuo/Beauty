//
//  StatementCategoryDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/5.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "StatementCategoryDoc.h"

@implementation StatementCategoryDoc

- (id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"StatementCategoryDoc UndefinedKey");
}

@end
