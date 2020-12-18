//
//  ZWJson.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZWJson : NSObject
+ (void)parseJson:(id)json showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,NSInteger code ,id message))success failure:(void(^)(NSInteger code,NSString *error))failure;

+ (void)parseJsonWithXML:(id)XML viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)successMsg showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,NSInteger code ,id message))success failure:(void(^)(NSInteger code,NSString *error))failure;
@end

