//
//  PromotionListRes.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/24.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYZBaseModel.h"

@interface PromotionListRes : CYZBaseModel

@property (nonatomic,copy) NSString *StartDate;
@property (nonatomic,copy) NSString *EndDate;

@property (nonatomic,assign) int type;
@property (nonatomic,assign) BOOL HasProduct;

@property (nonatomic,copy) NSString *Description;
@property (nonatomic,copy) NSString *PromotionCode;
@property (nonatomic,copy) NSString *PromotionPictureURL;
@property (nonatomic,copy) NSString *Title;

@end
