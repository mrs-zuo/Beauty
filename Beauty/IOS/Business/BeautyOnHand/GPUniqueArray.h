//
//  GPUniqueArray.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPUniqueArray : NSObject
@property (nonatomic, strong) NSMutableArray *container;
@property (nonatomic, copy) NSString *uniqueKey;
@property (nonatomic, assign) NSInteger containerCount;

- (instancetype)initWithUniqueKey:(NSString *)key;
- (void)addGPObjectArray:(NSArray *)array;
- (void)addGPObject:(id)object;
- (void)removeGPObject:(id)object;
- (BOOL)containerGPObject:(id)object;
@end
