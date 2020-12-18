//
//  GPCHTTPClient.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-4.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "AFHTTPClient.h"

@interface GPCHTTPClient : AFHTTPClient

+ (instancetype)sharedClient;

- (AFHTTPRequestOperation *)requestUrlPath:(NSString *)path  showErrorMsg:(BOOL)showMsg  parameters:(id)parameters WithSuccess:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
@end
