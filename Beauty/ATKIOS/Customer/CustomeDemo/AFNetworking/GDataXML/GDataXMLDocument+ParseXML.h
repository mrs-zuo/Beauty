//
//  GDataXMLNode+Additional.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-2.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "GDataXMLNode.h"

@interface GDataXMLDocument (ParseXML)

// 解析如 “1|更新需求成功!“类似信息的XML
// 当viewController = nil 操作成功后不会goBack
// showSuccessMsg是否显示操作成功后的信息
// showFailureMsg是否显示操作失败后的信息
// void(^)(int) 返回的信息是  |前面的数字

+ (void)parseXML:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg success:(void (^)(GDataXMLElement *))success failure:(void (^)())failure;

+ (void)parseXML2:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg  success:(void(^)(int))success failure:(void(^)())failure;

+ (void)parseXML3:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg success:(void (^)(GDataXMLElement *))success failure:(void (^)(NSInteger flag))failure;
@end
