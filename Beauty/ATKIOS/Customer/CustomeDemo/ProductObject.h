//
//  ProductObject.h
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-5-28.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GPProductSellingWay) {
    GPProductSellingWayOriginalPrice  = 0,  //原价
    GPProductSellingWayDiscountPrice  = 1,  //折扣价
    GPProductSellingWayPromotionPrice = 2,  //促销价
};
@interface ProductSold : NSObject
@property (assign, nonatomic) NSInteger product_branchId;
@property (copy, nonatomic) NSString *product_branchName;
@property (assign, nonatomic) NSInteger product_quantity;
@property (assign, nonatomic) NSInteger product_storageType;
@property (copy, nonatomic) NSString *product_storageTypeStr;
@end

@interface ProductObject : NSObject

//产品外接属性
@property (assign, nonatomic) NSInteger product_belongsCompanyID;       //产品所属公司ID


//产品基本属性
@property (assign, nonatomic) long long product_code;                   //产品Code(产品的唯一标识)
@property (assign, nonatomic) long long product_ID;                     //产品ID(用以区分相同产品的不同版本)
@property (retain, nonatomic) NSString *product_name;                   //产品名称
@property (retain, nonatomic) NSString *product_searchField;            //搜索域
@property (retain, nonatomic) NSString *product_describe;               //产品介绍
@property (assign, nonatomic) CGFloat product_nameHeight;               //产品名称高度
@property (assign, nonatomic) CGFloat product_describeHeight;           //产品介绍高度


//产品图片属性
@property (retain, nonatomic) NSString *product_thumbnail;              //产品缩略图
@property (strong, nonatomic) NSArray *product_pictureURLArray;         //产品图片URL Array


//产品销售属性
@property (assign, nonatomic) GPProductSellingWay product_sellingWay;   //产品销售方法
@property (assign, nonatomic) CGFloat product_originalPrice;            //产品原价
@property (assign, nonatomic) CGFloat product_promotionPrice;           //产品促销价(可能为0)
@property (assign, nonatomic) CGFloat product_discountPrice;           //产品促销价(可能为0)
@property (assign, nonatomic) CGFloat product_salesPrice;               //产品销售价(一定有值)
@property (retain, nonatomic, readonly) NSString *product_originalPriceStr;     //产品原价字符串（保留两位小数）
@property (retain, nonatomic, readonly) NSString *product_promotionPriceStr;    //产品促销价字符串（保留两位小数）
@property (retain, nonatomic, readonly) NSString *product_discountPriceStr;    //产品折扣价价字符串（保留两位小数）
@property (retain, nonatomic, readonly) NSString *product_salesPriceStr;        //产品销售价字符串（保留两位小数）

@property (assign,nonatomic) NSString *  product_expirationDate;//有效期

@property (strong, nonatomic) NSArray *product_soldBranch;
@property (assign, nonatomic) NSInteger product_selectedIndex;

//计算高度
- (CGFloat)valuationProductNameHeightWithFont:(UIFont *)font;
- (CGFloat)valuationProductDescribeHeightWithFont:(UIFont *)font;


//计算产品销售价
- (void)valuationProductSalesPrice;



@end
