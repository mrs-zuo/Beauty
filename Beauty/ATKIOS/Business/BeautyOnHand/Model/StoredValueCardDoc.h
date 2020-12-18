//
//  StoredValueCardDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoredValueCardDoc : NSObject
@property (assign, nonatomic) NSInteger storedValueCard_ID;
@property (copy, nonatomic) NSString *storeCardlevel;
@property (copy, nonatomic) NSString *storeCardDiscount;     // 住宅1 工作2 其他3

@end
