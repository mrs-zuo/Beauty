//
//  BeautyRecordRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/2/29.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BeautyRecordRes : NSObject
@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,strong) NSNumber *serviceCode;
@property (nonatomic,strong) NSMutableArray *imageURLArrs;

@end
