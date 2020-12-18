//
//  OrderInfo.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/10.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;

@interface OrderInfo : NSObject
@property (nonatomic, assign) NSInteger OrderID;
@property (nonatomic, assign) NSInteger OrderObjectID;
@property (nonatomic, assign) NSInteger ProductType; // 商品1 ， 服务0
@property (nonatomic, strong) NSString *ProductName;
@property (nonatomic, strong) NSString *SubServiceIDs;
@property (nonatomic, strong) NSString *Remark;
@property (nonatomic, assign) CGFloat  Remark_Height;
@property (nonatomic, strong) NSString *AccountName;
@property (nonatomic, assign) NSInteger AccountID;
@property (nonatomic ,assign) long long taskID;
@property (nonatomic,assign) NSInteger IsConfirmed;
/*
 *后台传回的标准子服务格式
 */
@property (nonatomic, strong) NSMutableArray *SubServiceList;

/*
 *前台界面显示
 */
@property (nonatomic, strong) NSMutableArray *groupList;
@property (nonatomic, assign) NSInteger subServiceCount;

@property (nonatomic, assign) NSInteger ExecutingCount;
@property (nonatomic, assign) NSInteger FinishedCount;
@property (nonatomic, assign) NSInteger TotalCount;
@property (nonatomic, assign) NSInteger SurplusCount;

@property (nonatomic, strong) NSString *StatusTitleSer;
@property (nonatomic, strong) NSString *SurplusTitleSer;

@property (nonatomic, strong) NSString *StatusTitleCom;
@property (nonatomic, strong) NSString *SurplusTitleCom;

@property (nonatomic, strong) NSString *serviceID;

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL      isFinish;

@property (nonatomic, strong) NSString *parameter;

- (instancetype)initWithDic:(NSDictionary *)dic;
+ (AFHTTPRequestOperation *)requestOrderInfoArray:(NSString *)orderIDs TaskID:(long long)taskID AccountDic:(NSDictionary *)userDic completionBlock:(void (^)(NSArray *, NSString *, NSInteger ))block;
//+ (AFHTTPRequestOperation *)requestCommitOrder:(NSArray *)orderArray completionBlock:(void(^)(NSString *, NSInteger ))block;
@end


@interface SubServiceGroup : NSObject
@property (nonatomic, strong) NSString *serviceName;
@property (nonatomic, assign) NSInteger serviceID;
@property (nonatomic, assign) BOOL isDesignated;
@property (nonatomic, strong) NSMutableArray *serviceList;
@property (nonatomic, assign) NSInteger serviceCount;

- (instancetype)initWithServiceArray:(NSArray *)array accountName:(NSString *)accName accountID:(NSInteger)accID;
- (NSString *)parDesignatedServiceIDAndTreatmentList;
@end


@interface SubService : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger SubServiceID;
@property (nonatomic, strong) NSString *SubServiceName;
@property (nonatomic, strong) NSString *ExecutorName;
@property (nonatomic, assign) NSInteger ExecutorID;
@property (nonatomic, assign) BOOL isDesignated;
- (instancetype)initWithDic:(NSDictionary *)dic accname:(NSString *)name accid:(NSInteger)accid;
- (instancetype)initWithServiceAccname:(NSString *)name accid:(NSInteger)accid;
@end


