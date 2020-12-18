//
//  GDataXMLNode+Additional.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-2.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "GDataXMLDocument+ParseXML.h"
#import "SVProgressHUD.h"

@implementation GDataXMLDocument (Additional)

+ (void)parseXML:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg success:(void (^)(GDataXMLElement *))success failure:(void (^)())failure
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    GDataXMLElement *resultData = [[document nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
    NSInteger result_Flag = [[[[resultData elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
    NSString *result_Msg = [[[resultData elementsForName:@"Message"] objectAtIndex:0] stringValue];
    
    if (result_Flag <= 0)
    {
        failure();
        
        if (showFailureMsg && [result_Msg length] > 0)
            [SVProgressHUD showErrorWithStatus:result_Msg];
    } else if (result_Flag == 1)
    {
        GDataXMLElement *contentElement = [[resultData elementsForName:@"Content"] objectAtIndex:0];
        success (contentElement);
        
        if (showSuccessMsg && [result_Msg length] > 0)
            [SVProgressHUD showSuccessWithStatus:result_Msg];
        
        if (viewController != nil) {
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [viewController.navigationController popViewControllerAnimated:YES];
            });
        }
    }
}

+ (void)parseXML2:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg
         success:(void(^)(int))success failure:(void(^)())failure
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    NSString *resultStr = [[[document nodesForXPath:@"//soap:Body" error:nil] objectAtIndex:0] stringValue];
    NSArray *resultArray = [ resultStr componentsSeparatedByString:@"|"];
    
    int flag = [[resultArray objectAtIndex:0] intValue];
    NSString *msg = [resultArray objectAtIndex:1];
    if (flag > 0) {
        if (showSuccessMsg && [msg length] > 0) {
            [SVProgressHUD showSuccessWithStatus:msg];
        }
        success(flag);
        
        if (viewController != nil) {
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [viewController.navigationController popViewControllerAnimated:YES];
            });
        }
        
    } else {
        if (showFailureMsg) {
            [SVProgressHUD showErrorWithStatus:msg];
        }
        failure();
    }
}
+ (void)parseXML3:(NSString *)xml viewController:(UIViewController *)viewController showSuccessMsg:(BOOL)showSuccessMsg showFailureMsg:(BOOL)showFailureMsg success:(void (^)(GDataXMLElement *))success failure:(void (^)(NSInteger flag))failure
{
    GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithXMLString:xml options:0 error:nil];
    GDataXMLElement *resultData = [[document nodesForXPath:@"//Result" error:nil] objectAtIndex:0];
    NSInteger result_Flag = [[[[resultData elementsForName:@"Flag"] objectAtIndex:0] stringValue] intValue];
    NSString *result_Msg = [[[resultData elementsForName:@"Message"] objectAtIndex:0] stringValue];
    
    if (result_Flag <= 0)
    {
        failure(result_Flag);
        
        if (showFailureMsg && [result_Msg length] > 0)
            [SVProgressHUD showErrorWithStatus:result_Msg];
    } else if (result_Flag == 1)
    {
        GDataXMLElement *contentElement = [[resultData elementsForName:@"Content"] objectAtIndex:0];
        success (contentElement);
        
        if (showSuccessMsg && [result_Msg length] > 0)
            [SVProgressHUD showSuccessWithStatus:result_Msg];
        
        if (viewController != nil) {
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [viewController.navigationController popViewControllerAnimated:YES];
            });
        }
    }
}

@end
