//
//  EcardInfo.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-12-1.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "EcardInfo.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"


@implementation EcardInfo

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
