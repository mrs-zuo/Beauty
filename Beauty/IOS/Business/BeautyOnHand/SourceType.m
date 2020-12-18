//
//  SourceType.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/7/15.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "SourceType.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"


@implementation SourceType

- (id)initWithDictionary:(NSDictionary *)dictionary
{
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
@end

