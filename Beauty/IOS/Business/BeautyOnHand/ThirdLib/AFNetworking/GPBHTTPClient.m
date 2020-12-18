//
//  GPBHTTPClient.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-2-28.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "GPBHTTPClient.h"
#import "NSString+Additional.h"
#import "PermissionDoc.h"
#import "NSMutableString+Dictionary.h"
#import "AppDelegate.h"
#import "UIAlertView+AddBlockCallBacks.h"

@implementation GPBHTTPClient

static GPBHTTPClient *_sharedClient = nil;

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *servierURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account_GPBasicURLString"];
        NSString *fixedURL = [servierURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        _sharedClient = [[GPBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    });
    
    [_sharedClient checkBasicURL];

    return _sharedClient;
}


- (void)checkBasicURL
{
    NSString *basicURLString = self.baseURL.absoluteString;
    NSString *serviceURLStr  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account_GPBasicURLString"];
    if (![basicURLString isEqualToString:serviceURLStr]) {
        NSString *fixedURL = [serviceURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _sharedClient = [[GPBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    }
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self setStringEncoding:NSUTF8StringEncoding];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    self.allowsInvalidSSLCertificate = YES;

    return self;
}

- (AFNetworkReachabilityStatus)networkStatus
{
    switch (self.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您的网络貌似不给力，请重试！" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case AFNetworkReachabilityStatusUnknown:
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi:
            break;
        default:
            break;
    }
    
    return self.networkReachabilityStatus;
}

- (AFHTTPRequestOperation *)requestUrlPath:(NSString *)url andParameters:(id)parameters failureHandle:(AFRequestFailureHandle)handleMode WithSuccess:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    
    if ([self networkStatus] == AFNetworkReachabilityStatusNotReachable) {
//        return nil;
        
//        failure(nil);
//        return nil;
    }
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:url andParameters:(id)parameters];
    urlRequest.timeoutInterval = 10.0f;
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if ([SVProgressHUD isVisible]) {
            [SVProgressHUD dismiss];
        }

        if (handleMode == AFRequestFailureNone) {
            
        } else if (handleMode == AFRequestFailureDefault) {
            NSInteger code = response.statusCode;
            if (code == 401) {
                NSDictionary *dic =  response.allHeaderFields;
                NSInteger errorCode = [[dic objectForKey:@"errorMessage"] integerValue];
                
                switch (errorCode) {
                    case 10010:
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请升级至最新版！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
                        alert.tag = 0;
                        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding-shang-jia-ban/id787142525?ls=1&mt=8"]];
                            }
                        }];
                    }
                        break;
                    case 10013:
                    {
                        AppDelegate *dele = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [dele testLogoutApp];
                    }
                        break;
                    default:
                        [SVProgressHUD showErrorWithStatus2:[NSString stringWithFormat:@"%ld 陈伟林！", (long)errorCode] touchEventHandle:^{}];
                        break;
                }
            } else if (code == 500) {
                [SVProgressHUD showErrorWithStatus2:@"陈伟林！" touchEventHandle:^{}];
            }
        }
        
        failure(error);

    }];
    [self enqueueHTTPRequestOperation:requestOperation];
    
    return requestOperation;
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path andParameters:(id)parameters {
    
    if (parameters == nil) {
        parameters = @"";
    }
    if ([parameters isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:parameters];
//        parameters = [[NSMutableString alloc] stringFromDictionary:dic];
        NSMutableString *string = [NSMutableString string];
        parameters = [string stringFromDictionary:parameters];
    }
    if ([parameters isKindOfClass:[NSArray class]]) {
        NSMutableString *string = [NSMutableString string];
        parameters = [string stringFromArray:parameters];
    }
    
    NSString * version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSArray *pathArray = [path componentsSeparatedByString:@"/"];
    NSString *methodName = [pathArray lastObject];
    NSLog(@"the md5 is %@", [[NSString stringWithFormat:@"%@%@%ld%@HS", methodName, parameters, (long)ACC_COMPANTID, [[PermissionDoc sharePermission] userGUID] ] uppercaseString]);
    
    NSString *md5 = [NSString md5String:[[NSString stringWithFormat:@"%@%@%ld%@HS", methodName, parameters, (long)ACC_COMPANTID, [[PermissionDoc sharePermission] userGUID] ] uppercaseString]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    NSString *timeStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];;

    [request setHTTPMethod:@"POST"];
    
    [request addValue:@"Application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"1" forHTTPHeaderField:@"CT"];
    [request addValue:@"1" forHTTPHeaderField:@"DT"];
    [request addValue:methodName forHTTPHeaderField:@"ME"];
    [request addValue:version forHTTPHeaderField:@"AV"];
    [request addValue:[NSString stringWithFormat:@"%ld", (long)ACC_COMPANTID] forHTTPHeaderField:@"CO"];
    [request addValue:[NSString stringWithFormat:@"%ld", (long)ACC_BRANCHID] forHTTPHeaderField:@"BR"];
    [request addValue:[NSString stringWithFormat:@"%ld", (long)ACC_ACCOUNTID] forHTTPHeaderField:@"US"];
    [request addValue:timeStr forHTTPHeaderField:@"TI"];
    [request addValue:[[PermissionDoc sharePermission] userGUID] forHTTPHeaderField:@"GU"];
    [request addValue:md5 forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];

    return request;
}

@end