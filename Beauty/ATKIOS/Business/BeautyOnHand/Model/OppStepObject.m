//
//  OppStepObject.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OppStepObject.h"

@implementation OppStepObject

- (id)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"OppStepObject UndefinedKey");
}
@end
