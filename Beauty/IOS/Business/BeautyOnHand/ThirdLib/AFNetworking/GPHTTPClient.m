//
//  MLHTTPClient.m
//  GlamourPromise
//
//  Created by GuanHui on 13-6-24.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "GPHTTPClient.h"
#import "NSData+Base64.h"
#import "DEFINE.h"
#import "SVProgressHUD.h"
#import "CacheInDisk.h"
#import "CustomerDoc.h"
#import "RecordDoc.h"
#import "MessageDoc.h"
#import "TemplateDoc.h"
#import "MerchantDoc.h"
#import "ProgressDoc.h"
#import "OrderDoc.h"
#import "AccountDoc.h"
#import "PayDoc.h"
#import "LevelDoc.h"
#import "ServiceDoc.h"
#import "TreatmentDoc.h"
#import "ScheduleDoc.h"
#import "ContactDoc.h"
#import "QuestionDoc.h"
#import "ProductAndPriceDoc.h"
#import "OpportunityDoc.h"
#import "AppDelegate.h"
#import "OverallMethods.h"
#import "LoginDoc.h"
#import "DFFilterSet.h"

// #define kXML_PREVIOUSString @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>"

// #define kXML_PREVIOUSString @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><MySoapHeader xmlns=\"http://tempuri.org/\"><UserName>aaa</UserName><PassWord>bbb</PassWord></MySoapHeader></soap:Header><soap:Body>"

#define kXML_PREVIOUSString [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Header><MySoapHeader xmlns=\"http://tempuri.org/\"><UserName>%@</UserName><PassWord>%@</PassWord></MySoapHeader></soap:Header><soap:Body>", kSOAPHeader_UserName, kSOAPHeader_UserPwd]

#define kXML_BEHINDString @"</soap:Body></soap:Envelope>"

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
static id shareClient = nil;

+ (id)shareClient
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        NSString *servierURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account_GPBasicURLString"];
        NSString *fixedURL = [servierURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        shareClient = [[GPHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    });
    
    [shareClient checkBasicURL];
    return shareClient;
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

- (void)checkBasicURL
{
    NSString *basicURLString = self.baseURL.absoluteString;
    NSString *serviceURLStr  = [[NSUserDefaults standardUserDefaults] objectForKey:@"Account_GPBasicURLString"];
    if (![basicURLString isEqualToString:serviceURLStr]) {
        NSString *fixedURL = [serviceURLStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        shareClient = [[GPHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:fixedURL]];
    }
}

// -----网络检查
- (AFNetworkReachabilityStatus)networkStatus
{
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
        if(soapAction) //如果soapAction不为空则用XML请求，否则用json
        {
            [bodyString appendString:kXML_PREVIOUSString];
            [bodyString appendString:messsage];
            [bodyString appendString:kXML_BEHINDString];
        }else
            [bodyString appendString:messsage];
    }
    
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.baseURL];
    
    NSLog(@"url = %@", url);
    
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[[bodyString dataUsingEncoding:NSUTF8StringEncoding] length]] forHTTPHeaderField:@"Content-Length"];
    if(soapAction){
        [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:soapAction forHTTPHeaderField:@"SOAPAction"];
    }
    else{
        [request addValue:@"Application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }
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
    }];
    
    [self enqueueHTTPRequestOperation:requestOperation];
}

// -----AFHTTPRequestOperation加入栈 返回Operation
- (AFHTTPRequestOperation *)enqueueHttpOperationWithRequest:(NSURLRequest *)urlRequest
                                                    success:(void (^)(id xml))success
                                                    failure:(void (^)(NSError *error))failure
{
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation.responseString);
        NSLog(@"the AFHTTPRequestOperation is success");
       //----------
       // NSString *soapMehod = [urlRequest valueForHTTPHeaderField:@"SOAPAction"];
       // [[CacheInDisk cacheManger] setObject:operation.responseString forURL:soapMehod];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [self enqueueHTTPRequestOperation:requestOperation];
    return requestOperation;

}

- (AFHTTPRequestOperation *)requestGetVersionWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *version = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *kGPBasePathString = @"/WebService/version.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServerVersion";
    NSString *message = [NSString stringWithFormat:@"<getServerVersion xmlns=\"http://tempuri.org/\"><DeviceType>%d</DeviceType><ClientType>%d</ClientType><CurrentVersion>%@</CurrentVersion></getServerVersion>", 0, 0 ,version];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestAccountLoginWithMobile:(NSString *)mobile passwd:(NSString *)pwd
                                                  success:(void (^)(id xml))success
                                                  failure:(void (^)(NSError *error))failure;
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyListForAccount";
    NSString *message = [NSString stringWithFormat:@"<getCompanyListForAccount xmlns=\"http://tempuri.org/\"><strJson>{\"LoginMobile\":\"%@\",\"Password\":\"%@\",\"DeviceType\":%d,\"AppVersion\":\"%@\",\"ImageWidth\":%d,\"ImageHeight\":%d}</strJson></getCompanyListForAccount>", mobile, [OverallMethods EscapingString:pwd], 1, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 180, 180];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];

    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
- (AFHTTPRequestOperation *)requestLoginInfoForAccount:(LoginDoc*)loginDoc
                                                  success:(void (^)(id xml))success
                                                  failure:(void (^)(NSError *error))failure;
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *deviceToken  = [[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"];
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateLoginInfoForAccount";
    NSString *message = [NSString stringWithFormat:@"<updateLoginInfoForAccount xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"UserID\":%ld,\"DeviceType\":%d,\"DeviceID\":\"%@\",\"AppVersion\":\"%@\"}</strJson></updateLoginInfoForAccount>", (long)loginDoc.companyId, (long)loginDoc.accountId,1 ,deviceToken ? deviceToken : @"",  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 多张图片修改 (for服务效果)
// type == 0  服务前
// type == 1  服务后
// 多张图片修改 (for服务效果)    type == 0  服务前  type == 1  服务后
- (AFHTTPRequestOperation *)requestUploadImageAndDeleteImageWithTreatmentId:(NSInteger)treatmentId customerId:(NSInteger)customerId uploadImageXML:(NSString *)uploadImageXML deleteImageXML:(NSString *)deleteImage success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
   
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateTreatmentImage";
    NSString *message = [NSString stringWithFormat:@"<updateTreatmentImage xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID><TreatmentID>%ld</TreatmentID><AddImage>%@</AddImage><DeleteImage>%@</DeleteImage></updateTreatmentImage>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID, (long)customerId, (long)treatmentId, uploadImageXML , deleteImage];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
#pragma mark -
#pragma mark - Account
// 请求Account列表 (仅仅在SelectCustomersViewController使用)
// 请求Account列表 by BranchID   -->  type = 0  companyID = "" BranchId = ?
// 请求Account列表 by CompanyID  -->  type = 1  companyID = ?  BranchId = ""
- (AFHTTPRequestOperation *)requestGetAccountListByType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *message = @"";
    if (type == 0) {
        message = [NSString stringWithFormat:@"<getAccountList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ImageWidth></ImageWidth><ImageHeight></ImageHeight></getAccountList>",(long)ACC_COMPANTID, (long)ACC_BRANCHID];
    } else if (type == 1) {
        message = [NSString stringWithFormat:@"<getAccountList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID></BranchID><ImageWidth></ImageWidth><ImageHeight></ImageHeight></getAccountList>", (long)ACC_COMPANTID];
    } else if (type == 2) {
        message = [NSString stringWithFormat:@"<getAccountList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><ImageWidth></ImageWidth><ImageHeight></ImageHeight></getAccountList>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID];
    }
    if ([message length] == 0) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getAccountList";
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestGetAccountListViaJsonWithDate:(NSString *)date success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getAccountSchedule2_2";
    NSString *message = [NSString stringWithFormat:@"<getAccountSchedule2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"Date\":\"%@\"}</strJson></getAccountSchedule2_2>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, date];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
#pragma mark - Account  Customer 

//请求AccountList
- (AFHTTPRequestOperation *)requestAccountListWithBranchID:(NSInteger)branchId andFlag:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        return nil;
    }
    NSString *kGPBasePathString = @"WebService/account.asmx";
    NSString *soapActionString = @"http://tempuri.org/getAccountListForCustomer";
    NSString *message = [NSString stringWithFormat:@"<getAccountListForCustomer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CusotmerID>%ld</CusotmerID><Flag>%ld</Flag></getAccountListForCustomer>", (long)ACC_COMPANTID, (long)branchId, (long)0, (long)flag];
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
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Company.asmx";
    NSString *soapActionString = @"http://tempuri.org/getBusinessDetail";
    NSString *message = [NSString stringWithFormat:@"<getBusinessDetail xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ImageHeight>%d</ImageHeight><ImageWidth>%d</ImageWidth></getBusinessDetail>",(long)ACC_COMPANTID, (long)branchId, 270, 560];
    NSMutableURLRequest *urlRequest =[self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    }failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}
//获得分支机构列表
- (AFHTTPRequestOperation *)requestBeautySalonListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBranchList";
    NSString *message = [NSString stringWithFormat:@"<getBranchList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID></getBranchList>", (long)ACC_COMPANTID];
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

#pragma mark -
#pragma mark - Favourite
- (AFHTTPRequestOperation *)requestGetFavouriteListByProductType:(NSInteger)type andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getFavoriteList";
    NSString *message = [NSString stringWithFormat:@"<getFavoriteList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID><ProductType>%ld</ProductType></getFavoriteList>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerId, (long)type];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestAddFavouriteByProductType:(NSInteger)type andProductCode:(long  long)productCode success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addFavorite";
    NSString *message = [NSString stringWithFormat:@"<addFavorite xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><ProductType>%ld</ProductType><AccountID>%ld</AccountID><BranchID>%ld</BranchID><ProductCode>%lld</ProductCode></addFavorite>", (long)ACC_COMPANTID,  (long)type, (long)ACC_ACCOUNTID,(long)ACC_BRANCHID,(long long)productCode];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestDelFavouriteByFavouriteID:(NSInteger)favouriteID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/delFavorite";
    NSString *message = [NSString stringWithFormat:@"<delFavorite xmlns=\"http://tempuri.org/\"><FavoriteID>%ld</FavoriteID></delFavorite>", (long)favouriteID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//- (AFHTTPRequestOperation *)requestUpdateFavouriteByProductType:(NSInteger )type withIDs:(NSString *)IDs success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
//{
//    if ([self networkStatus] == NO) return nil;
//    
//    NSString *kGPBasePathString = @"/WebService/account.asmx";
//    NSString *soapActionString =  @"http://tempuri.org/updateFavoriteSort";
//    NSString *message = [NSString stringWithFormat:@"<updateFavoriteSort xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><ProductType>%d</ProductType><IDs>%@</IDs></updateFavoriteSort>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, type,IDs];
//    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
//    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
//        success(xml);
//    } failure:^(NSError *error) {
//        failure(error);
//    }];
//    
//    return opertation;
//}
// 请求customer列表
// --objectType = 0 objectID = accountID
// | objectType = 1 objectID = companyID (when branchID = 0)
// | objectType = 2 objectID = BranchID
//- (AFHTTPRequestOperation *)requestGetCustomerListWithObjectType:(NSInteger)objectType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
//{
//    if ([self networkStatus] == NO) return nil;
//    
//    NSString *kGPBasePathString = @"/WebService/customer.asmx";
//    NSString *soapActionString =  @"http://tempuri.org/getCustomerList_1_7";
//    NSString *message = [NSString stringWithFormat:@"<getCustomerList_1_7 xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ObjectType>%ld</ObjectType>></getCustomerList_1_7>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)objectType];
//    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
//    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
//        success(xml);
//    } failure:^(NSError *error) {
//        failure(error);
//    }];
//    
//    return opertation;
//    
//}
- (AFHTTPRequestOperation *)requestGetCustomerListWithAccountID:(NSInteger)accountID ObjectType:(NSInteger)objectType LevelID:(NSInteger)levelID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
   
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCustomerList_2_3_2";
    NSString *message ;
    if (levelID == -1) {
        message = [NSString stringWithFormat:@"<getCustomerList_2_3_2 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%ld,\"LevelID\":\"\"}</strJson></getCustomerList_2_3_2>", (long)accountID, (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)objectType];
    } else
//    {
//        message = [NSString stringWithFormat:@"<getCustomerList_2_2_2 xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><ObjectType>%ld</ObjectType><LevelID>%ld</LevelID></getCustomerList_2_2_2>", accountID, (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)objectType, (long)levelID];
//    }
    
    message = [NSString stringWithFormat:@"<getCustomerList_2_3_2 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld,\"ObjectType\":%ld,\"LevelID\":%ld}</strJson></getCustomerList_2_3_2>",(long)accountID, (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)objectType, (long)levelID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
    
    /*
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCustomerList";
    NSString *message = nil;
    if (objectType == 0) {
        message = [NSString stringWithFormat:@"<getCustomerList xmlns=\"http://tempuri.org/\"><ObjectID>%ld</ObjectID><ObjectType>%d</ObjectType></getCustomerList>", (long)ACC_ACCOUNTID, 0];
    } else if (objectType == 1) {
        message = [NSString stringWithFormat:@"<getCustomerList xmlns=\"http://tempuri.org/\"><ObjectID>%ld</ObjectID><ObjectType>%d</ObjectType></getCustomerList>", (long)ACC_COMPANTID, 1];
    } else if (objectType == 2) {
        message = [NSString stringWithFormat:@"<getCustomerList xmlns=\"http://tempuri.org/\"><ObjectID>%ld</ObjectID><ObjectType>%d</ObjectType></getCustomerList>", (long)ACC_BRANCHID, 2];
    }
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;*/
}

// 请求customer信息 by CustomerID
- (AFHTTPRequestOperation *)requestGetCustomerInfoByCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCustomerInfo";
    NSString *message = [NSString stringWithFormat:@"<getCustomerInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID></getCustomerInfo>",(long)customerID, (long)ACC_COMPANTID,(long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 请求customer信息 by AccountID json格式
- (AFHTTPRequestOperation *)requestGetScanResultByJsonAndQRCode:(NSString*)QRCodeString success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getInfoByQRcode";
    NSString *message = [NSString stringWithFormat:@"<getInfoByQRcode xmlns=\"http://tempuri.org/\"><strJson>{\"QRCode\":\"%@\",\"AccountID\":%ld,\"BranchID\":%ld}</strJson></getInfoByQRcode>",QRCodeString,(long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 请求customer基本信息
- (AFHTTPRequestOperation *)requestGetCustomerBasicInfo:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCustomerBasic";
    NSString *message = [NSString stringWithFormat:@"<getCustomerBasic xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID></getCustomerBasic>", (long)ACC_BRANCHID, (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 删除customer
- (AFHTTPRequestOperation *)requestDeleteCustomerBasicInfo:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteCustomer";
    NSString *message = [NSString stringWithFormat:@"<deleteCustomer xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID></deleteCustomer>", (long)ACC_ACCOUNTID, (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 添加customer
- (AFHTTPRequestOperation *)requestAddCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = customerDoc.cus_HeadImg;
    NSString *imgType = customerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addCustomer";
    NSString *message = [NSString stringWithFormat:@"<addCustomer xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><CompanyID>%ld</CompanyID><CreatorID>%ld</CreatorID><ResponsiblePersonID>%ld</ResponsiblePersonID><CustomerName>%@</CustomerName><Title>%@</Title><LoginMobile>%@</LoginMobile><PhoneList>%@</PhoneList><EmailList>%@</EmailList><AddressList>%@</AddressList><ImageString>%@</ImageString><ImageType>%@</ImageType><HeadFlag>%d</HeadFlag><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></addCustomer>", (long)ACC_BRANCHID, (long)ACC_COMPANTID, (long)ACC_ACCOUNTID,(long)customerDoc.cus_ResponsiblePersonID, customerDoc.cus_Name, customerDoc.cus_Title, customerDoc.cus_LoginMobile, customerDoc.cus_PhoneSend,customerDoc.cus_EmailSend, customerDoc.cus_AddressSend, imgStr, imgType, headFlag, 160, 160];
    NSLog(@"%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// check customer 信息是否重复
- (AFHTTPRequestOperation *)requestAddCustomerBasicInfoWithJson:(CustomerDoc *)customerDoc flag:(NSInteger)flag success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self networkStatus] == NO) return nil;
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = customerDoc.cus_HeadImg;
    NSString *imgType = customerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addCustomer_2_1";
    NSString *message = [NSString stringWithFormat:@"<addCustomer_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"IsCheck\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerName\":\"%@\",\"Title\":\"%@\",\"LoginMobile\":\"%@\",\"LevelID\":%ld,\"PhoneList\":%@,\"EmailList\":%@,\"AddressList\":%@,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"HeadFlag\":%d,\"ImageWidth\":%d,\"ImageHeight\":%d}</strJson></addCustomer_2_1>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID,(long)flag,(long)customerDoc.cus_ResponsiblePersonID, customerDoc.cus_Name, customerDoc.cus_Title, customerDoc.cus_LoginMobile, (long)customerDoc.cus_Level, customerDoc.cus_PhoneSend,customerDoc.cus_EmailSend, customerDoc.cus_AddressSend, imgStr, imgType, headFlag, 160, 160];
    
    NSLog(@"%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// add customer anyway and it is used after function addCustomer_2_1 .
- (AFHTTPRequestOperation *)requestsubmitCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = customerDoc.cus_HeadImg;
    NSString *imgType = customerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addCustomer_2_1";
    NSString *message = [NSString stringWithFormat:@"<addCustomer_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerName\":\"%@\",\"Title\":\"%@\",\"LoginMobile\":\"%@\",\"PhoneList\":%@,\"EmailList\":%@,\"AddressList\":%@,\"ImageString\":\"%@\",\"ImageType\":\"%@\",\"HeadFlag\":%d,\"ImageWidth\":%d,\"ImageHeight\":%d}</strJson></addCustomer_2_1>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID,(long)customerDoc.cus_ResponsiblePersonID, customerDoc.cus_Name, customerDoc.cus_Title, customerDoc.cus_LoginMobile, customerDoc.cus_PhoneSend,customerDoc.cus_EmailSend, customerDoc.cus_AddressSend, imgStr, imgType, headFlag, 160, 160];
    NSLog(@"%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 修改customer
- (AFHTTPRequestOperation *)requestUpdateCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;

    int headFlag = 0;
    NSString *imgStr  = @"";
    UIImage *headImg  = customerDoc.cus_HeadImg;
    NSString *imgType = customerDoc.cus_ImgType;
    if (headImg) {
        NSData *imgData = UIImageJPEGRepresentation(headImg, 0.3f);
        imgStr = [imgData base64EncodedString];
        headFlag = 1;
    }

    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateCustomerBasic";
    NSString *message =  [NSString stringWithFormat:@"<updateCustomerBasic xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID><CustomerName>%@</CustomerName><Title>%@</Title><LoginMobile>%@</LoginMobile><PhoneList>%@</PhoneList><EmailList>%@</EmailList><AddressList>%@</AddressList><ImageString>%@</ImageString><ImageType>%@</ImageType><HeadFlag>%d</HeadFlag></updateCustomerBasic>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)customerDoc.cus_ID, customerDoc.cus_Name, customerDoc.cus_Title, customerDoc.cus_LoginMobile, customerDoc.cus_PhoneSend, customerDoc.cus_EmailSend, customerDoc.cus_AddressSend, imgStr, imgType, headFlag];
  
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -- Customer Detail Info

// 请求customer详细信息
- (AFHTTPRequestOperation *)requestGetCustomerDetailInfoWithCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCustomerDetail";
    NSString *message = [NSString stringWithFormat:@"<getCustomerDetail xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getCustomerDetail>",(long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 设置顾客在其他分店的美丽顾问
- (AFHTTPRequestOperation *)requestAddResponsiblePersonIDWithCustomerId:(NSInteger)customerId ResponsiblePersonID:(NSInteger)responsiblePersonID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addResponsiblePersonID";
    NSString *message = [NSString stringWithFormat:@"<addResponsiblePersonID xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld}</strJson></addResponsiblePersonID>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)responsiblePersonID, (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 修改cusomter详细信息
- (AFHTTPRequestOperation *)requestUpdateCustomerDetailInfoWithCustomer:(CustomerDoc *)customer success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *ganderSre = @"";
    if (customer.cus_Gender == -1) {
        ganderSre = @"<Gender></Gender>";
    } else {
        ganderSre = [NSString stringWithFormat:@"<Gender>%ld</Gender>", (long)customer.cus_Gender];
    }
    
    NSString *marriageSre = @"";
    if (customer.cus_Marriage == -1) {
        marriageSre = @"<Marriage></Marriage>";
    } else {
        marriageSre = [NSString stringWithFormat:@"<Marriage>%ld</Marriage>", (long)customer.cus_Marriage];
    }
    
    NSString *heightStr = @"";
    if(customer.cus_Height != 0)
        heightStr = [NSString stringWithFormat:@"<Height>%.1f</Height>",customer.cus_Height];
    NSString *weightStr = @"";
    if(customer.cus_Weight != 0)
        weightStr = [NSString stringWithFormat:@"<Weight>%.1f</Weight>",customer.cus_Weight];
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateCustomerDetail";
    NSString *message = [NSString stringWithFormat:@"<updateCustomerDetail xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID>%@%@%@<BloodType>%@</BloodType><Birthday>%@</Birthday>%@<Profession>%@</Profession><Remark>%@</Remark><AnswerList></AnswerList></updateCustomerDetail>", (long)ACC_COMPANTID ,(long)ACC_ACCOUNTID, (long)customer.cus_ID, ganderSre, heightStr, weightStr, customer.cus_BloodType, customer.cus_BirthDay, marriageSre, customer.cus_Profession, customer.cus_Remark];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -- Profession Info

// 请求专业信息
- (AFHTTPRequestOperation *)requestGetProfessionInfoWithCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getQuestionAnswer";
    NSString *message = [NSString stringWithFormat:@"<getQuestionAnswer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID></getQuestionAnswer>",(long)ACC_COMPANTID, (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 修改专业信息
- (AFHTTPRequestOperation *)requestUpdateProfessionInfoWithCustomer:(CustomerDoc *)customer success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Customer.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateAnswer";
    NSString *message = [NSString stringWithFormat:@"<updateAnswer xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID><AnswerList>%@</AnswerList></updateAnswer>", (long)ACC_COMPANTID ,(long)ACC_ACCOUNTID, (long)customer.cus_ID, customer.cus_AnswerSend];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}


- (AFHTTPRequestOperation *)requestGetRecordInfoByCustomerId:(NSInteger)customerId tagIDs:(NSString *)tagIDs success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRecordListByCustomerID_2_0_2";
    NSString *message = [NSString stringWithFormat:@"<getRecordListByCustomerID_2_0_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"UserType\":%ld,\"TagIDs\":\"%@\"}</strJson></getRecordListByCustomerID_2_0_2>", (long)customerId, 1L, tagIDs];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --Record Info by AccountId
- (AFHTTPRequestOperation *)requestGetRecordInfoByAccountIdWithFilterDoc:(DFFilterSet *)filterDoc recordID:(NSInteger)recordID pageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRecordListAccountID_2_3_3";
    //getRecordListByAccountID_2_3_3  getRecordListByAccountID_2_0_2 getRecordListAccountID_2_3_3
//    NSString *message = [NSString stringWithFormat:@"<getRecordListByAccountID xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID></getRecordListByAccountID>",(long)ACC_ACCOUNTID];
    NSString *message = [NSString stringWithFormat:@"<getRecordListAccountID_2_3_3 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"BranchID\":%ld,\"CompanyID\":%ld,\"RecordID\":%ld,\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TagIDs\":\"%@\",\"PageIndex\":%ld,\"PageSize\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerID\":%ld}</strJson></getRecordListAccountID_2_3_3>",(long)ACC_ACCOUNTID , (kMenu_Type == 1 ? 0:(long)ACC_BRANCHID), (long)ACC_COMPANTID, (long)recordID, filterDoc.timeFlag, filterDoc.startTime, filterDoc.endTime, filterDoc.tagIDs, (long)pagIndex, (long)pagSize, (long)filterDoc.personID, (long)filterDoc.customerID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}


- (AFHTTPRequestOperation *)requestGetRecordInfoByAccountIdRecordID:(NSInteger)recordID PageIndex:(int)index PageSize:(int)size ResponsiblePersonID:(NSInteger)personID CustomerID:(NSInteger)customerID TagIDs:(NSString *)tagIDs TimeValid:(int)timeValid StartTime:(NSString *)start EndTime:(NSString *)end success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRecordListByAccountID_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getRecordListByAccountID_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"BranchID\":%ld,\"TagIDs\":\"%@\",\"RecordID\":%ld,\"PageIndex\":%d,\"PageSize\":%d,\"ResponsiblePersonID\":%ld,\"CustomerID\":%ld,\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\" EndTime\":\"%@\"}</strJson></getRecordListByAccountID_2_2_2>",(long)ACC_ACCOUNTID , (long)ACC_BRANCHID, tagIDs, (long)recordID, index, size, (long)personID, (long)customerID, timeValid, start, end];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 请求customer记录信息
- (AFHTTPRequestOperation *)requestGetRecordInfoWithCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRecordList";
    NSString *message = [NSString stringWithFormat:@" <getRecordList xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getRecordList>",(long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 删除record Info
- (AFHTTPRequestOperation *)requestDeleteRecordInfoWithRecordId:(NSInteger)recordId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteRecord";
    NSString *message = [NSString stringWithFormat:@"<deleteRecord xmlns=\"http://tempuri.org/\"><RecordID>%ld</RecordID>"
                         "<AccountID>%ld</AccountID></deleteRecord>",(long)recordId, (long)ACC_ACCOUNTID];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 添加 record Info  checkin
- (AFHTTPRequestOperation *)requestAddRecordInfoWithRecordInfo:(RecordDoc *)recordDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addRecord";
    NSString *message = [NSString stringWithFormat:@"<addRecord xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID><RecordTime>%@</RecordTime><Problem>%@</Problem><Suggestion>%@</Suggestion><TagIDs>%@</TagIDs><IsVisible>%ld</IsVisible></addRecord>",(long)ACC_COMPANTID, (long)ACC_BRANCHID,(long)ACC_ACCOUNTID, (long)recordDoc.CustomerID, recordDoc.RecordTime, [OverallMethods EscapingString:recordDoc.Problem], [OverallMethods EscapingString:recordDoc.Suggestion], recordDoc.tagIDs, (long)recordDoc.IsVisible];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 修改 record Info
- (AFHTTPRequestOperation *)requestUpdateRecordInfoWithRecordInfo:(RecordDoc *)recordDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/record.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateRecord";
    NSString *message = nil;//[NSString stringWithFormat:@"<updateRecord xmlns=\"http://tempuri.org/\"><RecordID>%ld</RecordID><AccountID>%ld</AccountID><RecordTime>%@</RecordTime><Problem>%@</Problem><Suggestion>%@</Suggestion><IsVisible>%ld</IsVisible></updateRecord>", (long)recordDoc.RecordID, (long)ACC_ACCOUNTID, recordDoc.RecordTime, [OverallMethods EscapingString:recordDoc.Problem], [OverallMethods EscapingString:recordDoc.Suggestion],(long)recordDoc.IsVisible];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 请求Customer List和最后的聊天记录、时间
// by AccountId    --> Flag = 0  accountId = ?  BrandID = ""  CompandyId = ""
// by BrandId      --> Flag = 1  accountId = ?  BrandID = ?   CompandyId = ""
// by CompandyId   --> Flag = 2  accountId = ?  BrandID = ""  CompandyId = ?
- (AFHTTPRequestOperation *)requestGetCustomerSelectListWithType:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getContactListForAccount";
    NSString *message = [NSString stringWithFormat:@"<getContactListForAccount xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><Flag>%ld</Flag></getContactListForAccount>>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)flag];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
    
    /*
    if ([self networkStatus] == NO) return nil;
    
    NSString *message = @"";
    if (flag == 0) {
        message = [NSString stringWithFormat:@"<getContactListForAccount xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID></BranchID><AccountID>%ld</AccountID><Flag>%ld</Flag></getContactListForAccount>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)flag];
    } else if (flag == 1) {
        message = [NSString stringWithFormat:@"<getContactListForAccount xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><Flag>%ld</Flag></getContactListForAccount>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)flag];
    } else if (flag == 2) {
        message = [NSString stringWithFormat:@"<getContactListForAccount xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID></BranchID><AccountID>%ld</AccountID><Flag>%ld</Flag></getContactListForAccount>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)flag];
    }
    if([message length] == 0) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getContactListForAccount";
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;*/
}

// 请求Message List byOneToOne
- (AFHTTPRequestOperation *)requestGetMessagesListByOneToOneWithCustomer:(NSInteger)customerId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getHistoryMessage";
    NSString *message = [NSString stringWithFormat:@"<getHistoryMessage xmlns=\"http://tempuri.org/\"><HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><OlderThanMessageID>%d</OlderThanMessageID></getHistoryMessage>",(long)ACC_ACCOUNTID, (long)customerId, 0];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 请求Message List byOneToMore
- (AFHTTPRequestOperation *)requestGetMessagesListByOneToMoreSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getGroupMsg";
    NSString *message = [NSString stringWithFormat:@"<getGroupMsg xmlns=\"http://tempuri.org/\"><accountId>%ld</accountId></getGroupMsg>",(long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 发送消息 byOneToOne
- (AFHTTPRequestOperation *)requestSendMessageByOneToOneWithMessage:(MessageDoc *)messageDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;

    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addMessage";
    NSString *message = [NSString stringWithFormat:@"<addMessage xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><SenderID>%ld</SenderID><ReceiverIDs>%@</ReceiverIDs><MessageContent>%@</MessageContent><MessageType>%ld</MessageType><GroupFlag>%ld</GroupFlag></addMessage>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)messageDoc.mesg_FromUserID, messageDoc.mesg_ToUserIDString, [OverallMethods EscapingString:messageDoc.mesg_MessageContent], (long)messageDoc.mesg_MessageType, (long)messageDoc.mesg_GroupFlag];
    
    
//      NSString *message = [NSString stringWithFormat:@"<addMessage xmlns=\"http://tempuri.org/\"><CompanyID>%d</CompanyID><BranchID>%d</BranchID><FromUserID>%d</FromUserID><ToUserIDs>%@</ToUserIDs><MessageContent>%@</MessageContent><MessageType>%d</MessageType><GroupFlag>%d</GroupFlag></addMessage>", ACC_COMPANTID, ACC_BRANCHID, messageDoc.mesg_FromUserID,messageDoc.mesg_ToUserIDString, messageDoc.mesg_MessageContent, messageDoc.mesg_MessageType, messageDoc.mesg_GroupFlag];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 发送消息 byOneToMore
- (AFHTTPRequestOperation *)requestSendMessageByOneToMoreWithMessage:(MessageDoc *)messageDoc toUserIdsStr:(NSString *)toUserIdsStr Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addGroupMsg";
    NSString *message = [NSString stringWithFormat:@"<addGroupMsg xmlns=\"http://tempuri.org/\"><msgType>%d</msgType><fromUserId>%ld</fromUserId><strToUserId>%@</strToUserId>"
                         "<messageContent>%@</messageContent></addGroupMsg>", 0, (long)ACC_ACCOUNTID, toUserIdsStr, messageDoc.mesg_MessageContent];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获得最新消息 byOneToOne
- (AFHTTPRequestOperation *)requestGetNewMessagesWithCustomerId:(NSInteger)customerId lastMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNewMessage";
    NSString *message = [NSString stringWithFormat:@" <getNewMessage xmlns=\"http://tempuri.org/\">"
                        " <HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><MessageID>%ld</MessageID></getNewMessage>", (long)ACC_ACCOUNTID, (long)customerId, (long)messageId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获得历史记录
// firstMessageId 为历史记录中MessageID最小值
- (AFHTTPRequestOperation *)requestHistoryMessagesWithCustomerId:(NSInteger)customerId firstMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Message.asmx";     
    NSString *soapActionString =  @"http://tempuri.org/getHistoryMessage";
    NSString *message = [NSString stringWithFormat:@" <getHistoryMessage xmlns=\"http://tempuri.org/\">"
                         " <HereUserID>%ld</HereUserID><ThereUserID>%ld</ThereUserID><OlderThanMessageID>%ld</OlderThanMessageID></getHistoryMessage>", (long)ACC_ACCOUNTID, (long)customerId, (long)messageId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestTheTotalCountOfNewMessageWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNewMessageCount";
    NSString *message = [NSString stringWithFormat:@"<getNewMessageCount xmlns=\"http://tempuri.org/\"><ToUserID>%ld</ToUserID></getNewMessageCount>", (long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取群消息的历史记录 (每次返回5条信息)
- (AFHTTPRequestOperation *)requestGetGroupMsgWithLastID:(NSInteger)lastID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getHistoryMessageForMarketing";
    NSString *message = [NSString stringWithFormat:@"<getHistoryMessageForMarketing xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><OlderThanMessageID>%ld</OlderThanMessageID></getHistoryMessageForMarketing>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)lastID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 更新已经请求的群发消息
- (AFHTTPRequestOperation *)requestRefreshGroupMsgWithTheOldestTime:(NSInteger)recentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/message.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNewMessageForMarketing";
    NSString *message = [NSString stringWithFormat:@"<getNewMessageForMarketing xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><NewerThanMessageID>%ld</NewerThanMessageID></getNewMessageForMarketing>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)recentID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 获得模板list
- (AFHTTPRequestOperation *)requestTemplateListWithType:(NSInteger)type Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/template.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getTemplateList";
    NSString *message = [NSString stringWithFormat:@"<getTemplateList xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CompanyID>%ld</CompanyID></getTemplateList>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 添加模板
- (AFHTTPRequestOperation *)requestAddTemplateWithTemplate:(TemplateDoc *)templateDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/template.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addTemplate";
    NSString *message = [NSString stringWithFormat:@"<addTemplate xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><CompanyID>%ld</CompanyID><CreatorID>%ld</CreatorID><Subject>%@</Subject><Content>%@</Content><TemplateType>%ld</TemplateType></addTemplate>", (long)ACC_BRANCHID, (long)ACC_COMPANTID, (long)templateDoc.tmp_CreatorID, [OverallMethods EscapingString:templateDoc.Subject], [OverallMethods EscapingString:templateDoc.TemplateContent], (long)templateDoc.TemplateType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 修改模板
- (AFHTTPRequestOperation *)requestUpdateTemplateWithTemplate:(TemplateDoc *)templateDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/template.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateTemplate";
    NSString *message = [NSString stringWithFormat:@"<updateTemplate xmlns=\"http://tempuri.org/\"><TemplateID>%ld</TemplateID><UpdaterID>%ld</UpdaterID><Subject>%@</Subject><Content>%@</Content><TemplateType>%ld</TemplateType></updateTemplate>", (long)templateDoc.TemplateID, (long)ACC_ACCOUNTID, [OverallMethods EscapingString:templateDoc.Subject], [OverallMethods EscapingString:templateDoc.TemplateContent], (long)templateDoc.TemplateType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 删除模板
- (AFHTTPRequestOperation *)requestDeleteTemplateWithTemplateID:(NSInteger)templateId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/template.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteTemplate";
    NSString *message = [NSString stringWithFormat:@"<deleteTemplate xmlns=\"http://tempuri.org/\"><TemplateID>%ld</TemplateID></deleteTemplate>", (long)templateId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -
#pragma mark - Opportunity

// --add Opportunity
- (AFHTTPRequestOperation *)requestAddOpportunity:(OpportunityDoc *)opp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString = @"http://tempuri.org/addOpportunity";
    NSString *message = [NSString stringWithFormat:@"<addOpportunity xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID><Discount>%.2f</Discount><ProductList>%@</ProductList></addOpportunity>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)opp.customerId, opp.discount, [OverallMethods EscapingString:opp.strProductDetail]];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --add Opportunity json
- (AFHTTPRequestOperation *)requestAddOpportunityByJson:(OpportunityDoc *)opp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString = @"http://tempuri.org/addOpportunity_1_8";
    NSString *message = [NSString stringWithFormat:@"<addOpportunity_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CustomerID\":%ld,\"Discount\":%.2f,\"ProductList\":[%@]}</strJson></addOpportunity_1_8>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)opp.customerId, opp.discount, [OverallMethods EscapingString:opp.strProductDetail]];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Opportunity List
- (AFHTTPRequestOperation *)requestGetOpportunityListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;

    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOpportunityList";
    NSString *message = [NSString stringWithFormat:@"<getOpportunityList xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><CompanyID>%ld</CompanyID></getOpportunityList>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Opportunity List json
- (AFHTTPRequestOperation *)requestGetJsonOpportunityListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOpportunityList_1_8";
    NSString *message = [NSString stringWithFormat:@"<getOpportunityList_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"CompanyID\":%ld,\"BranchID\":%ld}</strJson></getOpportunityList_1_8>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Opportunity Detail
- (AFHTTPRequestOperation *)requestGetOpportunityDetailByOppId:(NSInteger)oppId productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOpportunityDetail";
    NSString *message = [NSString stringWithFormat:@"<getOpportunityDetail xmlns=\"http://tempuri.org/\"><OpportunityID>%ld</OpportunityID><ProductType>%ld</ProductType></getOpportunityDetail>", (long)oppId, (long)productType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Opportunity Detail json
- (AFHTTPRequestOperation *)requestGetJsonOpportunityDetailByOppId:(NSInteger)oppId productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOpportunityDetail_1_8";
    NSString *message = [NSString stringWithFormat:@"<getOpportunityDetail_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"OpportunityID\":%ld,\"ProductType\":%ld}</strJson></getOpportunityDetail_1_8>", (long)oppId, (long)productType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --delete Opportunity
- (AFHTTPRequestOperation *)requestDeleteOpportunityWithOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;

    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteOpportunity";
    NSString *message = [NSString stringWithFormat:@"<deleteOpportunity xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><OpportunityID>%ld</OpportunityID></deleteOpportunity>", (long)ACC_ACCOUNTID, (long)oppId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --delete Opportunity json
- (AFHTTPRequestOperation *)requestJsonDeleteOpportunityWithOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteOpportunity_1_8";
    NSString *message = [NSString stringWithFormat:@"<deleteOpportunity_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"OpportunityID\":%ld}</strJson></deleteOpportunity_1_8>", (long)ACC_ACCOUNTID, (long)oppId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
#pragma mark -- Progress

// --get Progress List
- (AFHTTPRequestOperation *)requestGetProgressHistoryListByOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProgressHistory";
    NSString *message = [NSString stringWithFormat:@" <getProgressHistory xmlns=\"http://tempuri.org/\"><OpportunityID>%ld</OpportunityID></getProgressHistory>", (long)oppId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Progress List json
- (AFHTTPRequestOperation *)requestGetJsonProgressHistoryListByOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProgressHistory_1_8";
    NSString *message = [NSString stringWithFormat:@" <getProgressHistory_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"OpportunityID\":%ld}</strJson></getProgressHistory_1_8>", (long)oppId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --add Progress
- (AFHTTPRequestOperation *)requestAddProgress:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addProgress";
    NSString *message = [NSString stringWithFormat:@"<addProgress xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><OpportunityID>%ld</OpportunityID><Progress>%ld</Progress><Description>%@</Description><Quantity>%ld</Quantity><TotalPrice>%.2Lf</TotalPrice><TotalSalePrice>%.2Lf</TotalSalePrice></addProgress>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)opportunityDoc.opp_ID, (long)opportunityDoc.opp_Progress, opportunityDoc.opp_Describe, (long)opportunityDoc.productAndPriceDoc.productDoc.pro_quantity, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --add Progress json
- (AFHTTPRequestOperation *)requestAddProgressByJson:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addProgress_1_8";
    NSString *message = [NSString stringWithFormat:@"<addProgress_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"CreatorID\":%ld,\"OpportunityID\":%ld,\"Progress\":%ld,\"Description\":\"%@\",\"Quantity\":%ld,\"BranchID\":%ld,\"TotalSalePrice\":%.2Lf,\"ProductCode\":%ld,\"ProductType\":%ld,\"CustomerID\":%ld}</strJson></addProgress_1_8>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, (long)opportunityDoc.opp_ID, (long)opportunityDoc.opp_Progress, opportunityDoc.opp_Describe, (long)opportunityDoc.productAndPriceDoc.productDoc.pro_quantity, (long)ACC_BRANCHID, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney,(long)opportunityDoc.productAndPriceDoc.productDoc.pro_Code,(long)opportunityDoc.productAndPriceDoc.productDoc.pro_Type,(long)opportunityDoc.customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --update Progress
- (AFHTTPRequestOperation *)requestUpdateProgress:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateProgress";
    NSString *message = [NSString stringWithFormat:@"<updateProgress xmlns=\"http://tempuri.org/\"><ProgressID>%ld</ProgressID><AccountID>%ld</AccountID><Description>%@</Description><Quantity>%ld</Quantity><TotalPrice>%.2Lf</TotalPrice><TotalSalePrice>%.2Lf</TotalSalePrice></updateProgress>", (long)opportunityDoc.opp_ProgressID, (long)ACC_ACCOUNTID, opportunityDoc.opp_Describe, (long)opportunityDoc.productAndPriceDoc.productDoc.pro_quantity, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalMoney, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --update Progress json
- (AFHTTPRequestOperation *)requestUpdateProgressByJson:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateProgress_1_8";
    NSString *message = [NSString stringWithFormat:@"<updateProgress_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"ProgressID\":%ld,\"AccountID\":%ld,\"Description\":\"%@\",\"Quantity\":%ld,\"UpdaterID\":%ld,\"TotalSalePrice\":%.2Lf}</strJson></updateProgress_1_8>", (long)opportunityDoc.opp_ProgressID, (long)ACC_ACCOUNTID, opportunityDoc.opp_Describe, (long)opportunityDoc.productAndPriceDoc.productDoc.pro_quantity, (long)ACC_ACCOUNTID, opportunityDoc.productAndPriceDoc.productDoc.pro_TotalSaleMoney];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --get Progress Detail
- (AFHTTPRequestOperation *)requestGetProgressDetail:(NSInteger)progressID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProgressDetail";
    NSString *message = [NSString stringWithFormat:@"<getProgressDetail xmlns=\"http://tempuri.org/\"><ProgressID>%ld</ProgressID><ProductType>%ld</ProductType></getProgressDetail>", (long)progressID, (long)productType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --get Progress Detail json
- (AFHTTPRequestOperation *)requestGetProgressDetailByJson:(NSInteger)progressID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/opportunity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getProgressDetail_1_8";
    NSString *message = [NSString stringWithFormat:@"<getProgressDetail_1_8 xmlns=\"http://tempuri.org/\"><strJson>{\"ProgressID\":%ld,\"ProductType\":%ld}</strJson></getProgressDetail_1_8>", (long)progressID, (long)productType];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
#pragma mark -
#pragma mark - Order
#pragma mark -- Order

// --get Order Count
- (AFHTTPRequestOperation *)requestGetOrderCountWithCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderCount2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderCount2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"IsBusiness\":%d}</strJson></getOrderCount2_2_2>",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerID, 1];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --订单列表 about AccountID_1_7_4
- (AFHTTPRequestOperation *)requestGetOrderListByAccountIDAndProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid orderId:(NSInteger)orderId viewType:(NSInteger)viewType filterByTime:(NSInteger)filterBytime startTime:(NSString*)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByAccountID_1_7_4";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByAccountID_1_7_4 xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><BranchID>%ld</BranchID><ProductType>%ld</ProductType><Status>%ld</Status><PaymentStatus>%ld</PaymentStatus><OrderId>%ld</OrderId><ViewType>%ld</ViewType><FilterByTimeFlag>%ld</FilterByTimeFlag><StartTime>%@</StartTime><EndTime>%@</EndTime></getOrderListByAccountID_1_7_4>", (long)ACC_ACCOUNTID,(long)ACC_BRANCHID , (long)productType, (long)status, (long)isPaid, (long)orderId, (long)viewType, (long)filterBytime, startTime, endTime];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --订单列表 about AccountID_2_2_2 by json
- (AFHTTPRequestOperation *)requestGetOrderListByAccountIDAndProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid orderId:(NSInteger)orderId responsePersonID:(NSInteger)responsePersonId customerID:(NSInteger)customerId viewType:(NSInteger)viewType filterByTime:(NSInteger)filterBytime pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize  isShowAll:(NSInteger)isShowAll startTime:(NSString*)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByAccountID_2_2_2";
    
    NSInteger branchId = 0;
    if (kMenu_Type == 0)  branchId = ACC_BRANCHID;
    
    NSString *message = [NSString stringWithFormat:@"<getOrderListByAccountID_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"BranchID\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"OrderID\":%ld,\"ViewType\":%ld,\"FilterByTimeFlag\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerID\":%ld,\"PageIndex\":%ld,\"PageSize\":%ld,\"IsShowAll\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}</strJson></getOrderListByAccountID_2_2_2>", (long)ACC_ACCOUNTID,(long)branchId , (long)productType, (long)status, (long)isPaid, (long)orderId, (long)viewType, (long)filterBytime,(long)responsePersonId, (long)customerId, (long)pageIndex, (long)pageSize,(long)isShowAll, startTime, endTime];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --get unpaid list
- (AFHTTPRequestOperation *)requestGetUnpaidListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getUnPaidList";
    NSString *message = [NSString stringWithFormat:@"<getUnPaidList xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld}</strJson></getUnPaidList>", (long)ACC_BRANCHID];
    NSLog(@"message = %@", message);
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

// --订单列表 about CustomerID
- (AFHTTPRequestOperation *)requestGetOrderListByCustomerID:(NSInteger)customerID productType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByCustomerID xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><BranchID>%ld</BranchID><ProductType>%ld</ProductType><Status>%ld</Status><PaymentStatus>%ld</PaymentStatus></getOrderListByCustomerID>", (long)customerID, (long)ACC_BRANCHID,(long)productType, (long)status, (long)isPaid];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// --订单列表 about CustomerID by json
- (AFHTTPRequestOperation *)requestGetOrderListViaJsonByCustomerID:(NSInteger)customerID productType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid acccountId:(NSInteger)accountID startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderListByCustomerID_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderListByCustomerID_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld,\"BranchID\":%ld,\"ProductType\":%ld,\"Status\":%ld,\"PaymentStatus\":%ld,\"IsBusiness\":%d,\"AccountID\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\"}</strJson></getOrderListByCustomerID_2_2_2>", (long)customerID, (long)ACC_BRANCHID,(long)productType, (long)status, (long)isPaid, 1 ,(long)accountID,startTime ? startTime : @"", endTime ? endTime :@""];//status
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// --订单详细
- (AFHTTPRequestOperation *)requestGetOrderDetailWithOrderID:(NSInteger)orderID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderDetail";
    NSString *message = [NSString stringWithFormat:@"<getOrderDetail xmlns=\"http://tempuri.org/\"><OrderID>%ld</OrderID><ProductType>%ld</ProductType><UserID>%ld</UserID></getOrderDetail>", (long)orderID, (long)productType, (long)ACC_ACCOUNTID];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --订单详细 json
- (AFHTTPRequestOperation *)requestViaJsonOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getOrderDetail_2_2";
    NSString *message = [NSString stringWithFormat:@"<getOrderDetail_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"OrderID\":%ld,\"ProductType\":%ld,\"BranchID\":%ld,\"AccountID\":%ld}</strJson></getOrderDetail_2_2>", (long)orderId, (long)type,(long) ACC_BRANCHID,(long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --添加订单
- (AFHTTPRequestOperation *)requestAddOrder:(OpportunityDoc *)opp oppIdStr:(NSString *)oppIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;

    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/addOrder_1_7_4";
    NSString *message = [NSString stringWithFormat:@"<addOrder_1_7_4 xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID><ResponsiblePersonID>%ld</ResponsiblePersonID><CreatorID>%ld</CreatorID><OpportunityID>%@</OpportunityID><CartID></CartID><OrderDetail>%@</OrderDetail></addOrder_1_7_4>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)opp.customerId, (long)ACC_ACCOUNTID, (long)ACC_ACCOUNTID, oppIdStr, opp.strProductDetail];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// --添加订单 1_7_6
- (AFHTTPRequestOperation *)requestAddOrderNew:(OpportunityDoc *)opp oppIdStr:(NSString *)oppIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/addOrder_1_7_6";
    NSString *message = [NSString stringWithFormat:@"<addOrder_1_7_6 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":\"%ld\",\"CustomerID\":\"%ld\",\"CreatorID\":\"%ld\",\"UpdaterID\":\"%ld\",\"OrderList\":[%@]}</strJson></addOrder_1_7_6>",(long)ACC_COMPANTID,(long)opp.customerId,(long)ACC_ACCOUNTID,(long)ACC_ACCOUNTID,opp.strProductDetail];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// order 修改
- (AFHTTPRequestOperation *)requestUpdateOrder:(OrderDoc *)orderDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateOrder";
    NSString *message = [NSString stringWithFormat:@"<updateOrder xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><CustomerID>%ld</CustomerID><ResponsiblePersonID>%ld</ResponsiblePersonID><UpdaterID>%ld</UpdaterID><OrderID>%ld</OrderID><OrderTime>%@</OrderTime><Status>%d</Status><Course>%@</Course><Contact>%@</Contact></updateOrder>", (long)ACC_COMPANTID, (long)orderDoc.order_CustomerID, (long)orderDoc.order_ResponsiblePersonID, (long)ACC_ACCOUNTID, (long)orderDoc.order_ID, orderDoc.order_OrderTime, orderDoc.order_Status, orderDoc.strCourse ,orderDoc.strContact];
    NSLog(@"message = %@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 删除
- (AFHTTPRequestOperation *)requestDeleteOrder:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/deleteOrder_1_7_6";
    NSString *message = [NSString stringWithFormat:@"<deleteOrder_1_7_6 xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":\"%ld\",\"OrderID\":\"%ld\",\"IsBusiness\":\"%ld\",\"UpdaterID\":\"%ld\"}</strJson></deleteOrder_1_7_6>", (long)ACC_BRANCHID, (long)orderId, (long)1 ,(long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//Remark 更新
- (AFHTTPRequestOperation *)updateOrderRemark:(NSInteger)orderId Remark:(NSString *) remark  CustomerID:(NSInteger) customerId UpdaterID:(NSInteger) updateId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateOrderRemark";
    NSString *message = [NSString stringWithFormat:@"<updateOrderRemark xmlns=\"http://tempuri.org/\"><strJson>{\"ID\":\"%ld\",\"Remark\":\"%@\",\"CustomerID\":\"%ld\",\"UpdaterID\":\"%ld\"}</strJson></updateOrderRemark>", (long)orderId, remark, (long)customerId, (long)updateId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
//order 修改过期时间
- (AFHTTPRequestOperation *)updateOrderExpirationTime:(NSInteger)orderId ExpirationTime:(NSString *) expirationTime  CustomerID:(NSInteger) customerId UpdaterID:(NSInteger) updateId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/UpdateExpirationTime";
    NSString *message = [NSString stringWithFormat:@"<UpdateExpirationTime xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"ExpirationTime\":\"%@\",\"CustomerID\":%ld,\"UpdaterID\":%ld}</strJson></UpdateExpirationTime>", (long)ACC_BRANCHID, (long)orderId, expirationTime, (long)customerId, (long)updateId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
//order 添加指定
- (AFHTTPRequestOperation *)updateTreatmentDesignated:(NSInteger)treatmentID OrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID IsDesignated:(BOOL) isDesignated success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/UpdateTreatmentDesignated";
    NSString *message = [NSString stringWithFormat:@"<UpdateTreatmentDesignated xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"TreatmentID\":%ld,\"UpdaterID\":%ld,\"IsDesignated\":%d}</strJson></UpdateTreatmentDesignated>",(long)ACC_BRANCHID, (long)orderID, (long)treatmentID, (long)updaterID, isDesignated];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//order 添加统计
- (AFHTTPRequestOperation *)updateOrderAddOrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID IsAddUp:(BOOL) isAddUp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/UpdateOrderIsAddUp";
    NSString *message = [NSString stringWithFormat:@"<UpdateOrderIsAddUp xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"UpdaterID\":%ld,\"IsAddUp\":%d}</strJson></UpdateOrderIsAddUp>",(long)ACC_BRANCHID, (long)orderID, (long)updaterID, isAddUp];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)updateOrderTotalSalePriceOrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID TotalSalePrice:(double) salePrice success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/UpdateTotalSalePrice";
    NSString *message = [NSString stringWithFormat:@"<UpdateTotalSalePrice xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"UpdaterID\":%ld,\"TotalSalePrice\":%.2f}</strJson></UpdateTotalSalePrice>", (long)ACC_BRANCHID, (long)orderID, (long)updaterID, salePrice];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;

    
}

// order 添加treatment
- (AFHTTPRequestOperation *)requestAddNewTreatmentWithOrderID:(NSInteger)orderId andCourseID:(NSInteger)courseId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/addTreatment";
    NSString *message = [NSString stringWithFormat:@"<addTreatment xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><OrderID>%ld</OrderID><CourseID>%ld</CourseID><CustomerID>%ld</CustomerID><CreatorID>%ld</CreatorID></addTreatment>", (long)ACC_COMPANTID, (long)orderId, (long)courseId, (long)customerId, (long)ACC_ACCOUNTID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 删除treatment
- (AFHTTPRequestOperation *)requestdeleteTreatmentWithTreatmentID:(NSInteger)treatmentId andScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/deleteTreatment";
    NSString *message = [NSString stringWithFormat:@"<deleteTreatment xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID><ScheduleID>%ld</ScheduleID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID></deleteTreatment>", (long)treatmentId, (long)scheduleId, (long)customerId, (long)ACC_ACCOUNTID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 完成treatment
- (AFHTTPRequestOperation *)requestCompleteTreatmentWithScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId addOrderID:(NSInteger)orderID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/completeTreatment";
    NSString *message = [NSString stringWithFormat:@"<completeTreatment xmlns=\"http://tempuri.org/\"><ScheduleID>%ld</ScheduleID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID><OrderID>%ld</OrderID></completeTreatment>", (long)scheduleId, (long)customerId, (long)ACC_ACCOUNTID, (long)orderID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// order 完成treatment by course id
- (AFHTTPRequestOperation *)requestCompleteTreatmentByCourseID:(NSInteger)courseId andCustomerID:(NSInteger)customerId andOrderID:(NSInteger)orderID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/completeTrearmentsByCourseID";
    NSString *message = [NSString stringWithFormat:@"<completeTrearmentsByCourseID xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld, \"CustomerID\":%ld, \"CourseID\":%ld, \"UpdaterID\":%ld ,\"OrderID\":%ld}</strJson></completeTrearmentsByCourseID>", (long)ACC_BRANCHID, (long)customerId, (long)courseId,(long)ACC_ACCOUNTID ,(long)orderID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// order 取消treatment
- (AFHTTPRequestOperation *)requestCancelTreatmentWithTreatmentID:(NSInteger)treatmentId OrderID:(NSInteger)orderID andScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/cancelTreatment";
    NSString *message = [NSString stringWithFormat:@"<cancelTreatment xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><OrderID>%ld</OrderID><TreatmentID>%ld</TreatmentID><ScheduleID>%ld</ScheduleID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID></cancelTreatment>",(long)ACC_BRANCHID, (long)orderID, (long)treatmentId, (long)scheduleId, (long)customerId, (long)ACC_ACCOUNTID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 更新treatment
- (AFHTTPRequestOperation *)requestUpdateTreatmentWithTreatment:(TreatmentDoc *)treatment OrderID:(NSInteger)orderID andScheduleTime:(NSString *)time andExecutorID:(NSInteger)executorId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateTreatmentDetail";
    NSString *message = [NSString stringWithFormat:@"<updateTreatmentDetail	xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><OrderID>%ld</OrderID><TreatmentID>%ld</TreatmentID><ScheduleID>%ld</ScheduleID><ScheduleTime>%@</ScheduleTime><ExecutorID>%ld</ExecutorID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID></updateTreatmentDetail>",(long)ACC_BRANCHID, (long)orderID, (long)treatment.treat_ID, (long)treatment.treat_Schedule.sch_ID, time, (long)executorId, (long)customerId, (long)ACC_ACCOUNTID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 完成treatment
- (AFHTTPRequestOperation *)requestUpdateResponsiblePersonWithOrderID:(NSInteger)orderId andResponsiblePersonID:(NSInteger)responsiblePersonId andCustomerID:(NSInteger)customerId andSalesID:(NSInteger)salesId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateResponsiblePerson";
    NSString *message = [NSString stringWithFormat:@"<updateResponsiblePerson xmlns=\"http://tempuri.org/\"><BranchID>%ld</BranchID><OrderID>%ld</OrderID><ResponsiblePersonID>%ld</ResponsiblePersonID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID><SalesID>%ld</SalesID></updateResponsiblePerson>",(long)ACC_BRANCHID, (long)orderId, (long)responsiblePersonId, (long)customerId, (long)ACC_ACCOUNTID, (long)salesId];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 更新treatmentremark
- (AFHTTPRequestOperation *)requestUpdateTreatmentRemarkWithTreatment:(TreatmentDoc *)treatment andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateTreatmentRemark";
    NSString *message = [NSString stringWithFormat:@"<updateTreatmentRemark	xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID><CustomerID>%ld</CustomerID><Remark>%@</Remark><UpdaterID>%ld</UpdaterID></updateTreatmentRemark>", (long)treatment.treat_ID, (long)customerId, treatment.treat_Remark, (long)ACC_ACCOUNTID];
    NSLog(@"message=%@", message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// order 更新treatmentremark
- (AFHTTPRequestOperation *)requestCompleteOrderWithOrderID:(NSInteger)orderId CustomerID:(NSInteger)customerId andOrderType:(NSInteger)orderType andFlag:(BOOL)finishFlag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/completeOrder_2_1";
//    NSString *message = [NSString stringWithFormat:@"<completeOrder xmlns=\"http://tempuri.org/\"><OrderID>%ld</OrderID><CustomerID>%ld</CustomerID><UpdaterID>%ld</UpdaterID></completeOrder>",(long)orderId, (long)customerId,  (long)ACC_ACCOUNTID];
    NSString *message = [NSString stringWithFormat:@"<completeOrder_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"UpdaterID\":%ld,\"CustomerID\":%ld,\"OrderType\":%ld,\"IsComplete\":%d}</strJson></completeOrder_2_1>",(long)ACC_BRANCHID, (long)orderId, (long)ACC_ACCOUNTID, (long)customerId, (long)orderType, finishFlag];

    NSLog(@"message:%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
//group
- (AFHTTPRequestOperation *)requestAddNewTreatmentGroupWithOrderID:(NSInteger)orderId CourseID:(NSInteger)courseId CustomerID:(NSInteger)customerId CreatorID:(NSInteger)creatorID IsDesign:(int)isDesign andSubServiceIDs:(NSString *)subService success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addTreatment_2_3_1";
    NSString *message = [NSString stringWithFormat:@"<addTreatment_2_3_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"OrderID\":%ld,\"CourseID\":%ld,\"CustomerID\":%ld,\"CreatorID\":%ld,\"IsDesignated\":%d,\"SubServiceIDs\":\"%@\"}</strJson></addTreatment_2_3_1>",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)orderId, (long)courseId, (long)customerId, (long)creatorID, isDesign, subService];
    
    NSLog(@"message:%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;

}

- (AFHTTPRequestOperation *)requestdeleteTreatmentWithCustomerID:(NSInteger)customerID OrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID AndGroup:(NSString *)group success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/deleteTreatment_2_3_1";
    NSString *message = [NSString stringWithFormat:@"<deleteTreatment_2_3_1 xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"CustomerID\":%ld,\"UpdaterID\":%ld,\"Group\":%@}</strJson></deleteTreatment_2_3_1>",(long)ACC_BRANCHID, (long)orderID, (long)customerID, (long)updaterID, group];
    
    NSLog(@"message:%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;

}

- (AFHTTPRequestOperation *)requestCompleteTreatmentByCustomerID:(NSInteger)customerID OrderID:(NSInteger)orderID Group:(NSString *)group  andUpdaterID:(NSInteger)updaterID  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/completeTrearmentsByGroupNo_2_3_1";
    NSString *message = [NSString stringWithFormat:@"<completeTrearmentsByGroupNo_2_3_1 xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"OrderID\":%ld,\"CustomerID\":%ld,\"Group\":%@,\"UpdaterID\":%ld}</strJson></completeTrearmentsByGroupNo_2_3_1>",(long)ACC_BRANCHID, (long)orderID, (long)customerID, group, (long)updaterID];
    
    NSLog(@"message:%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;

}



#pragma mark -- Treatment && Contact

// 更新contact (ACCOUNT)
- (AFHTTPRequestOperation *)requestUpdateContactDetailInfoWith:(ContactDoc *)contactDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateContact";
    NSString *message = [NSString stringWithFormat:@"<updateContact xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><Remark>%@</Remark><ContactID>%ld</ContactID><Status>%ld</Status><ScheduleID>%ld</ScheduleID></updateContact>",(long)ACC_ACCOUNTID, contactDoc.cont_Remark, (long)contactDoc.cont_ID, (long)contactDoc.cont_Schedule.sch_Completed, (long)contactDoc.cont_Schedule.sch_ID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message:%@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 更新treatment(ACCOUNT)
- (AFHTTPRequestOperation *)requestUpdateTreatmentDetailInfoWith:(TreatmentDoc *)treatmentDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateTreatment";
    NSString *message = [NSString stringWithFormat:@"<updateTreatment xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><Remark>%@</Remark><TreatmentID>%ld</TreatmentID><Status>%ld</Status><ScheduleID>%ld</ScheduleID></updateTreatment>",(long)ACC_ACCOUNTID, treatmentDoc.treat_Remark, (long)treatmentDoc.treat_ID,(long)treatmentDoc.treat_Schedule.sch_Completed, (long)treatmentDoc.treat_Schedule.sch_ID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message:%@",message);
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
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getTreatmentImage";
    NSString *message = [NSString stringWithFormat:@"<getTreatmentImage xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID><CompanyID>%ld</CompanyID><ImageHeight>120</ImageHeight><ImageWidth>120</ImageWidth></getTreatmentImage>", (long)treatId, (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -
#pragma mark - Category


// --Get Category List
// type = 0 服务 | type = 1 商品

- (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdAndBranchIdWithType:(NSInteger)type Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><Type>%ld</Type><AccountID>%ld</AccountID><BranchID>%ld</BranchID></getCategoryListByCompanyID>", (long)ACC_COMPANTID, (long)type,(long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestGetCategoryListByCategoryId:(NSInteger)categoryID type:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/category.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCategoryListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getCategoryListByCategoryID xmlns=\"http://tempuri.org/\"><CategoryID>%ld</CategoryID><BranchID>%ld</BranchID><Type>%ld</Type><AccountID>%ld</AccountID></getCategoryListByCategoryID>", (long)categoryID, (long)ACC_BRANCHID,(long)type,(long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}


#pragma mark - Product

// --Get Product List

- (AFHTTPRequestOperation *)requestGetCommodityListByCompanyIdAndBranchIdWithCustomerID:(NSInteger)customerID Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getCommodityListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID></getCommodityListByCompanyID>", (long)ACC_COMPANTID,(long)ACC_BRANCHID,(long)ACC_ACCOUNTID, (long)customerID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestGetCommodityListByCategoryID:(NSInteger)categoryID andCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getCommodityListByCategoryID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CategoryID>%ld</CategoryID><CustomerID>%ld</CustomerID><AccountID>%ld</AccountID></getCommodityListByCategoryID>", (long)ACC_COMPANTID,(long)ACC_BRANCHID, (long)categoryID, (long)customerID, (long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --Get Product Detail

- (AFHTTPRequestOperation *)requestGetCommodityDetail:(long long)commodityID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/commodity.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCommodityDetailByCommodityCode";
    NSString *message = [NSString stringWithFormat:@"<getCommodityDetailByCommodityCode xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CommodityCode>%lld</CommodityCode><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></getCommodityDetailByCommodityCode>", (long)ACC_COMPANTID,(long)ACC_BRANCHID,(long)ACC_ACCOUNTID ,(long long)commodityID, 280, 280];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark - Service

// --Get Service List

- (AFHTTPRequestOperation *)requestGetServiceListByCompanyIdAndBranchIdWithCustomerID:(NSInteger)customerID Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceListByCompanyID";
    NSString *message = [NSString stringWithFormat:@"<getServiceListByCompanyID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CustomerID>%ld</CustomerID></getServiceListByCompanyID>", (long)ACC_COMPANTID,(long)ACC_BRANCHID,(long)ACC_ACCOUNTID, (long)customerID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestGetServiceListByCategoryID:(NSInteger)categoryID andCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceListByCategoryID";
    NSString *message = [NSString stringWithFormat:@"<getServiceListByCategoryID xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CategoryID>%ld</CategoryID><CustomerID>%ld</CustomerID><AccountID>%ld</AccountID></getServiceListByCategoryID>", (long)ACC_COMPANTID,(long)ACC_BRANCHID, (long)categoryID, (long)customerID, (long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --Get Service Detail

- (AFHTTPRequestOperation *)requestGetServiceDetail:(NSInteger)serviceID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceDetailByServiceCode";
    NSString *message = [NSString stringWithFormat:@"<getServiceDetailByServiceCode xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><ServiceCode>%ld</ServiceCode><ImageWidth>%d</ImageWidth><ImageHeight>%d</ImageHeight></getServiceDetailByServiceCode>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID,(long)serviceID, 280, 280];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// --Get Service Detail after Version 2.1

- (AFHTTPRequestOperation *)requestGetServiceDetailByJson:(long long)serviceID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/service.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getServiceDetailByServiceCode_2_1";
    NSString *message = [NSString stringWithFormat:@"<getServiceDetailByServiceCode_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"ProductCode\":%lld,\"ImageWidth\":%d,\"ImageHeight\":%d,\"AccountID\":%ld}</strJson></getServiceDetailByServiceCode_2_1>", (long)ACC_COMPANTID, (long)ACC_BRANCHID,(long long)serviceID, 280, 280, (long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -

//用户修改密码
- (AFHTTPRequestOperation *)requestChangeAccountPasswordWithNewPassword:(NSString*)nPassword OldPassword:(NSString*)oPassword success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/user.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateUserPassword";
    NSString *message = [NSString stringWithFormat:@"<updateUserPassword xmlns=\"http://tempuri.org/\"><UserID>%ld</UserID><OldPassword>%@</OldPassword><NewPassword>%@</NewPassword></updateUserPassword>", (long)ACC_ACCOUNTID,[OverallMethods EscapingString:oPassword],[OverallMethods EscapingString:nPassword]];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 获取Company详细信息 (美容院详细信息)
- (AFHTTPRequestOperation *)requestGetBeautyShopInfoWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/webservice/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyDetail";
    NSString *message = [NSString stringWithFormat:@"<getCompanyDetail xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId></getCompanyDetail>", (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取Company图片
- (AFHTTPRequestOperation *)requestGetBeautyShopImages:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getCompanyImage";
    NSString *message = [NSString stringWithFormat:@"<getCompanyImage xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId></getCompanyImage>", (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}


// 修改Company信息 (美容院信息)
- (AFHTTPRequestOperation *)requestUpdateBeautyShopInfoWithMerchantDoc:(MerchantDoc *)merchantDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/webservice/company.asmx";
    NSString *soapActionString =  @"http://tempuri.org/companyUpdate";
    NSString *message = [NSString stringWithFormat:@"<companyUpdate xmlns=\"http://tempuri.org/\">"
                         "<accountId>%ld</accountId><companyId>%ld</companyId><name>%@</name>"
                         "<summary>%@</summary><contact>%@</contact><phone>%@</phone>"
                         "<fax>%@</fax><address>%@</address><zip>%@</zip>"
                         "<web>%@</web></companyUpdate>", (long)ACC_ACCOUNTID, (long)ACC_COMPANTID, merchantDoc.mer_Name, merchantDoc.mer_Intro, merchantDoc.mer_Linkman, merchantDoc.mer_Phone, merchantDoc.mer_Fax, merchantDoc.mer_Address, merchantDoc.mer_Postcode, merchantDoc.mer_Url];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取AccountList
- (AFHTTPRequestOperation *)requestGetAccountInfoListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString =  @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/GetAccList";
    NSString *message = [NSString stringWithFormat:@"<GetAccList xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId></GetAccList>",(long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
       // [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;

}

// 获取Account  by accountId
- (AFHTTPRequestOperation *)requestGetAccountInfoByAccountIWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getAccountDetail";
    NSString *message = [NSString stringWithFormat:@" <getAccountDetail xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID></getAccountDetail>", (long)ACC_ACCOUNTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
       // [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return operation;
}

//获得account提醒数量
- (AFHTTPRequestOperation *)requestMessageWithRemindWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/notice.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRemindCountByAccountID_1_7_2";
    NSString *message = [NSString stringWithFormat:@"<getRemindCountByAccountID_1_7_2 xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><BranchID>%ld</BranchID></getRemindCountByAccountID_1_7_2>", (long)ACC_ACCOUNTID ,(long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *operation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);

    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return operation;
}

// 请求NoticeList
- (AFHTTPRequestOperation *)requestGetNoticeListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        return nil;
    }
    NSString *kGPBasePathString =  @"/WebService/notice.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getNoticeList";
    NSString *message = [NSString stringWithFormat:@"<getNoticeList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID></getNoticeList>",(long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
        [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// 请求accountRemindList
- (AFHTTPRequestOperation *)requestGetRemindListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString =  @"/WebService/notice.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getRemindListByAccountID_1_7_2";
    NSString *message = [NSString stringWithFormat:@"<getRemindListByAccountID_1_7_2 xmlns=\"http://tempuri.org/\"><AccountID>%ld</AccountID><BranchID>%ld</BranchID></getRemindListByAccountID_1_7_2>", (long)ACC_ACCOUNTID,(long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
       // [[CacheInDisk cacheManger] setObject:xml forURL:kGPBasePathString];
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 订单支付页面-- e卡信息获得 by 吴旭
- (AFHTTPRequestOperation *)requestECardInfoByCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getEcardInfo";
    NSString *message = [NSString stringWithFormat:@"<getEcardInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getEcardInfo>", (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 订单支付页面-- e卡信息获得 by 吴旭
- (AFHTTPRequestOperation *)requestPaymentInfoViaJsonByOrderID:(NSString*)orderIdList success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentInfo";
    NSString *message = [NSString stringWithFormat:@"<getPaymentInfo xmlns=\"http://tempuri.org/\"><strJson>{\"OrderIDList\":\"%@\",\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld}</strJson></getPaymentInfo>", orderIdList,(long)ACC_COMPANTID,(long)ACC_BRANCHID, (long)ACC_ACCOUNTID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// 订单支付页面-- e卡支付 by 吴旭
- (AFHTTPRequestOperation *)requestPayAddByEcard:(NSInteger )orderNumber andUserId:(NSInteger)userId andStrPayAmount:(NSString *)strPayAmount andStrOrderId:(NSString *)strOrderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/payAddByEcard";
    NSString *message = [NSString stringWithFormat:@"<payAddByEcard xmlns=\"http://tempuri.org/\"><orderNumber>%ld</orderNumber><userId>%ld</userId><strPayAmount>%@</strPayAmount><strOrderId>%@</strOrderId></payAddByEcard>",(long)orderNumber, (long)userId, strPayAmount, strOrderId];
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
 - (AFHTTPRequestOperation *)requestGetPaymentListByCustomerID:(NSInteger)customerId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) {
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentList";
    NSString *message = [NSString stringWithFormat:@"<getPaymentList xmlns=\"http://tempuri.org/\"><strJson>{\"CustomerID\":%ld, \"BranchID\":%ld}</strJson></getPaymentList>", (long)customerId,(long)ACC_BRANCHID];
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
        return nil;
    }
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentDetail";
    NSString *message = [NSString stringWithFormat:@"<getPaymentDetail xmlns=\"http://tempuri.org/\"><strJson>{\"ID\":%ld, \"BranchID\":%ld}</strJson></getPaymentDetail>", (long)Id,(long)ACC_BRANCHID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
//ecard 修改过期时间
- (AFHTTPRequestOperation *)updateEcardExpirationTime:(NSInteger)customerId ExpirationTime:(NSString *) expirationTime  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/customer.asmx";
    NSString *soapActionString = @"http://tempuri.org/updateExpirationDate";
    NSString *message = [NSString stringWithFormat:@"<updateExpirationDate xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"ExpirationTime\":\"%@\",\"CustomerID\":%ld}</strJson></updateExpirationDate>", (long)ACC_COMPANTID, expirationTime, (long)customerId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 充值页面 by
- (AFHTTPRequestOperation *)requestRechargeToEcardWithCustomerID:(NSInteger)customerID
                                                   responsibleID:(NSInteger)responsibleID
                                                     rechargeWay:(NSInteger)rechargeWay
                                                  rechargeAmount:(CGFloat)rechargeAmount
                                                 presentedAmount:(CGFloat)presentedAmount
                                                          remark:(NSString *)remark
                                                     peopleCount:(NSInteger __unused)count
                                                         SlaveID:(NSString *)slaveIDs
                                                         success:(void (^)(id xml))success
                                                         failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/recharge_2_3_3";
//    NSString *message = [NSString stringWithFormat:@"<recharge xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><CustomerID>%ld</CustomerID><ResponsiblePersonID>%ld</ResponsiblePersonID><CreatorID>%ld</CreatorID><Mode>%ld</Mode><Amount>%.2f</Amount><Remark>%@</Remark><GiveAmount>%.2f</GiveAmount></recharge>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerID, (long)responsibleID, (long)ACC_ACCOUNTID, (long)rechargeWay, rechargeAmount, [OverallMethods EscapingString:remark], presentedAmount];
    NSString *message = [NSString stringWithFormat:@"<recharge_2_3_3 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"ResponsiblePersonID\":%ld,\"CreatorID\":%ld,\"RechargeMode\":%ld,\"Amount\":%.2f,\"Remark\":\"%@\",\"GiveAmount\":%.2f,\"SlaveID\":%@}</strJson></recharge_2_3_3>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerID, (long)responsibleID, (long)ACC_ACCOUNTID, (long)rechargeWay, rechargeAmount, [OverallMethods EscapingString:remark], presentedAmount, slaveIDs];

    
    // <PeopleCount>%.2ld</PeopleCount> , (long)count
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 等级修改页面 by 吴旭
- (AFHTTPRequestOperation *)requestLevelChangeToEcardWithLevelId:(NSInteger)levelId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger userId = appDelegate.customer_Selected.cus_ID;
    NSString *kGPBasePathString = @"/WebService/level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/changeLevel";
    NSString *message = [NSString stringWithFormat:@"<changeLevel xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID><LevelID>%ld</LevelID></changeLevel>",(long)userId, (long)levelId];
    NSLog(@"%@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -
#pragma mark - by oxb

// 添加Account信息 (美容师信息)
- (AFHTTPRequestOperation *)requestAddAccountInfo:(AccountDoc *)accountDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Account.asmx";
    
    NSString *soapActionString =  @"http://tempuri.org/AddAccDetail";
    NSString *message = [NSString stringWithFormat:@"<AddAccDetail xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId>"
                         "<name>%@</name><title>%@</title><department>%@</department><expert>%@</expert><introduction>%@</introduction><mobile>%@</mobile>"
                         "</AddAccDetail>",(long)ACC_COMPANTID, accountDoc.cos_Name,accountDoc.cos_Title, accountDoc.cos_Department, accountDoc.cos_Expert,accountDoc.cos_Introduction, accountDoc.cos_Mobile];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 修改Account信息 (美容师信息)
- (AFHTTPRequestOperation *)requestUpdateAccountWithHeadImage:(UIImage *)headImage imageType:(NSString *)imageType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *imgStr  = @"";
    if (headImage) {
        NSData *imgData = UIImageJPEGRepresentation(headImage, 0.3f);
        imgStr = [imgData base64EncodedString];
    }
    
    NSString *kGPBasePathString = @"/webservice/image.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateUserHeadImage";
    NSString *message = [NSString stringWithFormat:@"<updateUserHeadImage xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><UserID>%ld</UserID><UserType>1</UserType><ImageString>%@</ImageString><ImageType>%@</ImageType><ImageHeight>160.0</ImageHeight><ImageWidth>160.0</ImageWidth></updateUserHeadImage>", (long)ACC_COMPANTID, (long)ACC_ACCOUNTID, imgStr, imageType];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

- (AFHTTPRequestOperation *)requestChangeStatus:(NSInteger)available  theAccountId:(NSInteger)accountId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/account.asmx";
    NSString *soapActionString =  @"http://tempuri.org/ChangeAvailableState";
    NSString *message = [NSString stringWithFormat:@"<ChangeAvailableState xmlns=\"http://tempuri.org/\"><companyId>%ld</companyId><accountId>%ld</accountId><available>%ld</available></ChangeAvailableState>",(long)ACC_COMPANTID,(long)accountId,(long)available];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//// 获取BALANCE列表
- (AFHTTPRequestOperation *)requestGetgetBalanceWithSuccess:(NSInteger)customerID  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBalance";
    NSString *message = [NSString stringWithFormat:@"<getBalance xmlns=\"http://tempuri.org/\"><userId>%ld</userId></getBalance>", (long)customerID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 获取levelInfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getEcardInfo";
    NSString *message = [NSString stringWithFormat:@"<getEcardInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getEcardInfo>", (long)customerId];
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
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc paymentXML:(NSString *)payXML orderXML:(NSString *)orderXML isCompletedFlag:(NSInteger)isComFlag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addPayment";
    NSString *message = [NSString stringWithFormat:@"<addPayment xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><OrderCount>%ld</OrderCount><TotalPrice>%f</TotalPrice><AccountID>%ld</AccountID><Remark>%@</Remark><PaymentDetail>%@</PaymentDetail><OrderID>%@</OrderID><IsCompletedFlag>%ld</IsCompletedFlag></addPayment>", (long)ACC_COMPANTID, (long)payDoc.OrderNumber, payDoc.pay_TotalPrice, (long)ACC_ACCOUNTID, payDoc.Pay_Remark, payXML, orderXML, (long)isComFlag];
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
// 添加支付信息 By Json
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc paymentJson:(NSString *)payJson orderJson:(NSString *)orderJson isCompletedFlag:(NSInteger)isComFlag andCreateTime:(NSString*)createTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addPayment_2_1";
    NSString *message = [NSString stringWithFormat:@"<addPayment_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"PeopleCount\":%ld,\"OrderCount\":%ld,\"TotalPrice\":\"%f\",\"AccountID\":%ld,\"Remark\":\"%@\",\"PaymentDetailList\":%@,\"OrderIDList\":\"%@\",\"IsCompletedFlag\":%ld,\"CreateTime\":\"%@\"}</strJson></addPayment_2_1>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)payDoc.pay_peoplecount,(long)payDoc.OrderNumber, payDoc.pay_TotalPrice, (long)ACC_ACCOUNTID, payDoc.Pay_Remark, payJson, orderJson, (long)isComFlag,createTime];
    
    NSLog(@"message: %@",message);
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
//// 获取levelInfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger UserId = appDelegate.customer_Selected.cus_ID;    //
    NSString *kGPBasePathString = @"/WebService/ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getEcardInfo";
    NSString *message = [NSString stringWithFormat:@"<getEcardInfo xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getEcardInfo>", (long)UserId];
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
    if ([self networkStatus] == NO) return nil;
    NSString *kGPBasePathString = @"/WebService/ECard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getQRCode_1_7_5";
    NSString *message = [NSString stringWithFormat:@"<getQRCode_1_7_5 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyCode\":\"%@\",\"Code\":\"%ld\",\"Type\":\"%ld\",\"QRCodeSize\":\"%d\"}</strJson></getQRCode_1_7_5>", ACC_COMPANTCODE,(long)code, (long)type, 9];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 添加充值信息
- (AFHTTPRequestOperation *)requestRechargeBalance:(NSString *)rechargeAmount success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    NSInteger accountId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_USERID"] integerValue];
    NSString *kGPBasePathString = @"/WebService/Order.asmx";
    
    NSString *soapActionString =  @"http://tempuri.org/rechargeBalance";
    NSString *message = [NSString stringWithFormat:@"<rechargeBalance xmlns=\"http://tempuri.org/\"><customerId>%ld</customerId>"
                         "<accountId>%ld</accountId><amount>%@</amount>"
                         "</rechargeBalance>",(long)customerId,(long)accountId,rechargeAmount];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

//// 获取用户消费充值记录
- (AFHTTPRequestOperation *)requestGetRchargeAndPayWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger UserId = appDelegate.customer_Selected.cus_ID;
    NSString *kGPBasePathString = @"/WebService/ecard.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getBalanceHistory_1_7_2";
    NSString *message = [NSString stringWithFormat:@"<getBalanceHistory_1_7_2 xmlns=\"http://tempuri.org/\"><CustomerID>%ld</CustomerID></getBalanceHistory_1_7_2>", (long)UserId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}
- (AFHTTPRequestOperation *)requestGetBalanceDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure{
    if ([self networkStatus] == NO) {
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

// 更改顾客会员等级
- (AFHTTPRequestOperation *)requestChangeCustomerLevel:(NSInteger)levelId  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger customerId = appDelegate.customer_Selected.cus_ID;
    NSString *kGPBasePathString = @"/WebService/order.asmx";
    NSString *soapActionString =  @"http://tempuri.org/changeLevel";
    NSString *message = [NSString stringWithFormat:@"<changeLevel xmlns=\"http://tempuri.org/\"><customerId>%ld</customerId><levelId>%ld</levelId></changeLevel>",(long)customerId,(long)levelId];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    NSLog(@"message: %@",message);
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

// 顾客等级分类列表
- (AFHTTPRequestOperation *)requestLevelInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getLevelList";
    NSString *message = [NSString stringWithFormat:@"<getLevelList xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID></getLevelList>", (long)ACC_COMPANTID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

//获取顾客等级 0(有效)：ecard等级修改  1（取出所有）：顾客高级筛选
- (AFHTTPRequestOperation *)requestLevelListByFlag:(int)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getLevelList_2_2_2";
    NSString *message = [NSString stringWithFormat:@"<getLevelList_2_2_2 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"Flag\":%d}</strJson></getLevelList_2_2_2>", (long)ACC_COMPANTID, flag];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}


// 修改顾客等级分类列表
- (AFHTTPRequestOperation *)requestLevelDetailInfoWithArray:(NSMutableArray *)endSendArray success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/updateAllLevel";
    NSString *message = [NSString stringWithFormat:@"<updateAllLevel xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><AccountID>%ld</AccountID><LevelNameString>%@</LevelNameString><DiscountString>%@</DiscountString><LevelIDString>%@</LevelIDString><TagString>%@</TagString></updateAllLevel>",(long)ACC_COMPANTID, (long)ACC_ACCOUNTID, endSendArray[1], endSendArray[3], endSendArray[2], endSendArray[0]];
    
    NSLog(@"message=%@", message);
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
}

#pragma mark -
#pragma mark - Report

// --Report Basic
//  -cycleType:  0=日、   1=月、  2=季、 3=年 、4=自定义
//  -objectType: 0=个人、 1=单店、 2=公司
- (AFHTTPRequestOperation *)requestGetReportBasicWithBranchID:(NSInteger)branchID accountID:(NSInteger)accountID cycleType:(NSInteger)cycleType objectType:(NSInteger)objectType  startTime:(NSString*) startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/report.asmx";
    NSString *soapActionString_2_1 =  @"http://tempuri.org/getReportBasic_2_1";

    NSString *message = [NSString stringWithFormat:@"<getReportBasic_2_1 xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"AccountID\":%ld,\"CycleType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"ObjectType\":%ld}</strJson></getReportBasic_2_1>",(long)ACC_COMPANTID, (long)branchID, (long)accountID, (long)cycleType, startTime, endTime,(long)objectType];

    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString_2_1 message:message];

    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}
// --Report Total
// - CompanyID:
- (AFHTTPRequestOperation *)requestGetCompanyTotalReportWithCompanyID:(NSInteger)companyID BranchID:(NSInteger)branchID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/report.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getTotalCountReport";
    
    NSString *message = [NSString stringWithFormat:@"<getTotalCountReport xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld}</strJson></getTotalCountReport>",(long)companyID, (long)branchID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
    
    
    
}





// --Report List
//  -cycleType: 0=日、 1=月、 2=季、 3=年
// -objectType: 0=个人 1=分店
- (AFHTTPRequestOperation *)requestGetReportListWithCycleType:(NSInteger)cycleType objectType:(NSInteger)objectType startTime:(NSString *) start endTime:(NSString *)end success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/report.asmx";
    NSString *soapActionString_1_7_2 =  @"http://tempuri.org/getReportList_1_7_2";
    
    NSString *message = [NSString stringWithFormat:@"<getReportList_1_7_2 xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><CycleType>%ld</CycleType><StartTime>%@</StartTime><EndTime>%@</EndTime><ObjectType>%ld</ObjectType></getReportList_1_7_2>",(long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)ACC_ACCOUNTID, (long)cycleType, start, end, (long)objectType];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString_1_7_2 message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}


- (AFHTTPRequestOperation *)requestgetBranchTotalList:(NSInteger)companyID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/report.asmx";
    NSString *soapBranchTotalList =  @"http://tempuri.org/getBranchTotalList";
    
    NSString *message = [NSString stringWithFormat:@"<getBranchTotalList xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld}</strJson></getBranchTotalList>",(long)ACC_COMPANTID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapBranchTotalList message:message];
    
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;

}

// --Report Detail
// -flag:        0=个人 1=分店 2=公司
// -productType: 0=服务 1=商品
// -cycleType:   0=日、 1=月、 2=季、 3=年 、4=自定义
// -orderType:   0=customer 1=商品或者服务
- (AFHTTPRequestOperation *)requestGetReportDetailWithBranchID:(NSInteger)branchID accountID:(NSInteger)accountID objectType:(NSInteger)objectType productType:(NSInteger)productType cycleType:(NSInteger)cycleType orderType:(NSInteger)orderType  itemType:(NSInteger)itemType startTime:(NSString*) startTime endTime:(NSString *)endTime  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/report.asmx";
    NSString *soapActionString_1_7_2 =  @"http://tempuri.org/getReportDetail_1_7_2";
    NSString *message;

    message= [NSString stringWithFormat:@"<getReportDetail_1_7_2 xmlns=\"http://tempuri.org/\"><CompanyID>%ld</CompanyID><BranchID>%ld</BranchID><AccountID>%ld</AccountID><ObjectType>%ld</ObjectType><CycleType>%ld</CycleType><StartTime>%@</StartTime><EndTime>%@</EndTime><OrderType>%ld</OrderType><ProductType>%ld</ProductType><ExtractItemType>%ld</ExtractItemType></getReportDetail_1_7_2>",(long)ACC_COMPANTID, (long)branchID, (long)accountID, (long)objectType, (long)cycleType, startTime, endTime,(long)orderType, (long)productType, (long)itemType];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString_1_7_2 message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}

// 获取评价
- (AFHTTPRequestOperation *)requestGetReviewInfoByTreatmentId:(NSInteger)treatmentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/review.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getReviewDetail";
    NSString *message = [NSString stringWithFormat:@"<getReviewDetail xmlns=\"http://tempuri.org/\"><TreatmentID>%ld</TreatmentID></getReviewDetail>", (long)treatmentID];
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
}


#pragma mark notepad
- (AFHTTPRequestOperation *)requestNoteListCustomerID:(NSInteger)customerId ID:(NSInteger)ID TagsID:(NSString*)tagsID andViewType:(NSInteger)viewType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
        
    
    NSString *kGPBasePathString = @"/WebService/notepad.asmx";
    NSString *soapActionString = [NSString stringWithFormat:@"http://tempuri.org/%@",(customerId == 0 ? @"getNotepadListByAccountID" : @"getNotepadList") ];
    NSString *message = nil;
    if (customerId == 0) {
        message = [NSString stringWithFormat:@"<getNotepadListByAccountID xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"BranchID\":%ld,\"ID\":%ld,\"TagIDs\":\"%@\",\"ViewType\":%ld}</strJson></getNotepadListByAccountID>", (long)ACC_ACCOUNTID, (long)ACC_BRANCHID, (long)ID, tagsID, (long)viewType];

    } else {
        message = [NSString stringWithFormat:@"<getNotepadList xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"ID\":%ld,\"TagIDs\":\"%@\",\"ViewType\":%ld}</strJson></getNotepadList>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerId, (long)ID, tagsID, (long)viewType];

    }
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;

}

#pragma mark notepad 2_3_3
- (AFHTTPRequestOperation *)requestNoteListAccountID:(DFFilterSet *)filter NoteID:(NSInteger)noteID PageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/notepad.asmx";
    NSString *soapActionString = @"http://tempuri.org/getNotepadListByAccountID_2_3_3"; 
    NSString *message = [NSString stringWithFormat:@"<getNotepadListByAccountID_2_3_3 xmlns=\"http://tempuri.org/\"><strJson>{\"AccountID\":%ld,\"BranchID\":%ld,\"CompanyID\":%ld,\"RecordID\":%ld,\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"PageIndex\":%ld,\"PageSize\":%ld,\"TagIDs\":\"%@\",\"ResponsiblePersonID\":%ld,\"CustomerID\":%ld}</strJson></getNotepadListByAccountID_2_3_3>", (long)ACC_ACCOUNTID, (long)ACC_BRANCHID, (long)ACC_COMPANTID, (long)noteID, filter.timeFlag, filter.startTime, filter.endTime, (long)pagIndex, (long)pagSize, filter.tagIDs, (long)filter.personID, (long)filter.customerID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    return opertation;
    
}



- (AFHTTPRequestOperation *)requestAddNoteCustomerID:(NSInteger)customerId CreatorID:(NSInteger)creatorID TagIDS:(NSString *)tagIDS andContent:(NSString *)content success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/notepad.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addNotepad";
    NSString *message = [NSString stringWithFormat:@"<addNotepad xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CustomerID\":%ld,\"CreatorID\":%ld, \"TagIDs\":\"%@\",\"Content\":\"%@\"}</strJson></addNotepad>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)customerId, (long)creatorID, tagIDS, content];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
    return opertation;
}












#pragma mark Tag

-(AFHTTPRequestOperation *)requestGetTagListsuccess:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self networkStatus] == NO) return nil;
    
    
    NSString *kGPBasePathString = @"/WebService/Tag.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getTagList";
    NSString *message = [NSString stringWithFormat:@"<getTagList xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld}</strJson></getTagList>", (long)ACC_COMPANTID, (long)ACC_BRANCHID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
    return opertation;

}

- (AFHTTPRequestOperation *)requestAddTagCreatorID:(NSInteger)creatorID TagName:(NSString *)tagName success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Tag.asmx";
    NSString *soapActionString =  @"http://tempuri.org/addTag";
    NSString *message = [NSString stringWithFormat:@"<addTag xmlns=\"http://tempuri.org/\"><strJson>{\"CompanyID\":%ld,\"BranchID\":%ld,\"CreatorID\":%ld,\"Name\":\"%@\"}</strJson></addTag>", (long)ACC_COMPANTID, (long)ACC_BRANCHID, (long)creatorID, tagName];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
    return opertation;

    
    
}




#pragma mark -PayRecord
- (AFHTTPRequestOperation *)requestPayRecordCustomerID:(NSInteger)customerID  success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentList";
    NSString *message = [NSString stringWithFormat:@"<getPaymentList xmlns=\"http://tempuri.org/\"><strJson>{\"BranchID\":%ld,\"CreatorID\":%ld}</strJson></getPaymentList>", (long)ACC_BRANCHID, (long)customerID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
    
    
}


- (AFHTTPRequestOperation *)requestPaymentDetailPaymentID:(NSInteger)paymentID  success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Payment.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getPaymentDetail";
    NSString *message = [NSString stringWithFormat:@"<getPaymentDetail xmlns=\"http://tempuri.org/\"><strJson>{\"ID\":%ld}</strJson></getPaymentDetail>", (long)paymentID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    
    return opertation;
    
    
    
    
}

- (AFHTTPRequestOperation *)requestEcardInfoByLevelID:(NSInteger)levelID CustomerID:(NSInteger)customerID success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self networkStatus] == NO) return nil;
    
    NSString *kGPBasePathString = @"/WebService/Level.asmx";
    NSString *soapActionString =  @"http://tempuri.org/getDiscountListForWebService";
    NSString *message = [NSString stringWithFormat:@"<getDiscountListForWebService xmlns=\"http://tempuri.org/\"><strJson>{\"LevelID\":%ld,\"CustomerID\":%ld}</strJson></getDiscountListForWebService>", (long)levelID, (long)customerID];
    
    NSMutableURLRequest *urlRequest = [self requestWithPath:kGPBasePathString soapAction:soapActionString message:message];
    AFHTTPRequestOperation *opertation = [self enqueueHttpOperationWithRequest:urlRequest success:^(id xml) {
        success(xml);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return opertation;
    
}

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


@end
