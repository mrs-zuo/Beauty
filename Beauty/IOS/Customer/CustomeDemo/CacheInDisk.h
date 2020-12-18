//
//  CacheInDisk.h
//  GlamourPromise
//
//  Created by TRY-MAC01 on 13-6-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CacheInDisk : NSObject

+ (id)cacheManger;
- (void)setObject:(NSString *)xml forURL:(NSString *)urlStr;
- (NSString *)objectForURL:(NSString *)urlStr;
- (void)removeAllCache;
@end
