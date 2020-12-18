//
//  ReportListDoc.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportListDoc.h"

@implementation ReportListDoc

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    //    [record ]
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
    
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"the UndefinedKey is %@", key);
}

@end
