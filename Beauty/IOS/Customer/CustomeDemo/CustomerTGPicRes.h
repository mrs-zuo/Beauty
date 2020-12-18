//
//  CustomerTGPicRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 16/3/2.
//  Copyright © 2016年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomerTGPicRes : NSObject

@property (nonatomic,copy) NSString *serviceName;
@property (nonatomic,strong) NSNumber *serviceCode;
@property (nonatomic,copy) NSString *TGStartTime;
@property (nonatomic,strong) NSNumber *branchID;
@property (nonatomic,copy) NSString *branchName;
@property (nonatomic,copy) NSString *comments;
@property (nonatomic,copy) NSString *groupNo;
@property (nonatomic,strong) NSMutableArray *TGPicList;




@end
