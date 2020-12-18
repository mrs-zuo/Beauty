//
//  OrderInfo.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/10.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OrderInfo.h"
#import "GPBHTTPClient.h"
@implementation OrderInfo

- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
        _count = _SurplusCount;
        _isFinish = YES;
        [_SubServiceList enumerateObjectsUsingBlock:^(SubService *sub, NSUInteger idx, BOOL *stop) {
            sub.ExecutorID = _AccountID;
            sub.ExecutorName = _AccountName;
        }];
    }
    return self;
}

- (void)setCount:(NSInteger)ct
{
    if (ct >= 0 && ct <= self.SurplusCount) {
        _count = ct;
    }
}
- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"SubServiceList"]) {
        self.SubServiceList = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in value) {
            [self.SubServiceList addObject:[[SubService alloc] initWithDic:dic accname:_AccountName accid:_AccountID]];
        }
//        if (self.SubServiceList.count == 0) {
//            [self.SubServiceList addObject:[[SubService alloc] initWithServiceAccname:_AccountName accid:_AccountID]];
//        }
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (NSMutableArray *)groupList
{
    if (_groupList == nil) {
        _groupList = [[NSMutableArray alloc] init];
        SubServiceGroup *subGroup = [[SubServiceGroup alloc] initWithServiceArray:_SubServiceList accountName:_AccountName accountID:_AccountID];
        [_groupList addObject:subGroup];
    }
    return _groupList;
}

- (NSInteger)subServiceCount
{
    _subServiceCount = 0;
    for (SubServiceGroup *grou in self.groupList) {
        _subServiceCount += grou.serviceCount;
    }
    
    return _subServiceCount;
}

- (NSString *)StatusTitleSer
{
    if (_TotalCount == 0) {
        _StatusTitleSer = [NSString stringWithFormat:@"完成%ld次/不限次", (long)_FinishedCount];
    } else {
        //===========以下是wugang修改
        //===========以下是Ryan修改========
        //long surplusCount = (long) (_SurplusCount - self.groupList.count);
        //==========以上是Ryan修改=========
        _StatusTitleSer = [NSString stringWithFormat:@"进行中%ld次/完成%ld次/共%ld次",_TotalCount-_SurplusCount-(long)_FinishedCount, (long)_FinishedCount,(long)_TotalCount];
        //==========以上是wugang修改=========
    }
    return _StatusTitleSer;
}

- (NSString *)SurplusTitleSer
{
    if (_TotalCount == 0) {
        _SurplusTitleSer = @"";
    } else {
        _SurplusTitleSer = [NSString stringWithFormat:@"剩余%lu次", (_SurplusCount - self.groupList.count)];
    }
    return _SurplusTitleSer;
}

- (NSString *)StatusTitleCom
{
    _StatusTitleCom = [NSString stringWithFormat:@"已交%ld件/共%ld件", (long)_FinishedCount, (long)_TotalCount];
    return _StatusTitleCom;
}

- (NSString *)SurplusTitleCom
{
    _SurplusTitleCom = [NSString stringWithFormat:@"剩余%ld件", (long)_SurplusCount];
    return _SurplusTitleCom;
}

- (NSString *)parameter
{
    if (self.ProductType == 1) {
        _parameter = [NSString stringWithFormat:@"{\"OrderID\":%ld,\"OrderObjectID\":%ld,\"ProductType\":%ld,\"Remark\":\"%@\",\"Count\":%ld,\"IsFinish\":%d}", (long)self.OrderID, (long)self.OrderObjectID, (long)self.ProductType, self.Remark, (long)self.count, self.isFinish];
    } else {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        if (self.groupList.count == 0) {
            _parameter = [NSString stringWithFormat:@"{\"OrderID\":%ld,\"TaskID\":%lld,\"OrderObjectID\":%ld,\"ProductType\":%ld,\"Remark\":\"%@\",\"ServicePIC\":0,\"IsDesignated\":0,\"TreatmentList\":[]}", (long)self.OrderID,(long long)self.taskID, (long)self.OrderObjectID, (long)self.ProductType, self.Remark];
        } else {
            for (SubServiceGroup *serviceGroup in self.groupList) {
                NSString *tmpString = [NSString stringWithFormat:@"{\"OrderID\":%ld,\"TaskID\":%lld,\"OrderObjectID\":%ld,\"ProductType\":%ld,\"Remark\":\"%@\",%@}", (long)self.OrderID,(long long)self.taskID, (long)self.OrderObjectID, (long)self.ProductType, self.Remark, [serviceGroup parDesignatedServiceIDAndTreatmentList]];
                [tmpArray addObject:tmpString];
            }
            _parameter = [tmpArray componentsJoinedByString:@","];
        }
    }
    return _parameter;
}

+ (AFHTTPRequestOperation *)requestOrderInfoArray:(NSString *)orderIDs TaskID:(long long)taskID AccountDic:(NSDictionary *)userDic completionBlock:(void (^)(NSArray *, NSString *, NSInteger))block
{
    NSString *par = [NSString stringWithFormat:@"{\"listOrderID\":[%@]}", orderIDs];
    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetOrderInfoList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

                OrderInfo * order = [[OrderInfo alloc] initWithDic:obj];
                
                if (order.SubServiceList.count ==0) {
                    SubService *sub = [[SubService alloc] init];
                     if (userDic != nil) {
                        sub.ExecutorID = [userDic[@"AccID"] integerValue];
                        sub.ExecutorName = userDic[@"AccName"];
                     }else
                     {
                         sub.ExecutorID = [[obj objectForKey:@"AccountID"]integerValue];
                         sub.ExecutorName = [obj objectForKey:@"AccountName"];
                     }
                    [order.SubServiceList  addObject:sub];
                }
                if (userDic != nil) {
        
                    [order.SubServiceList enumerateObjectsUsingBlock:^(SubService *sub, NSUInteger idx, BOOL *stop) {
                        sub.ExecutorID = [userDic[@"AccID"] integerValue];
                        sub.ExecutorName = userDic[@"AccName"];
                    }];
                
                    [order.groupList enumerateObjectsUsingBlock:^(SubServiceGroup *obj, NSUInteger idx, BOOL *stop) {
                        obj.serviceID = [userDic[@"AccID"] integerValue];
                        obj.serviceName = userDic[@"AccName"];
                    }];
                }
                [order setTaskID:(long long)taskID];
                [tmpArray addObject:order];
//                [tmpArray addObject:[[OrderInfo alloc] initWithDic:obj]];
            }];
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"SurplusCount == 0 && TotalCount != 0"];
            
            NSArray *removeArray = [tmpArray filteredArrayUsingPredicate:pred];
            
            if (removeArray.count) {
                [tmpArray removeObjectsInArray:removeArray];
            }
            
            block(tmpArray, message, code);
            
        } failure:^(NSInteger code, NSString *error) {
            block(nil, error, code);
        }];
    } failure:^(NSError *error) {
            block(nil, error.localizedDescription, -100);
    }];
}

//+ (AFHTTPRequestOperation *)requestCommitOrder:(NSArray *)orderArray completionBlock:(void (^)(NSString *, NSInteger))block
//{
//    NSMutableArray *tmpArray = [NSMutableArray array];
//    for (OrderInfo *order in orderArray) {
//        if ((order.ProductType == 1 && order.count == 0) || (order.ProductType == 0 && order.groupList.count == 0)) {
//            continue ;
//        }
//        [tmpArray addObject:order.parameter];
//    }
//    if (tmpArray.count == 0) {
//        block(@"", -11);
//        return nil;
//    }
//    NSString *par = [NSString stringWithFormat:@"{\"TGDetailList\":[%@]}",[tmpArray componentsJoinedByString:@","]];
//
//    return [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/AddTreatGroup" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
//        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
//            block(message, code);
//        } failure:^(NSInteger code, NSString *error) {
//            block(error, code);
//        }];
//    } failure:^(NSError *error) {
//        
//    }];
//}



@end


@implementation SubServiceGroup

- (instancetype)initWithServiceArray:(NSArray *)array accountName:(NSString *)accName accountID:(NSInteger)accID
{
    self = [super init];
    if (self) {
        _isDesignated = NO;
        _serviceName = accName;
        _serviceID = accID;
        
        if (array.count == 0) {
            _serviceList = [[NSMutableArray alloc] init];
//            _serviceList = [NSMutableArray arrayWithObject:[[SubService alloc] initWithServiceAccname:_serviceName accid:_serviceID]];
        } else {
            _serviceList = [[NSMutableArray alloc ] initWithArray:array copyItems:YES];
        }
    }
    return self;
}

- (NSInteger)serviceCount
{
    _serviceCount = 2 + self.serviceList.count;
    return _serviceCount;
}

- (NSString *)parDesignatedServiceIDAndTreatmentList
{
    NSMutableArray *tmpArray = [NSMutableArray array];
    if (self.serviceList.count == 0) {
        NSString *treatmentList = [NSString stringWithFormat:@"{\"SubServiceID\":0,\"ExecutorID\":%ld}", (long)self.serviceID];
        [tmpArray addObject:treatmentList];
    } else {
        for (SubService *sub in self.serviceList) {
            NSString *treatmentList = [NSString stringWithFormat:@"{\"SubServiceID\":%ld,\"ExecutorID\":%ld,\"IsDesignated\":%d}", (long)sub.SubServiceID, (long)sub.ExecutorID,sub.isDesignated];
            [tmpArray addObject:treatmentList];
        }
    }
    NSString *str = [NSString stringWithFormat:@"\"ServicePIC\":%ld,\"IsDesignated\":%d,\"TreatmentList\":[%@]", (long)self.serviceID, self.isDesignated, [tmpArray componentsJoinedByString:@","]];
    return str;
}

@end


@implementation SubService

- (instancetype)initWithServiceAccname:(NSString *)name accid:(NSInteger)accid
{
    self = [super init];
    if (self) {
        _SubServiceName = @"服务操作";
        _ExecutorID = accid;
        _ExecutorName = name;
    }
    return self;
}
- (instancetype)initWithDic:(NSDictionary *)dic accname:(NSString *)name accid:(NSInteger)accid
{
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
        _ExecutorID = accid;
        _ExecutorName = name;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    SubService *newSub = [[self class] allocWithZone:zone];
    newSub.SubServiceID = self.SubServiceID;
    newSub.SubServiceName = self.SubServiceName;
    newSub.ExecutorID = self.ExecutorID;
    newSub.ExecutorName = self.ExecutorName;
    return newSub;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    NSLog(@"%s", __FUNCTION__);
}
@end
