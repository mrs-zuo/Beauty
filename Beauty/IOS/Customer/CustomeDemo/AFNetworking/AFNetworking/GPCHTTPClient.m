//
//  GPCHTTPClient.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15-3-4.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "GPCHTTPClient.h"
#import "AFHTTPClient.h"
#import "DEFINE.h"
#import "UUID.h"
#import "NSString+Additional.h"
#import "NSString+MD5.h"
#import "NSMutableString+Dictionary.h"
#import "SVProgressHUD.h"
#import "NSDate+Convert.h"
#import "AFJSONRequestOperation.h"
#import "UIAlertView+AddBlockCallBacks.h"

@implementation GPCHTTPClient

static GPCHTTPClient *_sharedClient = nil;

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *servierURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"];
        NSString *fixedURL = [servierURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        _sharedClient = [[GPCHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    });
    
    [_sharedClient checkBasicURL];
    
    return _sharedClient;
}

- (void)checkBasicURL {
    NSString *basicURLString = self.baseURL.absoluteString;
    NSString *serviceURLStr  = [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"];
    if (![basicURLString isEqualToString:serviceURLStr]) {
        NSString *fixedURL = [serviceURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        _sharedClient = [[GPCHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    }
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self setStringEncoding:NSUTF8StringEncoding];
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setParameterEncoding:AFJSONParameterEncoding];
    //    self.allowsInvalidSSLCertificate = YES;
    
    return self;
}

- (AFNetworkReachabilityStatus)networkStatus {
    switch (self.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络未连接！" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
            break;
        case AFNetworkReachabilityStatusUnknown:
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusReachableViaWiFi: break;
    }
    
    return self.networkReachabilityStatus;
}

- (AFHTTPRequestOperation *)requestUrlPath:(NSString *)url
                              showErrorMsg:(BOOL)showMsg
                                parameters:(id)parameters
                               WithSuccess:(void (^)(id json))success
                                   failure:(void (^)(NSError *error))failure {
    
    if ([self networkStatus] == AFNetworkReachabilityStatusNotReachable)
        return nil;
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:url parameters:(id)parameters];
    urlRequest.timeoutInterval = 10;
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSInteger code = [[response.allHeaderFields objectForKey:@"errorMessage"] integerValue];
        NSLog(@"status Code:%ld, errorMessage:%ld",response.statusCode, code);
        if(showMsg){

            NSString *message = @"网络错误！";
            if (response.statusCode == 500)
                [SVProgressHUD showErrorWithStatus2:message];
            else if (response.statusCode == 401)
            {
         /*
                 10001	MD5加密参数未传递
                 10002	验证未通过
                 10003	方法名未传
                 10004	CompanyID未传
                 10005	BranchyID未传
                 10006	UserID未传
                 10007	ClientType未传
                 10008	AppVersion未传
                 10009	GUID未传
                 10010	版本过低
                 10011	头信息处理异常
                 10012	DeviceType未传
                 10013	登录异常
                 */
                switch (code) {
                    case 10010:
                    {
                        if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                        message = @"请升级至最新版！";
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            if (buttonIndex == 0) {
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/us/app/mei-li-yue-ding/id787185607"]];
                            }
                        }];
//                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                        [delegate logout:message callBack:^{
//                            
//                        }];
                        break;
                    }
                    case 10013:
                    {
                        if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                        message = @"登录异常，请重新登录！";
                        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [delegate logout:message callBack:nil];
                        break;
                    }
                    default:
                        [SVProgressHUD showErrorWithStatus2:[NSString stringWithFormat:@"Error Code:%ld\n%@",(long)code,message]];
                        break;
                }
            }
            else if ((!response || response.statusCode == 0) && [self networkStatus] == AFNetworkReachabilityStatusNotReachable ){
                if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络未连接！" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            } else{
                if (response )
                    [SVProgressHUD showErrorWithStatus2:[NSString stringWithFormat:@"Network Status:%ld\n%@",(long)response.statusCode,message]];
                else{
                    if (error.code == -1004)
                        [SVProgressHUD showErrorWithStatus2:error.localizedDescription];
                    else
                        if ([SVProgressHUD isVisible]) [SVProgressHUD dismiss];
                }
            }
        }
        failure(error);
    }];
    [self enqueueHTTPRequestOperation:requestOperation];
    
    return requestOperation;
}

- (NSMutableURLRequest *)requestWithPath:(NSString *)path  parameters:(id)parameters {
    
    if (parameters == nil)  parameters = @"";
    
    //如果是字典则转成字符串（因为直接调用NSJSONserialation 转成nsdata会转义“/”,base64编码字符串将出问题）
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSMutableString *string = [NSMutableString string];
        parameters = [string stringFromDictionary:parameters];
    }
    
    NSString * version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSArray *pathArray = [path componentsSeparatedByString:@"/"];
    NSString *methodName = [[pathArray lastObject] uppercaseString];
    NSString *str = @"";
    if (CUS_COMPANYID > 0)
        str =[str stringByAppendingFormat:@"%ld",(long)CUS_COMPANYID];
    str = [str stringByAppendingFormat:@"%@",[UUID getUUID]];

    NSString *md5 = [[[NSString stringWithFormat:@"%@%@%@HS", methodName, parameters, str] uppercaseString] getMD5];
    //NSString *md5 = [[[NSString stringWithFormat:@"%@%@HS", methodName, parameters] uppercaseString] getMD5];
    NSString *timeStr = [NSDate stringDateTimeLongLongFromDate:[NSDate date]];
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];;
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"Application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    /*与业务逻辑相关的头信息
         CO：公司ID
         BR：门店ID
         US：AccountID或者CustomerID
         CT：1、商户端 2、客户端 3、Web后台
         DT：1、IOS 2、安卓
         AV：当前应用的版本号
         ME：请求ACTION的MethodName
         TI:客户端请求时间
         GU：唯一识别号
         Authorization：MD5（MethodName+Parameters+HS）
        */
    [request addValue:@"2" forHTTPHeaderField:@"CT"];
    [request addValue:@"1" forHTTPHeaderField:@"DT"];
    [request addValue:methodName forHTTPHeaderField:@"ME"];
    [request addValue:version forHTTPHeaderField:@"AV"];
    [request addValue:timeStr forHTTPHeaderField:@"TI"];
    //不需要验证的方法，以上参数必须要传，以下则是可选
    [request addValue:[NSString stringWithFormat:@"%ld", (long)CUS_COMPANYID] forHTTPHeaderField:@"CO"];
    [request addValue:@"0" forHTTPHeaderField:@"BR"]; //customer 端为 0
    [request addValue:[NSString stringWithFormat:@"%ld", (long)CUS_CUSTOMERID] forHTTPHeaderField:@"US"];
    [request addValue:[UUID getUUID] forHTTPHeaderField:@"GU"];
    [request addValue:md5 forHTTPHeaderField:@"Authorization"];
    
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

@end
