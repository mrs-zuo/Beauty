//
//  ZWJson.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "ZWJson.h"
#import "SVProgressHUD.h"
@implementation ZWJson

+ (void)parseJsonWithJson:(id)json showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,NSInteger code ,id message))success failure:(void(^)(NSInteger code,NSString *error))failure{
    id data = [json objectForKey:@"Data"];
    NSInteger code = [[json objectForKey:@"Code"] integerValue];
    NSString *message = [json objectForKey:@"Message"];
    if (!message || [message isKindOfClass:[NSNull class]]) {
        message = nil;
    }
        if(code == 1) {
            if((NSNull *)data == [NSNull null])
                data = nil;
            success(data, code, message);
        }else if(code == 0) {
            failure(code, message.length > 0 ? message :@"操作失败！");
            if(errorMsg)
                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"操作失败！" touchEventHandle:^{}];
        }else if(code == -1) {
            failure(code, message.length > 0 ? message :@"系统错误！");
            if(errorMsg)
                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"系统错误！" touchEventHandle:^{}];
        }else {
            failure(code, message.length > 0 ? message :@"数据解析失败！");
        }

//    
//    if (viewController != nil) {
//        double delayInSeconds = 0.3f;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            [viewController.navigationController popViewControllerAnimated:YES];
//        });
//    }
    
}
+ (void)parseJsonWithJson2:(id)json showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,NSUInteger dataCnt ,NSInteger code ,id message))success failure:(void(^)(NSInteger code,NSString *error))failure{
    id data = [json objectForKey:@"Data"];
    NSInteger code = [[json objectForKey:@"Code"] integerValue];
    NSUInteger dataCnt = [[json objectForKey:@"DataCnt"] integerValue];
    NSString *message = [json objectForKey:@"Message"];
    if (!message || [message isKindOfClass:[NSNull class]]) {
        message = nil;
    }
        if(code == 1) {
            if((NSNull *)data == [NSNull null])
                data = nil;
                success(data, dataCnt, code, message);
        }else if(code == 0) {
            failure(code, message.length > 0 ? message :@"操作失败！");
            if(errorMsg)
                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"操作失败！" touchEventHandle:^{}];
        }else if(code == -1) {
            failure(code, message.length > 0 ? message :@"系统错误！");
            if(errorMsg)
                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"系统错误！" touchEventHandle:^{}];
        }else {
            failure(code, message.length > 0 ? message :@"数据解析失败！");
        }

}
/*
+ (void)parseJsonWithXML:(id)XML viewController:(__weak UIViewController *)viewController showSuccessMsg:(BOOL)successMsg showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,NSInteger code ,id message))success failure:(void(^)(NSInteger code,NSString *error))failure{
    NSString *origalString = (NSString *)XML;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[{*}]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0, origalString.length)];
    if(!array || [array count] < 2){
        failure(-1,@"抽取json数据失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:@"数据获取失败！"];
        return;
    }
    origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
    NSData *origalData =  [origalString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:&error];
    if((NSNull*)dataDic == [NSNull null] || dataDic.count == 0){
        failure(-1,@"json数据解析失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:@"数据解析失败！"];
        return;
    }
    id data = [dataDic objectForKey:@"Data"];
    NSInteger code = [[dataDic objectForKey:@"Code"] integerValue];
    NSString *message = [dataDic objectForKey:@"Message"];
    

    if(code == 1) {
        if(successMsg)
            [SVProgressHUD showSuccessWithStatus:message.length > 0 ? message : @"数据解析成功！"];
        if((NSNull *)data == [NSNull null])
            data = nil;
        success(data ,code, message);
    }else if(code == 0) {
        failure(code, message.length > 0 ? message :@"操作失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:message.length > 0 ? message :@"操作失败！"];
        return;
    }else if(code == -1) {
        failure(code, message.length > 0 ? message :@"系统错误！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:message.length > 0 ? message :@"系统错误！"];
        return;
    }else {
        failure(code, message.length > 0 ? message :@"数据解析失败！");

        return;
    }
    
    if (viewController != nil) {
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [viewController.navigationController popViewControllerAnimated:YES];
        });
    }
    
}
*/
+ (void)parseJsonWithXML:(id)XML viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)successMsg showErrorMsg:(BOOL)errorMsg success:(void(^)(id data ,id message))success failure:(void(^)(NSString *error))failure{
    NSString *origalString = (NSString *)XML;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[{*}]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *array = [regex matchesInString:origalString options:0 range:NSMakeRange(0, origalString.length)];
    if(!array || [array count] < 2){
        failure(@"抽取json数据失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:@"数据获取失败！"];
        return;
    }
    origalString = [origalString substringWithRange:NSMakeRange(((NSTextCheckingResult *)[array objectAtIndex:0]).range.location,  ((NSTextCheckingResult *)[array objectAtIndex:[array count]-1]).range.location + 1)];
    NSData *origalData =  [origalString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:origalData options:NSJSONReadingMutableLeaves error:&error];
    if((NSNull*)dataDic == [NSNull null] || dataDic.count == 0){
        failure(@"json数据解析失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus:@"数据解析失败！"];
        return;
    }
    id data = [dataDic objectForKey:@"Data"];
    NSInteger code = [[dataDic objectForKey:@"Code"] integerValue];
    NSString *message = [dataDic objectForKey:@"Message"];
    
    
    //    if (data != [NSNull null] && [data isKindOfClass:[NSString class]]) {
    //        if(code == 1 ){
    //            if(successMsg)
    //                [SVProgressHUD showSuccessWithStatus:message.length > 0 ? message : @"数据解析成功！"];
    //            success(data);
    //
    //        } else {
    //            failure(message.length > 0 ? message :@"数据解析失败！");
    //            if(errorMsg)
    //                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"数据解析失败！" touchEventHandle:^{}];
    //            return;
    //        }
    //    }else if (data  != [NSNull null]  && [data isKindOfClass:[NSDictionary class]]){
    //        if(code == 1){
    //            if(successMsg)
    //                [SVProgressHUD showSuccessWithStatus:message.length > 0 ? message : @"数据解析成功！"];
    //            success(data);
    //        } else {
    //            failure(message.length > 0 ? message :@"数据解析失败！");
    //            if(errorMsg)
    //                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"数据解析失败！" touchEventHandle:^{}];
    //            return;
    //        }
    //    } else if(data != [NSNull null]  && [data isKindOfClass:[NSArray class]]){
    //
    //        if(code == 1){
    //            if(successMsg)
    //                [SVProgressHUD showSuccessWithStatus:message.length > 0 ? message : @"数据解析成功！"];
    //            success(data);
    //        } else {
    //            failure(message.length > 0 ? message :@"数据解析失败！");
    //            if(errorMsg)
    //                [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"数据解析失败！" touchEventHandle:^{}];
    //            return;
    //        }
    //    } else {
    if(code == 1) {
        if(successMsg)
            [SVProgressHUD showSuccessWithStatus:message.length > 0 ? message : @"数据解析成功！"];
        if((NSNull *)data == [NSNull null])
            data = nil;
        success(data, message);
    }else {
        failure(message.length > 0 ? message :@"数据解析失败！");
        if(errorMsg)
            [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"数据解析失败！" touchEventHandle:^{}];
        return;
    }
    //    }
    //    else {
    //        failure(message.length > 0 ? message :@"数据解析失败！");
    //        if(errorMsg)
    //            [SVProgressHUD showErrorWithStatus2:message.length > 0 ? message :@"数据解析失败！" touchEventHandle:^{}];
    //        return;
    //    }
    
    if (viewController != nil) {
        double delayInSeconds = 0.3f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [viewController.navigationController popViewControllerAnimated:YES];
        });
    }
    
}
@end
