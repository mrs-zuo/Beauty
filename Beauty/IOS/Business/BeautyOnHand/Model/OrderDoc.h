//
//  OrderDoc.h
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-8-5.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductAndPriceDoc.h"
#import "CourseDoc.h"
#import "ContactDoc.h"

typedef NS_ENUM(NSInteger, OrderEditStatus) {
    OrderEditStatusNone = -1,
    OrderEditStatusIsMy = 1,
    OrderEditStatusBranch = 2
};
@class PaymentDoc;
@interface OrderDoc : NSObject
@property (assign, nonatomic) NSInteger order_AccountID;
@property (copy, nonatomic) NSString *order_AccountName;

@property (assign, nonatomic) NSInteger order_CustomerID;
@property (copy, nonatomic) NSString *order_CustomerName;

@property (assign, nonatomic) NSInteger order_CreatorID;
@property (copy, nonatomic) NSString *order_CreatorName;
@property (nonatomic, copy) NSString *order_CreateTime;



@property (assign, nonatomic) NSInteger order_Flag;//是否可以修改  0不可以  1可以

@property (assign, nonatomic) NSInteger order_ResponsiblePersonID;
@property (copy, nonatomic) NSString *order_ResponsiblePersonName;

//追加销售顾问
@property (nonatomic, assign) NSInteger order_SalesID;
@property (strong, nonatomic) NSMutableArray *order_SalesList;

@property (strong, nonatomic) NSString *order_Remark;
@property (nonatomic, assign) CGFloat remark_height;  //订单备注高度
// --Order Info
@property (assign, nonatomic) NSInteger order_ObjectID;
@property (assign, nonatomic) NSInteger order_ID;
@property (copy, nonatomic) NSString *order_OrderTime;
@property (copy, nonatomic) NSString *order_Number;     //订单编号
@property (nonatomic, copy) NSString *order_Branch;     //下单门店
@property (nonatomic, assign) NSInteger order_BranchId; //下单门店ID 用于判断是否是本店所开订单
@property (assign, nonatomic) NSInteger order_OrderSource;//订单来源
@property (assign, nonatomic) int order_Status;  // 服务 1：进行中、2：已完成、3：已取消。  (全部为-1)    商品 0：进行中、1：已完成、2：已取消、 3：待确认 4、已终止 (全部为-1)
@property (assign, nonatomic) int order_Ispaid;  // 1：未支付、 2：部分付 3:已支付
@property (assign, nonatomic) bool order_AppointMustPaid; //预约是否显示于结账后。1为是，0为否，默认为0

/**  价格 */
@property (nonatomic, assign) long double order_totalPrice;//--总价
@property (nonatomic, assign) long double order_UnPaidPrice; //未支付金额
@property (nonatomic, assign) long double order_calcPrice;//--会员价

/**订单状态*/
@property (strong, nonatomic, readonly) NSString *order_StatusStr;
@property (strong, nonatomic, readonly) NSString *order_IspaidStr;
/**TG的状态*/
@property (nonatomic ,assign) int order_TGStatus;
@property (nonatomic ,strong) NSString * order_TGStatusStr;

@property (strong, nonatomic) NSString *order_PayRemark;
@property (assign, nonatomic) bool order_OnceCompleted;
@property (nonatomic, assign) NSInteger  isThisBranch;
@property (nonatomic, assign) NSInteger  order_CourseFrequency;
@property (nonatomic ,assign) NSInteger  order_ServiceOn; //进行中的服务 0是无进行 1 是有进行的服务




@property (nonatomic, assign) BOOL isMyOrder;
@property (nonatomic, assign) OrderEditStatus editStatus;
// --Product Info
// 保存着serviceDoc或者commodityDoc对象的集合、totalMoeny、discountMoney、flag所有信息 （包含了Product中的所有信息）
@property (strong, nonatomic) ProductAndPriceDoc *productAndPriceDoc;


// --Others
@property (strong, nonatomic) NSMutableArray *productArray;
@property (strong, nonatomic) NSMutableArray *courseArray;
@property (strong, nonatomic) NSMutableArray *contractArray;
@property (nonatomic, strong) NSMutableArray * finishiServeArr;
@property (nonatomic ,strong) NSMutableArray * unFinishiServeArr;
@property (nonatomic ,strong) NSMutableArray * BenefitListArr;

@property (nonatomic ,strong) NSArray * order_TGListArr;
@property (assign, nonatomic) bool order_allCourceCompleted;   //所有的课程的treatment是否都完成

@property (copy, nonatomic) NSString *strOrderDetail;
@property (copy, nonatomic) NSString *strCourse;
@property (copy, nonatomic) NSString *strContact;

@property (assign, nonatomic) NSInteger ctlFlag;

@property (assign, nonatomic) NSInteger order_ProductType;//  0服务  1商品

/// 是否电子签
@property (nonatomic,assign) NSInteger IsConfirmed;

@property (nonatomic,copy) NSString *ThumbnailURL;


@end
