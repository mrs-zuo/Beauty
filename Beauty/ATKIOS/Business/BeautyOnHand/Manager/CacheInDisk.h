//
//  CacheInDisk.h
//  GlamourPromise
//
//  Created by GuanHui on 13-6-25.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheInDisk : NSObject

+ (id)cacheManger;
- (void)setObject:(NSString *)xml forURL:(NSString *)urlStr;
- (NSString *)objectForURL:(NSString *)urlStr;
- (void)removeAllCache;
@end
