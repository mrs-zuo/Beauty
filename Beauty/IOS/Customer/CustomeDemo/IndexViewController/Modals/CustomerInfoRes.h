//
//  CustomerInfoRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/24.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYZBaseModel.h"

@interface CustomerInfoRes : CYZBaseModel


@property (nonatomic,assign) int AllOrderCount;
@property (nonatomic,assign) int NeedConfirmTGCount;
@property (nonatomic,assign) int NeedReviewTGCount;
@property (nonatomic,assign) int UnPaidCount;

@property (nonatomic,copy) NSString *CompanyCode;
@property (nonatomic,copy) NSString *CustomerName;
@property (nonatomic,copy) NSString *DefaultCardNo;
@property (nonatomic,copy) NSString *HeadImageURL;
@property (nonatomic,copy) NSString *LoginMobile;





@end
