//
//  RecommendedProductListRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/24.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYZBaseModel.h"

@interface RecommendedProductListRes : CYZBaseModel

@property (nonatomic,assign) BOOL New;
@property (nonatomic,assign) long long ProductCode;
@property (nonatomic,assign) int  ProductID;
@property (nonatomic,copy) NSString *ProductName;
@property (nonatomic,assign) int  ProductType;
@property (nonatomic,assign) BOOL Recommended;
@property (nonatomic,copy) NSString *SearchField;
@property (nonatomic,assign) int  SortID;
@property (nonatomic,copy) NSString *Specification;
@property (nonatomic,copy) NSString *ThumbnailURL;
@property (nonatomic,assign) double  UnitPrice;

@end
