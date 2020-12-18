//
//  CommodityDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CommodityDoc.h"
#import "DEFINE.h"

@interface CommodityDoc ()
@property (assign, nonatomic) int count;
@end

@implementation CommodityDoc
@synthesize count;

- (id)init
{
    self = [super init];
    if (self) {
        count = 0;
        [self setComm_CommodityName:@""];
        [self setComm_Describe:@""];
        [self setComm_Quantity:1];
        _comm_DisplayImgArray = [NSArray array];
    }
    return self;
}

- (void)setComm_CommodityName:(NSString *)newComm_CommodityName
{
    _comm_CommodityName = newComm_CommodityName;
    CGFloat currentHeight = [newComm_CommodityName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    _comm_HeightForName = currentHeight;
}

- (void)setComm_Describe:(NSString *)newComm_Describe
{
    _comm_Describe = newComm_Describe;
    
    CGSize size = [_comm_Describe sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(290.0f, 300.0f) lineBreakMode:NSLineBreakByWordWrapping];
    if (size.height == 0) {
        _comm_HeightForDescribe = 18.0f;
    } else {
        _comm_HeightForDescribe = size.height;
    }
}

- (long double)retTotalMoney
{
    return  _comm_UnitPrice * _comm_Quantity;
}

- (long double)retDiscountMoney
{
    return _comm_PromotionPrice * _comm_Quantity;
}

@end
