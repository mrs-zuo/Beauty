//
//  ServerDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ServiceDoc.h"
#import "DEFINE.h"

@interface ServiceDoc()
@property (assign, nonatomic) int count;
@end

@implementation ServiceDoc
@synthesize service_isShowDiscountMoney;
@synthesize count;

- (id)init
{
    self = [super init];
    if (self) {
        self.service_ProductName = @"";
        self.service_Quantity = 1;
    }
    return self;
}

- (void)setService_ProductName:(NSString *)service_ProductName
{
    _service_ProductName = service_ProductName;

    CGFloat currentHeight = [_service_ProductName sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300, FLT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20;
    _service_HeightForProductName = currentHeight;
}

- (void)setService_Quantity:(NSInteger)service_Quantity
{
    _service_Quantity = service_Quantity;
}

- (void)setService_UnitPrice:(CGFloat)service_UnitPrice
{
    _service_UnitPrice = service_UnitPrice;
}

- (CGFloat)retTotalMoney
{
    return _service_UnitPrice * _service_Quantity;
}

- (CGFloat)retDiscountMoney
{
    return _service_PromotionPrice * _service_Quantity;
}

@end
