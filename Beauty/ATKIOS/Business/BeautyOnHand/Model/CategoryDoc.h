//
//  CategoryDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@interface CategoryDoc : NSObject

@property (assign, nonatomic) NSInteger category_BranchID;
@property (assign, nonatomic) NSInteger CategoryID; //Category_ID
@property (assign, nonatomic) NSInteger category_ParentID;
@property (copy, nonatomic) NSString *CategoryName; //Category_CategoryName

@property (assign, nonatomic) int NextCategoryCount;  //Category_Flag 0没有下级目录  1有下级目录
@property (assign, nonatomic) int ProductCount;  //Category_Count 下级目录或其详细列表的数量

- (id)initWithDictionary:(NSDictionary *)dictionary;


+ (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdAndBranchIdWithType:(NSString *)par completionBlock:(void(^)(NSArray *array,int count, NSString *mesg, NSError *error))block;

+ (AFHTTPRequestOperation *)requestGetCategoryListByParentId:(NSString *)par completionBlock:(void(^)(NSArray *array,int count, NSString *mesg, NSError *error))block;
@end
