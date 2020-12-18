//
//  OppStepObject.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OppStepObject : NSObject
@property (nonatomic, strong) NSString *StepName;
@property (nonatomic, assign) NSInteger StepID;

- (id)initWithDictionary:(NSDictionary *)dic;
@end
