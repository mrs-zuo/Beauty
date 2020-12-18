//
//  ProductAndPriceDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-10-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ProductAndPriceDoc.h"
#import "DEFINE.h"
#import "OppStepObject.h"
#import "EcardInfo.h"   
#import "WelfareRes.h"
@implementation ProductDoc

//- (void)setPro_Name:(NSString *)pro_Name
//{
//    _pro_Name = pro_Name;
//    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = _pro_Name;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
//    float currentHeight = size.height;
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    textView = nil;
//    _pro_HeightOfProductName = currentHeight;
//}

- (CGFloat)pro_HeightOfProductName {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _pro_Name;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    textView = nil;
    return  currentHeight;

}

//- (double)pro_TotalCalcPrice
//{
//    _pro_TotalCalcPrice = _pro_PromotionPrice * _pro_quantity;
//    return _pro_TotalCalcPrice;
//}



- (double)retCalculatePrice
{
    switch (_pro_MarketingPolicy) {
        case 0: return _pro_Unitprice;
        case 1: return _pro_Unitprice * _pro_Discount;
        case 2: return _pro_PromotionPrice;
        default: return 0.0f;
    }
}

@end

@implementation ProductAndPriceDoc

- (id)init
{
    self = [super init];
    if (self) {
        _productArray = [NSMutableArray array];
        _productDoc = [[ProductDoc alloc] init];
    }
    return self;
}

- (CGFloat)table_Height
{
    float tHeight = 0.0f;
    for (ProductDoc *productDoc in _productArray) {
        tHeight += productDoc.pro_HeightOfProductName;
        
        if (productDoc.pro_IsShowDiscountMoney) {
            tHeight += 3 * kTableView_HeightOfRow;
        } else {
            tHeight += 2 * kTableView_HeightOfRow;
        }
        tHeight += (kTableView_Margin_Bottom + kTableView_Margin_TOP);
        
        if (IOS6) tHeight += 2;
        
        if (productDoc.pro_Status == 1) {
            tHeight += kTableView_HeightOfRow;
        }
    }

    //--总价和优惠价
    if ([_productArray count] > 1)
    {
        tHeight += (kTableView_HeightOfRow + kTableView_Margin_TOP + kTableView_Margin_Bottom) * 2;
        if (IOS6) tHeight += 2;
    }
    
    return tHeight;
}


- (double)retDiscountMoney
{
    double  discountMoney = 0.0f;
    for (ProductDoc *productDoc  in _productArray) {
        if ([productDoc isKindOfClass:[ProductDoc class]]) {
            discountMoney += productDoc.pro_TotalSaleMoney;
        }
    }
    return discountMoney;
}

- (double)retTotalMoney
{
    double totalMoney = 0.0f;
    for (ProductDoc *productDoc  in _productArray) {
        if ([productDoc isKindOfClass:[ProductDoc class]]) {
            totalMoney += productDoc.pro_TotalMoney;
        }
    }
    return totalMoney;
}

- (void)initIsShowDiscountMoney
{
    for (ProductDoc *productDoc  in _productArray) {
        if ([productDoc isKindOfClass:[ProductDoc class]]) {
            if (productDoc.pro_TotalCalcPrice != productDoc.pro_TotalSaleMoney) {  //productDoc.pro_TotalMoney != productDoc.pro_TotalSaleMoney
                productDoc.pro_IsShowDiscountMoney = YES;
            } else {
                productDoc.pro_IsShowDiscountMoney = NO;
            }
        }
    }
    _productDoc.pro_IsShowDiscountMoney = _productDoc.pro_TotalSaleMoney != _productDoc.pro_TotalCalcPrice; //_productDoc.pro_TotalSaleMoney != _productDoc.pro_TotalMoney
}
@end
