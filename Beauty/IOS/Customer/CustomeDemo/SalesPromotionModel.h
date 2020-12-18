//
//  SalesPromotionModel.h
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesPromotionModel : NSObject
@property (nonatomic, copy) NSString *StartDate;
@property (nonatomic, copy) NSString *EndDate;
@property (nonatomic, copy) NSString *PromotionContent;
@property (nonatomic, copy) NSString *PromotionPictureURL;
@property (nonatomic, assign) NSInteger PromotionID;
@property (nonatomic, strong) NSArray *BranchList;
@property (nonatomic, assign) NSInteger PromotionType;
@property (nonatomic,copy) NSString * Title;
@property (nonatomic, copy) NSString *promotionDate;
@property (nonatomic, copy) NSString *PromotionCode;//
@property (nonatomic, copy) NSString *Description;//
- (instancetype)initWithDic:(NSDictionary *)dic;
@end
