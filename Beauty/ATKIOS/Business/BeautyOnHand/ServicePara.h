//
//  ServicePara.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/3/17.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServicePara : NSObject <NSCoding>

@property (nonatomic,assign) NSInteger ServicePIC;
@property (nonatomic,assign) NSInteger ProductType;
@property (nonatomic,assign) NSInteger Status;
@property (nonatomic,assign) NSInteger FilterByTimeFlag;
@property (nonatomic,copy) NSString *TGStartTime;

@property (nonatomic,copy) NSString *StartTime;
@property (nonatomic,copy) NSString *EndTime;
@property (nonatomic,assign) NSInteger PageIndex;
@property (nonatomic,assign) NSInteger PageSize;
@property (nonatomic,assign) NSInteger CustomerID;

//本地
//顾问Name
@property (nonatomic,copy) NSString *ServicePICName;
//顾客Name
@property (nonatomic,copy) NSString *CustomerName;
//默认顾问
@property (nonatomic, strong) NSMutableArray *accountArray;

@end
