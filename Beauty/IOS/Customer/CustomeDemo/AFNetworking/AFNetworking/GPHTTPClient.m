//
//  MLHTTPClient.m
//  GlamourPromise
//
//  Created by TRY-MAC01 on 13-6-24.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "GPHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "NSData+Base64.h"
#import "DEFINE.h"
#import "CacheInDisk.h"
#import "MessageDoc.h"
#import "CustomerDoc.h"
#import "ProductAndPriceDoc.h"
#import "PayDoc.h"
#import "CommodityDoc.h"
#import "CommentDoc.h"
#import "OverallMethods.h"
#import "SVProgressHUD.h"
#import "CommodityObject.h"

#define kXML_PREVIOUSString @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><MySoapHeader xmlns=\"http://tempuri.org/\"><UserName>GlamourPromiseUser</UserName><PassWord>resUesimorPruomalG</PassWord></MySoapHeader></soap:Header><soap:Body>"

//#define kXML_PREVIOUSString @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>"

#define kXML_BEHINDString @"</soap:Body></soap:Envelope>"

#define CUS_COMPANYCODE [[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYCODE"]
#define CUS_COMPANYID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_COMPANYID"] integerValue]
#define CUS_BRANCHID  [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_BRANCHID"] integerValue]
#define CUS_CUSTOMERID [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_USERID"] integerValue]
#define CUS_ISBUSINESS 0 ////modified by zhangwei for new function BUY_SERVICE (0 is customer,1 and null is business) 2014.7.9

@interface GPHTTPClient ()

-(NSMutableURLRequest *)requestWithPath:(NSString *)path soapAction:(NSString *)soapAction message:(NSString *)messsage;

- (void)enqueueOperationWithRequest:(NSURLRequest *)urlRequest
                            success:(void (^)(id xml))success
                            failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)enqueueHttpOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id xml))success
                                                    failure:(void (^)(NSError *error))failure;

@end

@implementation GPHTTPClient

id shareClient = nil;

+ (id)shareClient
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSString *fixedURL = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        shareClient = [[GPHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    });
    
    [shareClient checkBasicURL];
    
    return shareClient;
}

- (void)checkBasicURL
{
    NSString *basicURLString = [self.baseURL absoluteString];
    if (![basicURLString isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"]]) {
        NSString *fixedURL = [[[NSUserDefaults standardUserDefaults] objectForKey:@"CUSTOMER_DATABASE"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        shareClient = nil;
        shareClient = [[GPHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    }
}

- (id)initWithBaseURL:(NSURL *)url
{
    
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self setStringEncoding:NSUTF8StringEncoding];
    
    [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [self setParameterEncoding:AFFormURLParameterEncoding];
    
    return self;
}

// -----网络检查
- (AFNetworkReachabilityStatus)networkStatus
{
    switch (self.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
        {
            NSLog(@"网络未连接!");
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

// -----拼接Request的header和body
- (NSMutableURLRequest *)requestWithPath:(NSString *)path soapAction:(NSString *)soapAction message:(NSString *)messsage
{
    NSMutableString *bodyString = [NSMutableString string];
    if (messsage) {
        [bodyString appendString:kXML_PREVIOUSString];
        [bodyString appendString:messsage];
        [bodyString appendString:kXML_BEHINDString];
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[bodyString length]] forHTTPHeaderField:@"Content-Length"];
    [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

// -----AFHTTPRequestOperation加入栈 无返回Operation
- (void)enqueueOperationWithRequest:(NSURLRequest *)urlRequest
                            success:(void (^)(id xml))success
                            failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
/*#warning test -------
        NSString *messageStr = [NSString stringWithFormat:@"PATH:%@      SOAP METHOD:%@                  %@", [urlRequest URL], [[urlRequest allHTTPHeaderFields] objectForKey:@"SOAPAction"], error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"接口异常！" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];*/
    }];
    [self enqueueHTTPRequestOperation:requestOperation];
}

// -----AFHTTPRequestOperation加入栈 返回Operation
- (AFHTTPRequestOperation *)enqueueHttpOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id xml))success
                                                    failure:(void (^)(NSError *error))failure
{
    /*
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:urlRequest];
    NSURLCredential *urlCredential = [[NSURLCredential alloc] initWithIdentity:loginIdentity certificates:certArray persistence:NSURLCredentialPersistenceForSession];
    [httpClient setDefaultCredential:urlCredential];
    [httpClient setAllowsInvalidSSLCertificate:YES];
     */
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
/*#warning test -------
        NSString *messageStr = [NSString stringWithFormat:@"PATH:%@      SOAP METHOD:%@                  %@", [urlRequest URL], [[urlRequest allHTTPHeaderFields] objectForKey:@"SOAPAction"], error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"接口异常！" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];*/
    }];
    [self enqueueHTTPRequestOperation:requestOperation];
    return requestOperation;

}

// 登陆Operation
- (AFHTTPRequestOperation *)requestCustomerLoginWithMobile:(NSString *)mobile passwd:(NSString *)pwd success:(void (^)(id xml))success
                                                   failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyListForCustomer";
    NSString *message = [NSString stringWithFormat:@"<getCompanyListForCustomer xmlns=\"http://tempuri.org/\"><LoginMobile>%@</LoginMobile><Password>%@</Password><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight><DeviceType>%d</DeviceType><AppVersion>%@</AppVersion></getCompanyListForCustomer>", mobile, [OverallMethods EscapingString:pwd], 180, 180, 1 ,[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//选择所登录公司后返回登录信息
- (AFHTTPRequestOperation *)requestReturnLoginInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    NSInteger customerEquipmentType = [[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_EQUIPMENTTYPE"] integerValue];
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateLoginInfoForCustomer";
    NSString *message = [NSString stringWithFormat:@"<updateLoginInfoForCustomer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID><DeviceType>%ld</DeviceType><DeviceID>%@</DeviceID><AppVersion>%@</AppVersion></updateLoginInfoForCustomer>", (long)CUS_COMPANYID, (long)CUS_CUSTOMERID, (long)customerEquipmentType, deviceToken ? deviceToken : @"", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//验证码
- (AFHTTPRequestOperation *)requestCheckAuthenticationCodeWithMobile:(NSString *)mobile authenticationCode:(NSString *)code success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/checkAuthenticationCode";
    NSString *message = [NSString stringWithFormat:@"<checkAuthenticationCode xmlns=\"http://tempuri.org/\"><LoginMobile>%@</LoginMobile><AuthenticationCode>%@</AuthenticationCode></checkAuthenticationCode>", mobile, [OverallMethods EscapingString:code]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//获取验证码
- (AFHTTPRequestOperation *)requestGetAuthenticationCodeWithMobile:(NSString *)mobile success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getAuthenticationCode";
    NSString *message = [NSString stringWithFormat:@"<getAuthenticationCode xmlns=\"http://tempuri.org/\"><LoginMobile>%@</LoginMobile></getAuthenticationCode>",  mobile];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//通过customerId修改密码
- (AFHTTPRequestOperation *)requestUpdateCustomerPasswordWithCustomerID:(NSString *)customerIdStr LoginMobile:(NSString*)mobile NewPassword:(NSString *)password success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateCustomerPassword";
    NSString *message = [NSString stringWithFormat:@"<updateCustomerPassword xmlns=\"http://tempuri.org/\"><CustomerIDs>%@</CustomerIDs><LoginMobile>%@</LoginMobile><NewPassword>%@</NewPassword><ImageWidth>160</ImageWidth><ImageHeight>160</ImageHeight></updateCustomerPassword>", customerIdStr, mobile, [OverallMethods EscapingString:password]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//获取信息
- (AFHTTPRequestOperation *)requestGetCompanyInfoWithCustomerID:(NSInteger)customerId CompanyID:(NSInteger)companyId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyInfo";
    NSString *message = [NSString stringWithFormat:@"<getCompanyInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CompanyID>%ld</CompanyID><ImageWidth></ImageWidth><ImageHeight></ImageHeight></getCompanyInfo>",  (long)customerId, (long)companyId];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

- (AFHTTPRequestOperation *)requestUploadImage:(UIImage *)headImage success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/uploadImage";
    if (headImage == nil) return nil;
    
    NSData *data = UIImagePNGRepresentation(headImage);
    NSString *fileURL = [NSString stringWithFormat:@"customer\\%ld\\head.png", (long)CUS_CUSTOMERID];//// ????
    NSString *message = [NSString stringWithFormat:@"<uploadImage xmlns=\"http://tempuri.org/\"><imageStr>%@</imageStr><fileUrl>%@</fileUrl></uploadImage>", [data base64EncodedString], fileURL];
    NSLog(@"message:%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

#pragma mark - Account

//请求AccountList
- (AFHTTPRequestOperation *)requestAccountListWithBranchID:(NSInteger)branchId andFlag:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    if(branchId == 0)
        branchId = CUS_BRANCHID;
    NSString *kGPBasePathString = @"WebService/account.asmx";
    NSString *soapActionString = @"http://tempuri.org/getAccountListForCustomer";
    NSString *message = [NSString stringWithFormat:@"<getAccountListForCustomer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CusotmerID>%ld</CusotmerID><Flag>%ld</Flag></getAccountListForCustomer>", (long)CUS_COMPANYID, (long)branchId, (long)CUS_CUSTOMERID, (long)flag];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//请求AccountDetail
-(AFHTTPRequestOperation *) requestAccountDetailWithAccountId:(NSInteger)accountId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/account.asmx";
    NSString *soapActionString = @"http://tempuri.org/getAccountDetail";
    NSString *message = [NSString stringWithFormat:@"<getAccountDetail xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID></getAccountDetail>", (long)accountId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//请求business Detail
-(AFHTTPRequestOperation *) requestBusinessDetailWithAccountId:(NSInteger)branchId success:(void (^)(id xml)) success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Company.asmx";
    NSString *soapActionString = @"http://tempuri.org/getBusinessDetail";
    NSString *message = [NSString stringWithFormat:@"<getBusinessDetail xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ImageHeight>%d</ImageHeight><ImageWidth>%d</ImageWidth></getBusinessDetail>",(long)CUS_COMPANYID, (long)branchId, kBusiness_Height, 280 * 2];
    NSMutableURLRequest *urlRequest =[self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    }failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

#pragma mark - setting

-(AFHTTPRequestOperation *) requestBasicInfo:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/customer.asmx";
    NSString *soapActionString = @"http://tempuri.org/getBasicInfo";
    NSString *message = [NSString stringWithFormat:@"<getBasicInfo xmlns=\"http://tempuri.org/\"><customerId>%ld</customerId></getBasicInfo>",(long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//修改个人基本信息
-(AFHTTPRequestOperation *) updateBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/customer.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateBasicInfo";
    NSString *message = [NSString stringWithFormat:@"<updateBasicInfo xmlns=\"http://tempuri.org/\"><customerId>%ld</customerId><name>%@</name><mobile>%@</mobile><email>%@</email><weixin>%@</weixin><address>%@</address></updateBasicInfo>",(long)CUS_CUSTOMERID,customerDoc.cus_Name,customerDoc.cus_Mobile,customerDoc.cus_Email,customerDoc.cus_Weixin,customerDoc.cus_Address];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

#pragma mark - Company

//获取图片
-(AFHTTPRequestOperation *) requestComanyPic:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/company.asmx";
    NSString *soapActionString = @"http://tempuri.org/getCompanyImage";
    NSString *message = [NSString stringWithFormat:@"<getCompanyImage xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId></getCompanyImage>",(long)CUS_COMPANYID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}


//获得分支机构列表
- (AFHTTPRequestOperation *)requestBeautySalonListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBranchList";
    NSString *message = [NSString stringWithFormat:@"<getBranchList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID></getBranchList>", (long)CUS_COMPANYID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//获得分支机构详情
- (AFHTTPRequestOperation *)requestBeautySalonDetailWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBranchDetail";
    NSString *message = [NSString stringWithFormat:@"<getBranchDetail xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID></getBranchDetail>", (long)branchId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//获取分支机构图片
-(AFHTTPRequestOperation *) requestComanyBranchPicWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/company.asmx";
    NSString *soapActionString = @"http://tempuri.org/getCompanyImage";
    NSString *message = [NSString stringWithFormat:@"<getCompanyImage xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId></getCompanyImage>", (long)branchId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}


#pragma mark - Record

-(AFHTTPRequestOperation *) requestRecordList:(void (^)(id xml)) success failure:(void(^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Record.asmx";
    NSString *soapActionString = @"http://tempuri.org/getRecordListByCustomerID_2_0_2";
    NSString *message = [NSString stringWithFormat:@"<getRecordListByCustomerID_2_0_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"UserType\":%d}</strJson></getRecordListByCustomerID_2_0_2>",(long)CUS_CUSTOMERID,0];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation =[self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return operation;
}


#pragma mark - Chat

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestTheTotalCountOfNewMessageWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNewMessageCount";
    NSString *message = [NSString stringWithFormat:@"<getNewMessageCount xmlns=\"http://tempuri.org/\"><ToUserID>%ld</ToUserID></getNewMessageCount>", (long)CUS_CUSTOMERID];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 请求Customer List和最后的聊天记录、时间
- (AFHTTPRequestOperation *)requestGetAccountSelectListWithId:(NSInteger)branchId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    if(branchId == 0)
        branchId = CUS_BRANCHID;
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getContactListForCustomer";
    NSString *message = [NSString stringWithFormat:@"<getContactListForCustomer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getContactListForCustomer>", (long)CUS_COMPANYID, (long)branchId, (long)CUS_CUSTOMERID];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 请求Message List byOneToOne
- (AFHTTPRequestOperation *)requestGetMessageListByOneToOneWithAccountId:(NSInteger)accountId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getHistoryMessage";
    NSString *message = [NSString stringWithFormat:@"<getHistoryMessage xmlns=\"http://tempuri.org/\"><HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><OlderThanMessageID>%d</OlderThanMessageID></getHistoryMessage>",(long)CUS_CUSTOMERID, (long)accountId, 0];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

// 发送消息 byOneToOne
- (AFHTTPRequestOperation *)requestSendMessageByOneToOneWithMessage:(MessageDoc *)messageDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addMessage";
    NSString *message = [NSString stringWithFormat:@"<addMessage xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><SenderID>%ld</SenderID><ReceiverIDs>%@</ReceiverIDs><MessageContent>%@</MessageContent><MessageType>%ld</MessageType><GroupFlag>%ld</GroupFlag></addMessage>",(long)CUS_COMPANYID,(long)CUS_BRANCHID,(long)messageDoc.mesg_FromUserID,messageDoc.mesg_ToUserIDString, [OverallMethods EscapingString:messageDoc.mesg_MessageContent], (long)messageDoc.mesg_MessageType, (long)messageDoc.mesg_GroupFlag];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        NSLog(@"这里可以输出");
        failure(error);
    }];
    return operation;
}

// 获得最新消息 byOneToOne
- (AFHTTPRequestOperation *)requestGetNewMessageWithAccountId:(NSInteger)accountId lastMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/webservice/message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNewMessage";
    NSString *message = [NSString stringWithFormat:@" <getNewMessage xmlns=\"http://tempuri.org/\"><HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><MessageID>%ld</MessageID></getNewMessage>", (long)CUS_CUSTOMERID, (long)accountId, (long)messageId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}


// 获得历史记录
- (AFHTTPRequestOperation *)requestHistoryMessageWithAccountId:(NSInteger)accountId firstMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getHistoryMessage";
    NSString *message = [NSString stringWithFormat:@" <getHistoryMessage xmlns=\"http://tempuri.org/\">"
                         " <HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><OlderThanMessageID>%ld</OlderThanMessageID></getHistoryMessage>",(long)CUS_CUSTOMERID, (long)accountId, (long)messageId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}


#pragma mark - Notice + Remind + Promotion

//获得用户公告
- (AFHTTPRequestOperation *)requestMessageWithAllWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNoticeAndRemindAndPromotionCount";
    NSString *message = [NSString stringWithFormat:@"<getNoticeAndRemindAndPromotionCount xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID><TimeInterval>%d</TimeInterval></getNoticeAndRemindAndPromotionCount>", (long)CUS_COMPANYID, (long)CUS_CUSTOMERID, 24];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
        [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

// 请求NoticeList
- (AFHTTPRequestOperation *)requestGetNoticeListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString =  @"/WebService/notice.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNoticeList";
    NSString *message = [NSString stringWithFormat:@"<getNoticeList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID></getNoticeList>",(long)CUS_COMPANYID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
        [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 请求RemindList
- (AFHTTPRequestOperation *)requestGetRemindListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString =  @"/WebService/notice.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRemindListByCustomerID";
    NSString *message = [NSString stringWithFormat:@"<getRemindListByCustomerID xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getRemindListByCustomerID>",(long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
        [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//请求促销信息数量
- (AFHTTPRequestOperation *)requestSalesPromotionNumberSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/promotion.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPromotionCount";
    NSString *message = [NSString stringWithFormat:@"<getPromotionCount xmlns=\"http://tempuri.org/\"><companyID>%ld</companyID><BranchID>%ld</BranchID></getPromotionCount>", (long)CUS_COMPANYID,(long)CUS_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//请求促销信息
- (AFHTTPRequestOperation *)requestSalesPromotionWithWidth:(NSInteger)width andHeight:(NSInteger)height success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/promotion.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyPromotionInfo";
    NSString *message = [NSString stringWithFormat:@"<getCompanyPromotionInfo xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ImageHeight>%ld</ImageHeight><ImageWidth>%ld</ImageWidth></getCompanyPromotionInfo>", (long)CUS_COMPANYID, (long)CUS_BRANCHID,(long)height, (long)width];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
//请求促销信息 by json
- (AFHTTPRequestOperation *)requestSalesPromotionWithByJsonWidth:(NSInteger)width andHeight:(NSInteger)height success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/promotion.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyPromotionInfo_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getCompanyPromotionInfo_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"CustomerID\":%ld,\"ImageHeight\":%ld,\"ImageWidth\":%ld}</strJson></getCompanyPromotionInfo_2_2_2>", (long)CUS_COMPANYID, (long)CUS_CUSTOMERID,(long)height, (long)width];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
#pragma mark - Order

// 获取各种order的数量
- (AFHTTPRequestOperation *)requestGetOrderCountWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderCount";
    NSString *message = [NSString stringWithFormat:@"<getOrderCount xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID></getOrderCount>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取各种order的数量 by json
- (AFHTTPRequestOperation *)requestGetOrderCountViaJsonWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderCount2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderCount2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"BranchID\":%ld,\"CompanyID\":%ld,\"IsBusiness\":%d}</strJson></getOrderCount2_2_2>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID,(long)CUS_COMPANYID,0];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// order 添加
// type == 0 Service
// type == 1 Commodity
- (AFHTTPRequestOperation *)requestAddOrder:(OrderDoc *)orderDoc oppId:(NSInteger)oppId cartIdStr:(NSString *)cartIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
   // NSInteger branchId = orderDo
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/addOrder_1_7_6";
    NSString *message =    nil;//[NSString stringWithFormat:@"<addOrder_1_7_6 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":\"%ld\",\"CustomerID\":\"%ld\",\"CreatorID\":\"%ld\",\"UpdaterID\":\"%ld\",%@}</strJson></addOrder_1_7_6>",(long)CUS_COMPANYID,(long)CUS_CUSTOMERID,(long)CUS_CUSTOMERID,(long)CUS_CUSTOMERID,orderDoc.strOrderDetail];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
//刷新价格
- (AFHTTPRequestOperation *)requestProductInfoListCustomerID:(NSInteger)customerID ProductArray:(NSString *)product success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProductInfoList";
    NSString *message = [NSString stringWithFormat:@"<getProductInfoList xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"ProductCode\":%@}</strJson></getProductInfoList>", (long)customerID, product];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
    return opertation;
    
    
}
// 订单列表
- (AFHTTPRequestOperation *)requestGetOrderListByProductType:(NSInteger)type andStatus:(NSInteger)status andIsPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByCustomerID xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID><ProductType>%ld</ProductType><Status>%ld</Status><PaymentStatus>%ld</PaymentStatus></getOrderListByCustomerID>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID,(long)type, (long)status, (long)isPaid];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --订单列表 about CustomerID by json
- (AFHTTPRequestOperation *)requestGetOrderListViaJsonByProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByCustomerID_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"BranchID\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"IsBusiness\":%ld}</strJson></getOrderListByCustomerID_2_2_2>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID,(long)productType, (long)status, (long)isPaid,(long)0];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// 未确认订单
- (AFHTTPRequestOperation *)requestGetUnconfirmedOrderListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getUnconfirmedOrderList";
    NSString *message = [NSString stringWithFormat:@"<getUnconfirmedOrderList xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getUnconfirmedOrderList>", (long)CUS_CUSTOMERID];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 确认订单
- (AFHTTPRequestOperation *)requestPostUnconfirmedOrderListWithOrderXml:(NSString *)cXml andPassword:(NSString *)password Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/confirmOrder";
    NSString *message = [NSString stringWithFormat:@"<confirmOrder xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><Password>%@</Password><OrderList>%@</OrderList></confirmOrder>", (long)CUS_CUSTOMERID, [OverallMethods EscapingString:password], [OverallMethods EscapingString:cXml]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//订单列表 about Service
- (AFHTTPRequestOperation *)requestGetOrderListAboutServiceWithType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID";
    NSString *message = [NSString stringWithFormat:@" <getOrderListByCustomerID xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID><ProductType>%d</ProductType><Status>%ld</Status></getOrderListByCustomerID>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID, 0, (long)type];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//订单列表 about Commodity
- (AFHTTPRequestOperation *)requestGetOrderListAboutCommodityWithType:(NSInteger)Status success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID";
    NSString *message = [NSString stringWithFormat:@" <getOrderListByCustomerID xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID><ProductType>%d</ProductType><Status>%ld</Status></getOrderListByCustomerID>", (long)CUS_CUSTOMERID, (long)CUS_BRANCHID, 1, (long)Status];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;

}

// --订单列表 about PaymentID
- (AFHTTPRequestOperation *)requestGetOrderListByPaymentID:(NSInteger)paymentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByPaymentID";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByPaymentID xmlns=\"http://tempuri.org/\"><PaymentID>%ld</PaymentID></getOrderListByPaymentID>", (long)paymentID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get payment list by order id
- (AFHTTPRequestOperation *)requestGetPaymentDetailByOrderID:(NSInteger)orderID withSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentDetailByOrderID_2_2";
    NSString *message = [NSString stringWithFormat:@"<getPaymentDetailByOrderID_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"OrderID\":%ld}</strJson></getPaymentDetailByOrderID_2_2>", (long)orderID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取SchedulueTime
- (AFHTTPRequestOperation *)requestOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderDetail";
    NSString *message = [NSString stringWithFormat:@"<getOrderDetail xmlns=\"http://tempuri.org/\"><OrderID>%ld</OrderID><ProductType>%ld</ProductType><UserID>%ld</UserID></getOrderDetail>", (long)orderId, (long)type, (long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestViaJsonOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderDetail_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderDetail_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"OrderID\":%ld,\"ProductType\":%ld,\"BranchID\":%ld}</strJson></getOrderDetail_2_2>", (long)orderId, (long)type,(long) CUS_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 确认订单 通过productId 反馈Order内容
- (AFHTTPRequestOperation *)requestOrderConfirmByProductId:(NSInteger )productId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProductDetail";
    NSString *message = [NSString stringWithFormat:@"<getProductDetail xmlns=\"http://tempuri.org/\"><productId>%ld</productId></getProductDetail>", (long)productId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取服务前后的图片URLs
- (AFHTTPRequestOperation *)requestGetEffectDisplayImages:(NSInteger)treatId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getTreatmentImage";
    NSString *message = [NSString stringWithFormat:@"<getTreatmentImage xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID><CompanyID>%ld</CompanyID></getTreatmentImage>", (long)treatId, (long)CUS_COMPANYID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 取消订单
- (AFHTTPRequestOperation *)requestCancelOrderByOrderId:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteOrder_1_7_6";
    NSString *message = [NSString stringWithFormat:@"<deleteOrder_1_7_6 xmlns=\"http://tempuri.org/\"><strJson>{\"UpdaterID\":%ld,\"OrderID\":%ld,\"IsBusiness\":%ld}</strJson></deleteOrder_1_7_6>",(long)CUS_CUSTOMERID, (long)orderId, (long)0];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 获取评论
- (AFHTTPRequestOperation *)requestOrderCommentByTreatmentId:(NSInteger)treatmentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Review.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getReviewDetail";
    NSString *message = [NSString stringWithFormat:@"<getReviewDetail xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID></getReviewDetail>", (long)treatmentId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 添加评论
- (AFHTTPRequestOperation *)requestAddOrderCommentByCommentDoc:(CommentDoc *)commentDoc andOrderID:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Review.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addReview";
    NSString *message = [NSString stringWithFormat:@"<addReview xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><TreatmentID>%ld</TreatmentID><OrderID>%ld</OrderID><CreatorID>%ld</CreatorID><Satisfaction>%ld</Satisfaction><Comment>%@</Comment></addReview>", (long)CUS_COMPANYID, (long)commentDoc.comment_TreatmentID, (long)orderId, (long)CUS_CUSTOMERID, (long)commentDoc.comment_Score,[OverallMethods EscapingString:commentDoc.comment_Describe]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 更新评论
- (AFHTTPRequestOperation *)requestUpdateOrderCommentByCommentDoc:(CommentDoc *)commentDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Review.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateReview";
    NSString *message = [NSString stringWithFormat:@"<updateReview xmlns=\"http://tempuri.org/\"><ReviewID>%ld</ReviewID><UpdaterID>%ld</UpdaterID><Satisfaction>%ld</Satisfaction><Comment>%@</Comment></updateReview>", (long)commentDoc.comment_ReviewID, (long)CUS_CUSTOMERID, (long)commentDoc.comment_Score, [OverallMethods EscapingString:commentDoc.comment_Describe]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

#pragma mark - E-Card

// 获取levelInfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getEcardInfo";
    NSString *message = [NSString stringWithFormat:@"<getEcardInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getEcardInfo>", (long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}


// 获取用户消费充值一览
- (AFHTTPRequestOperation *)requestGetRchargeAndPayWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/ECard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBalanceHistory_1_7_2";
    NSString *message = [NSString stringWithFormat:@"<getBalanceHistory_1_7_2 xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getBalanceHistory_1_7_2>", (long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取用户充值detail
- (AFHTTPRequestOperation *)requestGetBalanceDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/ECard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBalanceDetail";
    NSString *message = [NSString stringWithFormat:@"<getBalanceDetail xmlns=\"http://tempuri.org/\"><strJson>{\"ID\":%ld}</strJson></getBalanceDetail>", (long)Id];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取二维码（弃用）
- (AFHTTPRequestOperation *)requestGetTwoDimensionalCodeWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/ECard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getQRCode";
    NSString *message = [NSString stringWithFormat:@"<getQRCode xmlns=\"http://tempuri.org/\"><CompanyCode>%@</CompanyCode><CustomerID>%ld</CustomerID><QRCodeSize>%d</QRCodeSize></getQRCode>", CUS_COMPANYCODE, (long)CUS_CUSTOMERID, kTwoDimensionalCode_Size];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取二维码 json
- (AFHTTPRequestOperation *)requestGetTwoDimensionalCodeWithCompanyCodeOrCustomerID:(NSInteger)code withType:(NSInteger)type withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/ECard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getQRCode_1_7_5";
    NSString *message = [NSString stringWithFormat:@"<getQRCode_1_7_5 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyCode\":\"%@\",\"Code\":\"%ld\",\"Type\":\"%ld\",\"QRCodeSize\":\"%d\"}</strJson></getQRCode_1_7_5>", CUS_COMPANYCODE, (long)code, (long)type, 9];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark - Album

// 相册--获取相册列表
- (AFHTTPRequestOperation *)requestGetPhotoAlbumListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPhotoAlbumList";
    NSString *message = [NSString stringWithFormat:@"<getPhotoAlbumList xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getPhotoAlbumList>", (long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 相册--获取相册详细图片
- (AFHTTPRequestOperation *)requestGetPhotoAlbumDetailWithCreateTime:(NSString *)createTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPhotoAlbumDetail";
    NSString *message = [NSString stringWithFormat:@"<getPhotoAlbumDetail xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CreateDate>%@</CreateDate><ImageHeight>%ld</ImageHeight><ImageWidth>%ld</ImageWidth><ThumbImageWidth>%d</ThumbImageWidth><ThumbImageHeight>%d</ThumbImageHeight></getPhotoAlbumDetail>", (long)CUS_CUSTOMERID, createTime, (long)(kSCREN_BOUNDS.size.width * 2), (long)(kSCREN_BOUNDS.size.width * 2), 160,160];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

#pragma mark - Category and Commodity

//获取categoryList by companyId
- (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><IsBusiness>%d</IsBusiness><Type>%d</Type><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getCategoryListByCompanyID>", (long)CUS_COMPANYID, CUS_ISBUSINESS,1,(long)CUS_BRANCHID, (long)CUS_CUSTOMERID];//modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//获取全部CommodityList
- (AFHTTPRequestOperation *)requestGetCommodityListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getCommodityListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><IsBusiness>%d</IsBusiness><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getCommodityListByCompanyID>", (long)CUS_COMPANYID,CUS_ISBUSINESS,(long)CUS_BRANCHID ,(long)CUS_CUSTOMERID];   //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//获取categoryList by parentId
- (AFHTTPRequestOperation *)requestGetCategoryListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure withType:(NSInteger)type
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCategoryID xmlns=\"http://tempuri.org/\"><CategoryID>%ld</CategoryID><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID><IsBusiness>%d</IsBusiness><Type>%ld</Type></getCategoryListByCategoryID>", (long)parentId,(long)CUS_BRANCHID, (long)CUS_CUSTOMERID, CUS_ISBUSINESS, (long)type]; //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}


//获取commodityList by parentId
- (AFHTTPRequestOperation *)requestGetCommodityListListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getCommodityListByCategoryID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><IsBusiness>%d</IsBusiness><CategoryID>%ld</CategoryID><CustomerID>%ld</CustomerID></getCommodityListByCategoryID>", (long)CUS_COMPANYID,(long)CUS_BRANCHID,CUS_ISBUSINESS, (long)parentId, (long)CUS_CUSTOMERID];    //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 商品-- 获取Commodity Detail by commodityId
- (AFHTTPRequestOperation *)requestGetCommodityInfo:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityDetailByCommodityCode";
    NSString *message = [NSString stringWithFormat:@"<getCommodityDetailByCommodityCode xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CommodityCode>%lld</CommodityCode><BranchID>%ld</BranchID><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></getCommodityDetailByCommodityCode>", (long)CUS_COMPANYID, (long long)commodity,(long)CUS_BRANCHID, kBusiness_Width, kBusiness_Height];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// 商品-- 获取Commodity Detail by commodityId and json
- (AFHTTPRequestOperation *)requestGetCommodityInfoByJson:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityDetailByCommodityCode_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getCommodityDetailByCommodityCode_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"ProductCode\":%lld,\"ImageWidth\":%d,\"ImageHeight\":%d}</strJson></getCommodityDetailByCommodityCode_2_2_2>", (long)CUS_COMPANYID,(long)0, (long)CUS_CUSTOMERID, (long long)commodity, kBusiness_Width, kBusiness_Height];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
#pragma mark -Service
//获取ServiceList by Company
- (AFHTTPRequestOperation *)requestGetCategoryServiceListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCompanyID";
    //modified by zhangwei 2014.7.10
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><IsBusiness>%d</IsBusiness><Type>%d</Type><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getCategoryListByCompanyID>", (long)CUS_COMPANYID,CUS_ISBUSINESS, 0,(long)CUS_BRANCHID, (long)CUS_CUSTOMERID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//获取全部ServiceList
- (AFHTTPRequestOperation *)requestGetServiceListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getServiceListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><IsBusiness>%d</IsBusiness><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getServiceListByCompanyID>", (long)CUS_COMPANYID,CUS_ISBUSINESS,(long)CUS_BRANCHID ,(long)CUS_CUSTOMERID];    //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//获取ServiceList by parentId
- (AFHTTPRequestOperation *)requestGetServiceListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCategoryID xmlns=\"http://tempuri.org/\"><CategoryID>%ld</CategoryID><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID><IsBusiness>%d</IsBusiness><Type>%d</Type></getCategoryListByCategoryID>", (long)parentId,(long)CUS_BRANCHID,(long)CUS_CUSTOMERID, CUS_ISBUSINESS, 0];   //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//获取ServiceList by parentId
- (AFHTTPRequestOperation *)requestGetServiceListListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getServiceListByCategoryID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><IsBusiness>%d</IsBusiness><CategoryID>%ld</CategoryID><CustomerID>%ld</CustomerID></getServiceListByCategoryID>", (long)CUS_COMPANYID,(long)CUS_BRANCHID,CUS_ISBUSINESS, (long)parentId, (long)CUS_CUSTOMERID];   //modified by zhangwei for new function BUY_SERVICE 2014.7.9
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// Service-- 获取Service Detail by commodityId
- (AFHTTPRequestOperation *)requestGetServiceInfo:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceDetailByServiceCode";
//    NSString *message = [NSString stringWithFormat:@"<getServiceDetailByServiceCode xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><ServiceCode>%ld</ServiceCode><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></getServiceDetailByServiceCode>", (long)CUS_COMPANYID, (long)commodity, kBusiness_Width, kBusiness_Height];
    NSString *message = [NSString stringWithFormat:@"<getServiceDetailByServiceCode xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><ServiceCode>%lld</ServiceCode><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></getServiceDetailByServiceCode>", (long)CUS_COMPANYID, (long long)commodity, kBusiness_Width, kBusiness_Height];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
- (AFHTTPRequestOperation *)requestGetServiceInfoByJson:(long long)serviceCode success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceDetailByServiceCode_2_1";
    
    NSString *message = [NSString stringWithFormat:@"<getServiceDetailByServiceCode_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"ProductCode\":%lld,\"BranchID\":%ld,\"CustomerID\":%ld,\"ImageWidth\":%d,\"ImageHeight\":%d}</strJson></getServiceDetailByServiceCode_2_1>", (long)CUS_COMPANYID, (long long)serviceCode, (long)0, (long)CUS_CUSTOMERID ,kBusiness_Width, kBusiness_Height];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
#pragma mark - Pay

// 订单支付页面-- e-卡信息获得 by 吴旭
- (AFHTTPRequestOperation *)requestECardInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/webservice/ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getEcardInfo";
    NSString *message = [NSString stringWithFormat:@"<getEcardInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getEcardInfo>", (long)CUS_CUSTOMERID];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 订单支付页面-- e-卡支付 json
- (AFHTTPRequestOperation *)requestPayAddByEcard:(NSInteger )orderNumber andPaymentDetailList:(NSString *)strPayList  andPassword:(NSString *)password andOrderList:(NSString *)orderList andTotalPrice:(CGFloat)totalPrice success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addPayment_2_1";
   // NSString *message = [NSString stringWithFormat:@"<payByEcard xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><OrderCount>%ld</OrderCount><CustomerID>%ld</CustomerID><Password>%@</Password><CreatorID>%ld</CreatorID><PayAmount>%@</PayAmount><OrderID>%@</OrderID></payByEcard>",(long)CUS_COMPANYID, (long)CUS_BRANCHID, (long)orderNumber, (long)CUS_CUSTOMERID, password, (long)CUS_CUSTOMERID, strPayAmount, strOrderId];
    NSString *message = [NSString stringWithFormat:@"<addPayment_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"OrderCount\":%ld,\"CustomerID\":%ld,\"Password\":\"%@\",\"CreatorID\":%ld,\"PaymentDetailList\":%@,\"OrderIDList\":\"%@\",\"IsCustomer\":%d,\"TotalPrice\":%.2f}</strJson></addPayment_2_1>",(long)CUS_COMPANYID,(long)CUS_BRANCHID, (long)orderNumber, (long)CUS_CUSTOMERID, password, (long)CUS_CUSTOMERID, strPayList, orderList, 1 ,totalPrice];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取用户支付list一览
- (AFHTTPRequestOperation *)requestGetPaymentListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentList";
    NSString *message = [NSString stringWithFormat:@"<getPaymentList xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld, \"BranchID\":%ld}</strJson></getPaymentList>", (long)CUS_CUSTOMERID,(long)CUS_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取用户Ecard Discount一览
- (AFHTTPRequestOperation *)requestGetECardLevelDiscountListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getDiscountListForWebService";
    NSString *message = [NSString stringWithFormat:@"<getDiscountListForWebService xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld, \"LevelID\":%ld}</strJson></getDiscountListForWebService>", (long)CUS_CUSTOMERID,(long)0];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 获取用户支付detail一览
- (AFHTTPRequestOperation *)requestGetPaymentDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentDetail";
    NSString *message = [NSString stringWithFormat:@"<getPaymentDetail xmlns=\"http://tempuri.org/\"><strJson>{\"ID\":%ld, \"BranchID\":%ld}</strJson></getPaymentDetail>", (long)Id,(long)CUS_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 添加支付信息
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/payAdd";
    NSString *message = [NSString stringWithFormat:@"<payAdd xmlns=\"http://tempuri.org/\"><orderNumber>%ld</orderNumber>"
                         "<totalPrice>%@</totalPrice><userId>%d</userId><strPayMode>%@</strPayMode><strPayAmount>%@</strPayAmount><strOrderId>%@</strOrderId>"
                         "</payAdd>",(long)payDoc.OrderNumber,payDoc.pay_TotalPrice,6,payDoc.Pay_Model,payDoc.Pay_AmountByModel,payDoc.OrderIdList];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark - Shopping Cart

// get Cart Count
- (AFHTTPRequestOperation *)requestGetShoppingCartCountByCustomerIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/User.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCartAndNewMessageCount";
    NSString *message = [NSString stringWithFormat:@"<getCartAndNewMessageCount xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID></getCartAndNewMessageCount>",(long)CUS_CUSTOMERID,(long)CUS_BRANCHID];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// select Cart List
- (AFHTTPRequestOperation *)requestGetShoppingCartListByCustomerIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/cart.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCartList";
    NSString *message = [NSString stringWithFormat:@"<getCartList xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CompanyID>%ld</CompanyID></getCartList>",(long)CUS_CUSTOMERID, (long)CUS_COMPANYID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// add Cart
- (AFHTTPRequestOperation *)requestAddCommodityToShoppingCartWithCommodity:(CommodityObject *)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/cart.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addCart";
    NSInteger branchId = [[commodity.product_soldBranch objectAtIndex:commodity.product_selectedIndex - 1] product_branchId];
    NSString *message = [NSString stringWithFormat:@"<addCart xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID><CommodityCode>%lld</CommodityCode><BranchID>%ld</BranchID><Quantity>%d</Quantity></addCart>",(long)CUS_COMPANYID, (long)CUS_CUSTOMERID, (long long)commodity.product_code,(long)branchId, 1 ];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// update Cart
- (AFHTTPRequestOperation *)requestUpdateCommodityInShoppingCartWithCommodity:(CommodityDoc *)commodity andProduntCount:(NSInteger)newCount success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/cart.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateCart";
    NSString *message = [NSString stringWithFormat:@"<updateCart xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CommodityCode>%lld</CommodityCode><CartID>%ld</CartID><Quantity>%ld</Quantity></updateCart>", (long)CUS_CUSTOMERID, (long)CUS_COMPANYID, (long)CUS_BRANCHID, (long long)commodity.comm_Code ,(long)commodity.cart_ID, (long)newCount];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// delete Cart
- (AFHTTPRequestOperation *)requestDeleteCommodityFromShoppingCartWithCommodity:(NSString *)commId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/webservice/cart.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteCart";
    NSString *message = [NSString stringWithFormat:@"<deleteCart xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CartIDList>%@</CartIDList></deleteCart>",(long)CUS_CUSTOMERID, commId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

#pragma mark - Customer

//用户修改密码
- (AFHTTPRequestOperation *)requestChangeCustomerPasswordWithNewPassword:(NSString*)nPassword oldPassword:(NSString*)oPassword success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateUserPassword";
    NSString *message = [NSString stringWithFormat:@"<updateUserPassword xmlns=\"http://tempuri.org/\"><UserID>%ld</UserID><OldPassword>%@</OldPassword><NewPassword>%@</NewPassword></updateUserPassword>", (long)CUS_CUSTOMERID, [OverallMethods EscapingString:oPassword], [OverallMethods EscapingString:nPassword]];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//用户修改头像
- (AFHTTPRequestOperation *)requestChangeCustomerPhotoWithImageString:(NSString *)imageString andImageType:(NSString *)imageType andImageWidth:(double)imageWidth andImageHeight:(double)imageHeight success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateUserHeadImage";
    NSString *message = [NSString stringWithFormat:@"<updateUserHeadImage xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><UserID>%ld</UserID><UserType>%d</UserType><ImageString>%@</ImageString><ImageType>%@</ImageType><ImageWidth>%f</ImageWidth><ImageHeight>%f</ImageHeight></updateUserHeadImage>",(long)CUS_COMPANYID, (long)CUS_CUSTOMERID, 0, imageString, imageType, imageWidth, imageHeight];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

#pragma mark - AppVersion

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestAppVersionWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        [SVProgressHUD showErrorWithStatus2:@"无网络连接"];
        return nil;
    }
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *kGPBasePathString = @"/WebService/version.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServerVersion";
    NSString *message = [NSString stringWithFormat:@"<getServerVersion xmlns=\"http://tempuri.org/\"><DeviceType>%d</DeviceType><ClientType>%d</ClientType><CurrentVersion>%@</CurrentVersion></getServerVersion>", 0, 1,version];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

@end
