//
// MLHTTPClient.h
// GlamourPromise
//
// Created by TRY-MAC01 on 13-6-24.
// Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "CustomerDoc.h"
#import "RecordDoc.h"
#import "OrderDoc.h"
#import "CommentDoc.h"


@class MessageDoc;
@class AFHTTPRequestOperation;
@class ProductAndPriceDoc;
@class PayDoc;
@class CommodityDoc;
@class CommodityObject;
@interface GPHTTPClient : AFHTTPClient

+ (id)shareClient;

- (AFNetworkReachabilityStatus)networkStatus;

//上传图像
- (AFHTTPRequestOperation *)requestUploadImage:(UIImage *)headImage success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Login

//登陆Operation
- (AFHTTPRequestOperation *)requestCustomerLoginWithMobile:(NSString *)mobile passwd:(NSString *)pwd success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//选择所登录公司后返回登录信息
- (AFHTTPRequestOperation *)requestReturnLoginInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取验证码
- (AFHTTPRequestOperation *)requestGetAuthenticationCodeWithMobile:(NSString *)mobile success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//验证验证码
- (AFHTTPRequestOperation *)requestCheckAuthenticationCodeWithMobile:(NSString *)mobile authenticationCode:(NSString *)code success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//通过customerId修改密码
- (AFHTTPRequestOperation *)requestUpdateCustomerPasswordWithCustomerID:(NSString *)customerIdStr LoginMobile:(NSString*)mobile NewPassword:(NSString *)password success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取信息
- (AFHTTPRequestOperation *)requestGetCompanyInfoWithCustomerID:(NSInteger)customerId CompanyID:(NSInteger)companyId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Account

//请求customerList
- (AFHTTPRequestOperation *)requestAccountListWithBranchID:(NSInteger)branchId andFlag:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求AccountDetail
-(AFHTTPRequestOperation *) requestAccountDetailWithAccountId:(NSInteger)accountId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Company

//请求business Detail
-(AFHTTPRequestOperation *) requestBusinessDetailWithAccountId:(NSInteger)branchId success:(void (^)(id xml)) success failure:(void (^)(NSError *error))failure;

//获取图片
- (AFHTTPRequestOperation *)requestComanyPic:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure;

//获得分支机构列表
- (AFHTTPRequestOperation *)requestBeautySalonListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获得分支机构详情
- (AFHTTPRequestOperation *)requestBeautySalonDetailWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取分支机构图片
- (AFHTTPRequestOperation *)requestComanyBranchPicWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -- Setting

//请求个人基本信息
- (AFHTTPRequestOperation *)requestBasicInfo:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure;

//修改个人基本信息
- (AFHTTPRequestOperation *)updateBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml)) success failure:(void (^) (NSError *error))failure;

//用户修改密码
- (AFHTTPRequestOperation *)requestChangeCustomerPasswordWithNewPassword:(NSString*)nPassword oldPassword:(NSString*)oPassword success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//用户修改头像
- (AFHTTPRequestOperation *)requestChangeCustomerPhotoWithImageString:(NSString *)imageString andImageType:(NSString *)imageType andImageWidth:(double)imageWidth andImageHeight:(double)imageHeight success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Record

- (AFHTTPRequestOperation *)requestRecordList:(void (^)(id xml)) success failure:(void(^)(NSError *error))failure;

#pragma mark -- Chat

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestTheTotalCountOfNewMessageWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求Customer List和最后的聊天记录、时间
- (AFHTTPRequestOperation *)requestGetAccountSelectListWithId:(NSInteger)branchId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求Message List byOneToOne
- (AFHTTPRequestOperation *)requestGetMessageListByOneToOneWithAccountId:(NSInteger)AccountId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//发送消息 byOneToOne
- (AFHTTPRequestOperation *)requestSendMessageByOneToOneWithMessage:(MessageDoc *)messageDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获得最新消息 byOneToOne
- (AFHTTPRequestOperation *)requestGetNewMessageWithAccountId:(NSInteger)accountId lastMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


//获得历史记录
- (AFHTTPRequestOperation *)requestHistoryMessageWithAccountId:(NSInteger)accountId firstMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Message 

//获得用户公告，提醒，促销数量
- (AFHTTPRequestOperation *)requestMessageWithAllWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Notice

//请求NoticeList
- (AFHTTPRequestOperation *)requestGetNoticeListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求RemindList
- (AFHTTPRequestOperation *)requestGetRemindListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Order

// 获取各种order的数量
- (AFHTTPRequestOperation *)requestGetOrderCountWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取各种order的数量 by json
- (AFHTTPRequestOperation *)requestGetOrderCountViaJsonWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加订单
- (AFHTTPRequestOperation *)requestAddOrder:(OrderDoc *)orderDoc oppId:(NSInteger)oppId cartIdStr:(NSString *)cartIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//刷新价格
- (AFHTTPRequestOperation *)requestProductInfoListCustomerID:(NSInteger)customerID ProductArray:(NSString *)product success:(void (^)(id))success failure:(void (^)(NSError *))failure;

//订单列表
- (AFHTTPRequestOperation *)requestGetOrderListByProductType:(NSInteger)type andStatus:(NSInteger)status andIsPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about CustomerID by json
- (AFHTTPRequestOperation *)requestGetOrderListViaJsonByProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 未确认订单
- (AFHTTPRequestOperation *)requestGetUnconfirmedOrderListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 确认订单
- (AFHTTPRequestOperation *)requestPostUnconfirmedOrderListWithOrderXml:(NSString *)cXml andPassword:(NSString *)password Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//订单列表 about Service
- (AFHTTPRequestOperation *)requestGetOrderListAboutServiceWithType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//订单列表 about Commodity
- (AFHTTPRequestOperation *)requestGetOrderListAboutCommodityWithType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about paymentID
- (AFHTTPRequestOperation *)requestGetOrderListByPaymentID:(NSInteger)paymentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get payment list by order id
- (AFHTTPRequestOperation *)requestGetPaymentDetailByOrderID:(NSInteger)orderID withSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;

//获取SchedulueTime
- (AFHTTPRequestOperation *)requestOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestViaJsonOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//确认订单 通过productId 反馈Order内容
- (AFHTTPRequestOperation *)requestOrderConfirmByProductId:(NSInteger )productId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取评论
- (AFHTTPRequestOperation *)requestOrderCommentByTreatmentId:(NSInteger)treatmentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加评论
- (AFHTTPRequestOperation *)requestAddOrderCommentByCommentDoc:(CommentDoc *)commentDoc andOrderID:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 更新评论
- (AFHTTPRequestOperation *)requestUpdateOrderCommentByCommentDoc:(CommentDoc *)commentDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Recharge

//获取用户消费充值一览
- (AFHTTPRequestOperation *)requestGetRchargeAndPayWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取用户充值detail
- (AFHTTPRequestOperation *)requestGetBalanceDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求levelinfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取二维码（弃用）
- (AFHTTPRequestOperation *)requestGetTwoDimensionalCodeWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取二维码 json
- (AFHTTPRequestOperation *)requestGetTwoDimensionalCodeWithCompanyCodeOrCustomerID:(NSInteger)code withType:(NSInteger)type withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark -- SalesPromotion

//请求促销信息数量
- (AFHTTPRequestOperation *)requestSalesPromotionNumberSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求促销信息
- (AFHTTPRequestOperation *)requestSalesPromotionWithWidth:(NSInteger)width andHeight:(NSInteger)height success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求促销信息 by json
- (AFHTTPRequestOperation *)requestSalesPromotionWithByJsonWidth:(NSInteger)width andHeight:(NSInteger)height success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取服务前后的图片URLs
- (AFHTTPRequestOperation *)requestGetEffectDisplayImages:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 取消订单
- (AFHTTPRequestOperation *)requestCancelOrderByOrderId:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark - Photos

// 相册--获取相册列表
- (AFHTTPRequestOperation *)requestGetPhotoAlbumListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 相册--获取相册详细图片
- (AFHTTPRequestOperation *)requestGetPhotoAlbumDetailWithCreateTime:(NSString *)createTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark - Commodity

// 获取categoryList by companyId
- (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取全部CommodityList
- (AFHTTPRequestOperation *)requestGetCommodityListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestGetCategoryListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure withType:(NSInteger)type;

//获取commodityList by parentId
- (AFHTTPRequestOperation *)requestGetCommodityListListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取Commodity Detail by commodityId
- (AFHTTPRequestOperation *)requestGetCommodityInfo:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 商品-- 获取Commodity Detail by commodityId and json
- (AFHTTPRequestOperation *)requestGetCommodityInfoByJson:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark - Service

// 获取categoryList by companyId
- (AFHTTPRequestOperation *)requestGetCategoryServiceListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取全部CommodityList
- (AFHTTPRequestOperation *)requestGetServiceListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestGetServiceListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取commodityList by parentId
- (AFHTTPRequestOperation *)requestGetServiceListListByParentId:(NSInteger)parentId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取Commodity Detail by commodityId
- (AFHTTPRequestOperation *)requestGetServiceInfo:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
- (AFHTTPRequestOperation *)requestGetServiceInfoByJson:(long long)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark - Pay

// 增加支付信息
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;



// 订单支付页面-- e-卡信息获得 by 吴旭
- (AFHTTPRequestOperation *)requestECardInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 订单支付页面-- e-卡支付 by 吴旭
- (AFHTTPRequestOperation *)requestPayAddByEcard:(NSInteger )orderNumber andPaymentDetailList:(NSString *)strPayList  andPassword:(NSString *)password andOrderList:(NSString *)orderList andTotalPrice:(CGFloat)totalPrice success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户支付list一览
- (AFHTTPRequestOperation *)requestGetPaymentListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户Ecard Discount一览
- (AFHTTPRequestOperation *)requestGetECardLevelDiscountListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户支付detail一览
- (AFHTTPRequestOperation *)requestGetPaymentDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark - Shopping Cart

// get Cart Count
- (AFHTTPRequestOperation *)requestGetShoppingCartCountByCustomerIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// select Cart List
- (AFHTTPRequestOperation *)requestGetShoppingCartListByCustomerIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// add Cart
- (AFHTTPRequestOperation *)requestAddCommodityToShoppingCartWithCommodity:(CommodityObject *)commodity success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// update Cart
- (AFHTTPRequestOperation *)requestUpdateCommodityInShoppingCartWithCommodity:(CommodityDoc *)commodity andProduntCount:(NSInteger)newCount success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// delete Cart
- (AFHTTPRequestOperation *)requestDeleteCommodityFromShoppingCartWithCommodity:(NSString *)commId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark - AppVersion

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestAppVersionWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;





@end
