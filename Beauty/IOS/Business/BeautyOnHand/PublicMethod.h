//
//  UrlCheck.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-11-21.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicMethod : NSObject

@property (nonatomic, assign) BOOL containURL;
@property (nonatomic, copy) NSArray *rangeArray;

- (NSArray *)checkString:(NSString *)string;

@end
