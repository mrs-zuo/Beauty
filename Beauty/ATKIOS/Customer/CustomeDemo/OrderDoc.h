//
//  OrderDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PaymentDoc;
@class ServiceDoc;
@class CommodityDoc;
@class ProductAndPriceDoc;
@class TGList;
@interface OrderDoc : NSObject

@property (strong, nonatomic) TGList *tgList;
@property (strong, nonatomic) NSMutableArray *tgListMuArray;
@property (assign, nonatomic) NSInteger order_ObjectID;
@property (assign, nonatomic) NSInteger order_ID;       //订单ID
@property (copy, nonatomic) NSString *order_Number;     //订单编号 GPB-965 追加
@property (assign, nonatomic) NSInteger order_Count;     //订单数量，多个订单同时支付
@property (copy  , nonatomic) NSString *order_OrderTime;//订单时间
@property (assign  , nonatomic) NSInteger order_BranchId;   //下单的门店
@property (copy  , nonatomic) NSString *order_BranchName;//下单的门店名称

@property (assign, nonatomic) NSInteger order_Type;     //订单类型  0服务  1商品
@property (assign, nonatomic) NSInteger order_Status;   //订单完成状态 0:未完成  1:已完成  2:已取消
@property (assign, nonatomic) NSInteger order_Ispaid;   //订单支付状态 0:未支付  >0:已支付
@property (strong, nonatomic, readonly) NSString *order_StatusStr;//订单完成状态(服务文字)
@property (strong, nonatomic, readonly) NSString *order_StatusStrForCommodity;////订单完成状态(商品文字)
@property (strong, nonatomic, readonly) NSString *order_IspaidStr;//订单支付状态(支付文字)
@property (strong, nonatomic) NSString *order_PayRemark;//支付备注
@property (assign, nonatomic) NSInteger order_AccountID;//订单美丽顾问ID
@property (copy  , nonatomic) NSString *order_AccountName;//订单美丽顾问
@property (assign, nonatomic) NSInteger order_CreatorID;//订单创建人
@property (copy  , nonatomic) NSString *order_CreatorName;//订单创建人
@property (assign, nonatomic) NSInteger order_CustomerID;//

@property (copy  , nonatomic) NSString *order_ProductName;//因为一对一，所以存储产品或服务名称
@property (assign, nonatomic) NSInteger order_ProductNumber;//订单中产品数量
@property (assign, nonatomic) CGFloat order_TotalPrice;//订单中产品总原价
@property (assign, nonatomic) CGFloat order_TotalSalePrice;//订单中产品总优惠价
@property (assign, nonatomic) CGFloat order_UnPaidPrice;//部分支付时，未支付的部分

@property (strong, nonatomic) PaymentDoc *order_Payment;
@property (strong, nonatomic) NSMutableArray *productArray;
@property (strong, nonatomic) NSMutableArray *courseArray;
@property (strong, nonatomic) NSMutableArray *contractArray;

@property (assign, nonatomic) NSInteger status;   //订单选择状态 

@property (strong, nonatomic) ProductAndPriceDoc *productAndPriceDoc;

@property (strong, nonatomic) NSArray *OrderDetail;
@property (copy, nonatomic) NSString *strCourse;
@property (copy, nonatomic) NSString *strContact;
@property (assign, nonatomic) NSInteger ctlFlag;

@property (assign, nonatomic) NSInteger order_TreatmentID;   //订单确认时用到
@property (copy, nonatomic) NSString *order_Remark;   //订单确认时用到

@property (nonatomic ,assign) int order_TGStatus; //TG的状态
@property (nonatomic ,copy) NSString * order_TGStatusStr;

@property (nonatomic ,assign)NSInteger componyId;
/*
 * 订单中的默认卡
 */
@property (nonatomic ,assign)NSInteger cardID;
@property (copy  , nonatomic) NSString *order_cardName;

//杨添加的内容
@property (copy, nonatomic) NSString * productName;
@property (copy, nonatomic) NSString * tGStartTime;
@property (copy, nonatomic) NSString * accountName;
@property (copy, nonatomic) NSString * accountID;
@property (copy, nonatomic) NSString * paymentStatus;
@property (assign, nonatomic) NSInteger totalCount;
@property (assign, nonatomic) NSInteger finisHedCount;
@property (assign, nonatomic) long long  groupNo;
@property (assign, nonatomic) NSInteger orderID;
@property (copy, nonatomic) NSString * orderObjectID;
@property (assign, nonatomic) NSInteger productType;
@property (copy, nonatomic) NSString * productTypeStatus;
@property (copy, nonatomic) NSString * headImageURL;
@property (assign, nonatomic) NSInteger statusNew;
@property (copy, nonatomic) NSString * customerName;
@property (copy, nonatomic) NSString * customerID;
@property (copy, nonatomic) NSString * isDesignated;
@property (copy, nonatomic) NSString * totalCalcPrice;
@property (assign, nonatomic) NSInteger tGStatus;
@property (copy, nonatomic) NSString * tG_StatusStr;
@property (copy, nonatomic) NSString * tGEndTime;
@property (copy, nonatomic) NSString * serviceName;
@property (copy, nonatomic) NSString * responsiblePersonName;

//丁晓雷 添加的内容
@property (nonatomic,assign) NSInteger tGFinishedCount;
@property (nonatomic,assign) NSInteger tGTotalCount;
//@property (nonatomic,assign) NSInteger productType;
@property (nonatomic,assign) NSInteger branchID;

@end
