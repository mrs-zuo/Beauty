//
//  LevelDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by MAC_Lion on 13-8-21.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LevelDoc : NSObject

@property (assign, nonatomic) NSInteger level_ID;
@property (copy, nonatomic) NSString *level_Name;
@property (assign, nonatomic) float level_Discount;

@property (assign, nonatomic) int ctlFlag; // 未修改0 添加1 更改2 删除3

@end
