//
//  GPBHTTPClient.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-2-28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "ZWJson.h"
typedef NS_ENUM(NSInteger, AFRequestFailureHandle) {
    AFRequestFailureNone,
    AFRequestFailureDefault
};
@interface GPBHTTPClient : AFHTTPClient
+ (instancetype)sharedClient;

- (AFHTTPRequestOperation *)requestUrlPath:(NSString *)path andParameters:(id)parameters failureHandle:(AFRequestFailureHandle)handleMode WithSuccess:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
@end
