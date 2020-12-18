//
//  ShopInfoModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopInfoModel : NSObject
@property (nonatomic, assign) NSInteger BranchID;
@property (nonatomic, assign)   BOOL Visible;
@property (nonatomic, copy)   NSString *BranchName;
@property (nonatomic, copy)   NSString *Address;
@property (nonatomic, copy)   NSString *Phone;
@property (nonatomic, copy)   NSString *Fax;
@property (copy,nonatomic) NSString *Distance;

- (instancetype)initWithDic:(NSDictionary *)dic;
@end
