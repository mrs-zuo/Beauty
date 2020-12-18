//
//  SalesPromotionDoc.h
//  CustomeDemo
//
//  Created by macmini on 13-9-4.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SalesPromotionDoc : NSObject

@property (assign,nonatomic) NSInteger salesPromotion_ID;
@property (copy,nonatomic)NSString  *PromotionCode;
@property (assign,nonatomic) NSInteger salesPromotion_Type;
@property (copy,nonatomic) NSString *salesPromotion_Text;
@property (copy,nonatomic) NSString *salesPromotion_Url;
@property (copy,nonatomic) NSString *salesPromotion_BranchName;
@property (copy,nonatomic) NSString *salesPromotion_StartTime;
@property (copy,nonatomic) NSString *salesPromotion_EndTime;
@property (assign,nonatomic) BOOL isShow;
@end
