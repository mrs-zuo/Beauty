//
//  CategoryDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CategoryDoc.h"
#import "GPBHTTPClient.h"

@implementation CategoryDoc
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

+ (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdAndBranchIdWithType:(NSString *)par completionBlock:(void (^)(NSArray *, int, NSString *, NSError *))block {
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Category/getCategoryListByCompanyID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
//            NSArray *categList = [data objectForKey:@"CategoryList"];
            NSMutableArray *tmpArrary = [NSMutableArray array];
//            int count = [[data objectForKey:@"ProductCount"] intValue];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpArrary addObject:[[CategoryDoc alloc] initWithDictionary:obj]];
            }];
            block([tmpArrary copy], 0, nil, nil);
        } failure:^(NSInteger code, NSString *error) {
            block(nil, 0, error, nil);
        }];
    } failure:^(NSError *error) {
        block(nil, 0, nil, error);
    }];
}

+ (AFHTTPRequestOperation *)requestGetCategoryListByParentId:(NSString *)par completionBlock:(void (^)(NSArray *, int, NSString *, NSError *))block {
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Category/getCategoryListByCategoryID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
//            NSArray *categList = [data objectForKey:@"CategoryList"];
            NSMutableArray *tmpArrary = [NSMutableArray array];
//            int count = [[data objectForKey:@"ProductCount"] intValue];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [tmpArrary addObject:[[CategoryDoc alloc] initWithDictionary:obj]];
            }];
            block([tmpArrary copy], 0, nil, nil);
        } failure:^(NSInteger code, NSString *error) {
            block(nil, 0, error, nil);
        }];

    } failure:^(NSError *error) {
        block(nil, 0, nil, error);
    }];
}
@end
