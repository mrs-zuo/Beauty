//
//  CommodityDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-27.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "CommodityDoc.h"
#import "DEFINE.h"
#import "AppDelegate.h"
#import "CustomerDoc.h"

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
        self.comm_Quantity = 1;
        _comm_DisplayImgArray = [NSArray array];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (id)initWithSpecialDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {

        self.comm_ID = [[dictionary objectForKey:@"CommodityID"] integerValue];
        self.comm_Code = [[dictionary objectForKey:@"CommodityCode"] longLongValue];
        self.comm_CommodityName = [dictionary objectForKey:@"CommodityName"];
        self.comm_CommoditySearchField = [dictionary objectForKey:@"SearchField"];
        self.comm_UnitPrice = [[dictionary objectForKey:@"UnitPrice"] doubleValue];
        self.comm_PromotionPrice = [[dictionary objectForKey:@"PromotionPrice"] doubleValue];
        self.comm_NewBrand = [[dictionary objectForKey:@"New"] integerValue];
        self.comm_Recommended = [[dictionary objectForKey:@"Recommended"] integerValue];
        self.comm_Specification = [dictionary objectForKey:@"Specification"];
        self.comm_MarketingPolicy = [[dictionary objectForKey:@"MarketingPolicy"] integerValue];
        NSString *picUrl = [dictionary objectForKey:@"ThumbnailURL"];
        if ([picUrl isKindOfClass:[NSNull class]]) {
            picUrl = nil;
        }
        self.comm_ImgURL = picUrl;
        self.comm_FavouriteID = [[dictionary objectForKey:@"FavoriteID"] integerValue];
    
    }
    return self;

}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{

    if ([key isEqual:@"CommodityID"]) {
        self.comm_ID = [value integerValue];
    }
    if ([key isEqual:@"CommodityCode"]) {
        self.comm_Code = [value longLongValue];
    }
    if ([key isEqual:@"CommodityName"]) {
        self.comm_CommodityName = value;
    }
    if ([key isEqual:@"SearchField"]) {
        self.comm_CommoditySearchField = value;
    }
    if ([key isEqual:@"UnitPrice"]) {
        self.comm_UnitPrice = [value doubleValue];
    }
    if ([key isEqual:@"PromotionPrice"]) {
        self.comm_PromotionPrice = [value doubleValue];
    }
    if ([key isEqual:@"New"]) {
        self.comm_NewBrand = [value integerValue];
    }
    if ([key isEqual:@"Recommended"]) {
        self.comm_Recommended = [value integerValue];
    }
    if ([key isEqual:@"Specification"]) {
        self.comm_Specification = value;
    }
    if ([key isEqual:@"MarketingPolicy"]) {
        self.comm_MarketingPolicy = [value integerValue];
    }
    if ([key isEqual:@"ThumbnailURL"]) {
        self.comm_ImgURL = value;
    }
    if ([key isEqual:@"FavoriteID"]) {
        self.comm_FavouriteID = [value integerValue];
    }
    if ([key isEqual:@"Describe"]) {
        self.comm_Describe = value;
    }
    if ([key isEqual:@"StockCalcType"]) {
        self.comm_StockCalc = [NSString stringWithFormat:@"%@", value];
    }
    if ([key isEqual:@"CommodityImage"]) {
        self.comm_DisplayImgArray = value;
    }
    if ([key isEqual:@"StockQuantity"]) {
        self.comm_StockQuantity = [value integerValue];
    }

}
-(long double)comm_CalculatePrice
{
    switch (_comm_MarketingPolicy) {
        case 0:
            _comm_CalculatePrice = _comm_UnitPrice;
            break;
        case 1:
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CustomerDoc *cus_Selected = [appDelegate customer_Selected];
            _comm_CalculatePrice = cus_Selected ? _comm_PromotionPrice: _comm_UnitPrice;
            
            break;
        }
        case 2:
            _comm_CalculatePrice = _comm_PromotionPrice;
            
            break;
            
        default:
            break;
    }
    
    return _comm_CalculatePrice;

}
//- (CGFloat)comm_CalculatePrice {
//    switch (_comm_MarketingPolicy) {
//        case 0:
//            _comm_CalculatePrice = _comm_UnitPrice;
//            break;
//        case 1:
//        {
//            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            CustomerDoc *cus_Selected = [appDelegate customer_Selected];
//            _comm_CalculatePrice = cus_Selected ? _comm_PromotionPrice: _comm_UnitPrice;
//
//            break;
//        }
//        case 2:
//            _comm_CalculatePrice = _comm_PromotionPrice;
//
//            break;
//
//        default:
//            break;
//    }
//    
//    return _comm_CalculatePrice;
//}


//- (void)setComm_CommodityName:(NSString *)newComm_CommodityName
//{
//   _comm_CommodityName = newComm_CommodityName;
//    
//    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = _comm_CommodityName;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
//    float currentHeight = size.height;
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    textView = nil;
//    _comm_HeightForName = currentHeight;
//
//}

- (CGFloat)comm_HeightForName {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _comm_CommodityName;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    textView = nil;
    return currentHeight;
}

//- (void)setComm_Describe:(NSString *)newComm_Describe
//{
//    _comm_Describe = newComm_Describe;
//    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = _comm_Describe;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(290.0f, FLT_MAX)];
//    float currentHeight = size.height;
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    textView = nil;
//    _comm_HeightForDescribe = currentHeight;
//}

- (CGFloat)comm_HeightForDescribe
{
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _comm_Describe;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(290.0f, FLT_MAX)];
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    textView = nil;
    _comm_HeightForDescribe = currentHeight;
    return _comm_HeightForDescribe;
}
- (NSString *)comm_StockCalc
{
    
    if ([_comm_StockCalc isEqualToString:@"1"]) {
        return @"普通库存";
    } else if ([_comm_StockCalc isEqualToString:@"2"]) {
        return @"不计库存";
    } else if ([_comm_StockCalc isEqualToString:@"3"]) {
        return @"超卖库存";
    } else {
        return @"普通库存";
    }
    
}


@end
