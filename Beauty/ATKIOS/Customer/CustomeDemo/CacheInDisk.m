//
//  CacheInDisk.m
//  GlamourPromise
//
//  Created by TRY-MAC01 on 13-6-25.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CacheInDisk.h"

#define DATA_FOLDER_NAME @"DATA_CACHE"
@implementation CacheInDisk
static id cacheManger;

+ (id)cacheManger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheManger = [[CacheInDisk alloc] init];
    });
    return cacheManger;
}

- (NSString *)returnDataCachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *cachePath = [path stringByAppendingPathComponent:DATA_FOLDER_NAME];
    NSFileManager *fileManger = [[NSFileManager alloc] init];
    if (![fileManger fileExistsAtPath:cachePath]) {
        [fileManger createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}


- (void)setObject:(NSString *)xml forURL:(NSString *)urlStr
{
    NSString *newURLStr1 = [urlStr stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    NSString *newURLStr2 = [NSString stringWithFormat:@"%@.plist", [newURLStr1 substringFromIndex:1]];
    NSString *plistPath = [[self returnDataCachePath] stringByAppendingPathComponent:newURLStr2];
    
    NSLog(@"plistPath set:%@", plistPath);
//
//    NSFileManager* fm = [NSFileManager defaultManager];
//    if ([fm createFileAtPath:plistPath contents:nil attributes:nil] ) {
//        NSLog(@"success");
//    } else {
//        NSLog(@"failure");
//    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:xml, urlStr, nil];
    [dic writeToFile:plistPath atomically:YES];
}


- (NSString *)objectForURL:(NSString *)urlStr
{
    NSString *newURLStr1 = [urlStr stringByReplacingOccurrencesOfString:@"/" withString:@"."];
    NSString *newURLStr2 = [NSString stringWithFormat:@"%@.plist", [newURLStr1 substringFromIndex:1]];
    NSString *plistPath = [[self returnDataCachePath] stringByAppendingPathComponent:newURLStr2];
    NSLog(@"plistPath get:%@", plistPath);
    
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSLog(@"data:%@", dic[urlStr]);
    return dic[urlStr];
}

- (void)removeAllCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[self returnDataCachePath] error:nil];
}



@end
