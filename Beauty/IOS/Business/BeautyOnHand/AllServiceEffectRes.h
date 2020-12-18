//
//  AllServiceEffectRes.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/22.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AllServiceEffectRes : NSObject

@property (nonatomic,assign) double GroupNo;
@property (nonatomic,copy) NSString* TGStartTime;
@property (nonatomic,copy) NSString *ServiceName;
@property (nonatomic,assign) NSInteger OrderID;
@property (nonatomic,assign) NSInteger OrderObjectID;
@property (nonatomic,strong) NSMutableArray *ImageEffects;

@end
