//
//  CategoryDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryDoc : NSObject

@property (assign, nonatomic) NSInteger category_BranchID;
@property (assign, nonatomic) NSInteger category_ID;
@property (assign, nonatomic) NSInteger category_ParentID;
@property (copy, nonatomic) NSString *category_CategoryName;

@property (assign, nonatomic) NSInteger category_Flag;  // 0没有下级目录  1有下级目录
@property (assign, nonatomic) NSInteger category_Count;  // 下级目录或其详细列表的数量
@end
