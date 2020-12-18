//
//  ComOrderFilter.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/20.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComOrderFilter : NSObject
@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSString *personName;
@property (nonatomic, strong) NSPredicate *filterPred;
@end
