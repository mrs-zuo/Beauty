//
//  EcardReport.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "EcardReport.h"
#import "GPBHTTPClient.h"
#import "SVProgressHUD.h"

@implementation EcardReport
- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
}

+ (AFHTTPRequestOperation *)getReportWithPar:(NSString *)par completionBlock:(void (^)(NSArray *, NSInteger, NSString *))block {
    
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Report/getReportDetail_1_7_2" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *tmpArray = [data objectForKey:@"BalanceDetail"];
            if (![tmpArray isKindOfClass:[NSNull class]]) {
                NSMutableArray *ecardArray = [NSMutableArray array];
                [tmpArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [ecardArray addObject:[[EcardReport alloc] initWithDictionary:obj]];
                }];
                block([ecardArray copy], code, message);
            } else {
                block(nil, code, message);
                [SVProgressHUD showErrorWithStatus2:message touchEventHandle:^{}];
            }
        } failure:^(NSInteger code, NSString *error) {
            block(nil, code, error);
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
    
    
}
@end
