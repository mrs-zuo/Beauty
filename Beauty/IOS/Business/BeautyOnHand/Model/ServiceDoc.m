//
//  ServerDoc.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-9-9.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ServiceDoc.h"
#import "DEFINE.h"
#import "AppDelegate.h"
@implementation SubServiceDoc

@end
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
        self.service_Quantity = 1;
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqual:@"ServiceID"]) {
        self.service_ID = [value integerValue];
    }
    if ([key isEqual:@"ServiceCode"]) {
        self.service_Code = [value longLongValue];
    }
    if ([key isEqual:@"ServiceName"]) {
        self.service_ServiceName = value;
    }
    if ([key isEqual:@"SearchField"]) {
        self.service_ServiceSearchField = value;
    }
    if ([key isEqual:@"UnitPrice"]) {
        self.service_UnitPrice = [value doubleValue];
    }
    if ([key isEqual:@"PromotionPrice"]) {
        self.service_PromotionPrice = [value doubleValue];
    }
    if ([key isEqual:@"New"]) {
        self.service_NewBrand = [value integerValue];
    }
    if ([key isEqual:@"Recommended"]) {
        self.service_Recommended = [value integerValue];
    }
    if ([key isEqual:@"MarketingPolicy"]) {
        self.service_MarketingPolicy = [value integerValue];
    }
    if ([key isEqual:@"ExpirationTime"]) {
        self.service_ExpirationTime = value;
    }
    if ([key isEqual:@"ThumbnailURL"]) {
        self.service_ImgURL = value;
    }
    if ([key isEqual:@"FavoriteID"]) {
        self.service_FavouriteID = [value integerValue];
    }

    if ([key isEqual:@"Describe"]) {
        self.service_Describe = value;
    }
    if ([key isEqual:@"SpendTime"]) {
        self.service_SpendTime = [value integerValue];
    }
    if ([key isEqual:@"CourseFrequency"]) {
        self.service_CourseFrequency = [value integerValue];
    }
    if ([key isEqual:@"ServiceImage"]) {
        self.service_DisplayImgArray = value;
    }
    
    if ([key isEqual:@"FileUrl"]) {
        self.service_ImgURL = value;
    }
    if ([key isEqual:@"ExpirationDate"]) {
        self.service_ExpirationTime = value;
    }
    if ([key isEqual:@"Available"]) {
        self.service_Available = [value boolValue];
    }
    if ([key isEqual:@"ProductName"]) {
        self.service_ServiceName = value;
    }
    if ([key isEqual:@"ProductCode"]) {
        self.service_Code = [value longLongValue];
    }
    
    if ([key isEqual:@"ProductID"]) {
        self.service_ID = [value integerValue];
    }
    if ([key isEqual:@"ID"]) {
        self.service_FavouriteID = [value integerValue];
    }


}


- (long double)service_CalculatePrice {
        switch (_service_MarketingPolicy) {
            case 0:
            {
                _service_CalculatePrice = _service_UnitPrice;
            }
                break;
            case 1:
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                CustomerDoc *cus_Selected = [appDelegate customer_Selected];
                _service_CalculatePrice = cus_Selected ? _service_PromotionPrice : _service_UnitPrice;
            }
                break;
            case 2:
            {
                _service_CalculatePrice = _service_PromotionPrice;
            }
                break;
            default:
                break;
        }
    
        return _service_CalculatePrice;
}









//- (void)setService_ServiceName:(NSString *)service_ServiceName
//{
//    _service_ServiceName = service_ServiceName;
//    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = service_ServiceName;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
//    float currentHeight = size.height;
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    textView = nil;
//    _service_HeightForProductName = currentHeight;
//}

- (CGFloat)service_HeightForProductName {
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _service_ServiceName;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    textView = nil;
    return currentHeight;

}

//- (void)setService_Describe:(NSString *)service_Describe
//{
//    _service_Describe = service_Describe;
//    
//    
//    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
//    textView.text = service_Describe;
//    textView.font = kFont_Light_16;
//    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
//    float currentHeight = size.height;
//    if (currentHeight < kTableView_HeightOfRow) {
//        currentHeight = kTableView_HeightOfRow;
//    }
//    textView = nil;
//    _service_HeightForDescribe = currentHeight;
//}

- (CGFloat)service_HeightForDescribe
{
    __autoreleasing UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.text = _service_Describe;
    textView.font = kFont_Light_16;
    CGSize size = [textView sizeThatFits:CGSizeMake(300, FLT_MAX)];
    float currentHeight = size.height;
    if (currentHeight < kTableView_HeightOfRow) {
        currentHeight = kTableView_HeightOfRow;
    }
    textView = nil;
    _service_HeightForDescribe = currentHeight;
    return _service_HeightForDescribe;
}


@end
