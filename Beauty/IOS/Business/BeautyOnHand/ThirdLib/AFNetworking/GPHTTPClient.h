 //
//  MLHTTPClient.h
//  GlamourPromise
//
//  Created by GuanHui on 13-6-24.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@class CustomerDoc;
@class RecordDoc;
@class MessageDoc;
@class TemplateDoc;
@class MerchantDoc;
@class ProgressDoc;
@class OrderDoc;
@class ScheduleDoc;
@class AccountDoc;
@class PayDoc;
@class LevelDoc;
@class TreatmentDoc;
@class ContactDoc;
@class ProductAndPriceDoc;
@class OpportunityDoc;
@class LoginDoc;
@class AFHTTPRequestOperation;
@class DFFilterSet;
@interface GPHTTPClient : AFHTTPClient

+ (id)shareClient;

// 检测版本
- (AFHTTPRequestOperation *)requestGetVersionWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 登陆获取CompanyList Operation
- (AFHTTPRequestOperation *)requestAccountLoginWithMobile:(NSString *)mobile passwd:(NSString *)pwd success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取权限等信息
- (AFHTTPRequestOperation *)requestLoginInfoForAccount:(LoginDoc*)loginDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark -
#pragma mark - upload image

//// 单张图片删除
//- (AFHTTPRequestOperation *)requestDeleteImage:(NSString *)imgURLs success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 多张图片修改 (for服务效果)    type == 0  服务前  type == 1  服务后
- (AFHTTPRequestOperation *)requestUploadImageAndDeleteImageWithTreatmentId:(NSInteger)treatmentId customerId:(NSInteger)customerId uploadImageXML:(NSString *)uploadImageXML deleteImageXML:(NSString *)deleteImage success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//// 多张图片删除（for服务效果）
//- (AFHTTPRequestOperation *)requestDeleteMoreEffectImageWithImageXML:(NSString *)imageXML success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Account

// 请求Account列表 (仅仅在SelectCustomersViewController使用)
// 请求Account列表 by BranchID   --> type = 0  companyID = "" BranchId = ?
// 请求Account列表 by CompanyID  --> type = 1  companyID = ?  BranchId = ""
- (AFHTTPRequestOperation *)requestGetAccountListByType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


- (AFHTTPRequestOperation *)requestGetAccountListViaJsonWithDate:(NSString *)date success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Account

//请求customerList
- (AFHTTPRequestOperation *)requestAccountListWithBranchID:(NSInteger)branchId andFlag:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求AccountDetail
-(AFHTTPRequestOperation *) requestAccountDetailWithAccountId:(NSInteger)accountId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Company

//请求business Detail
-(AFHTTPRequestOperation *) requestBusinessDetailWithAccountId:(NSInteger)branchId success:(void (^)(id xml)) success failure:(void (^)(NSError *error))failure;
- (AFHTTPRequestOperation *)requestGetFavouriteListByProductType:(NSInteger)type andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestAddFavouriteByProductType:(NSInteger)type andProductCode:(long long)productCode success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestDelFavouriteByFavouriteID:(NSInteger )favouriteID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//获得分支机构列表
- (AFHTTPRequestOperation *)requestBeautySalonListSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获得分支机构详情
- (AFHTTPRequestOperation *)requestBeautySalonDetailWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//获取分支机构图片
- (AFHTTPRequestOperation *)requestComanyBranchPicWithBranchID:(NSInteger)branchId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//- (AFHTTPRequestOperation *)requestUpdateFavouriteByProductType:(NSInteger )type withIDs:(NSString *)IDs success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark -
#pragma mark - Customer
#pragma mark -- Customer Basic Info

//// 请求customer列表 by AccountID
//- (AFHTTPRequestOperation *)requestGetCustomerListByAccountIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//
//// 请求customer列表 by CompanyID
//- (AFHTTPRequestOperation *)requestGetCustomerListByCompanyIdWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;



// 请求customer列表
// --objectType = 0 objectId = accountID | objectType = 1 objectID = companyID
//- (AFHTTPRequestOperation *)requestGetCustomerListWithObjectType:(NSInteger)objectType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestGetCustomerListWithAccountID:(NSInteger)accountID ObjectType:(NSInteger)objectType LevelID:(NSInteger)levelID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


// 请求customer信息 by CustomerID
- (AFHTTPRequestOperation *)requestGetCustomerInfoByCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求customer信息 by CustomerID json格式
- (AFHTTPRequestOperation *)requestGetScanResultByJsonAndQRCode:(NSString*)QRCodeString success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求customer基本信息
- (AFHTTPRequestOperation *)requestGetCustomerBasicInfo:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 删除customer基本信息
- (AFHTTPRequestOperation *)requestDeleteCustomerBasicInfo:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// check customer是否重复
- (AFHTTPRequestOperation *)requestAddCustomerBasicInfoWithJson:(CustomerDoc *)customerDoc flag:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// add customer anyway
- (AFHTTPRequestOperation *)requestsubmitCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加custoner基本信息
- (AFHTTPRequestOperation *)requestAddCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改customer基本信息
- (AFHTTPRequestOperation *)requestUpdateCustomerBasicInfo:(CustomerDoc *)customerDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -- Customer Detail Info

// 请求customer详细信息
- (AFHTTPRequestOperation *)requestGetCustomerDetailInfoWithCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
// 顾客美丽顾问设置
- (AFHTTPRequestOperation *)requestAddResponsiblePersonIDWithCustomerId:(NSInteger)customerId ResponsiblePersonID:(NSInteger)responsiblePersonID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改cusomter详细信息
- (AFHTTPRequestOperation *)requestUpdateCustomerDetailInfoWithCustomer:(CustomerDoc *)customer success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -- Profession Info

// 请求专业信息
- (AFHTTPRequestOperation *)requestGetProfessionInfoWithCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改专业信息
- (AFHTTPRequestOperation *)requestUpdateProfessionInfoWithCustomer:(CustomerDoc *)customer success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -
#pragma mark - Record Info

// --Record Info by CustomerId
- (AFHTTPRequestOperation *)requestGetRecordInfoByCustomerId:(NSInteger)customerId tagIDs:(NSString *)tagIDs success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Record Info by AccountId
- (AFHTTPRequestOperation *)requestGetRecordInfoByAccountIdWithFilterDoc:(DFFilterSet *)filterDoc recordID:(NSInteger)recordID pageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestGetRecordInfoByAccountIdRecordID:(NSInteger)recordID PageIndex:(int)index PageSize:(int)size ResponsiblePersonID:(NSInteger)personID CustomerID:(NSInteger)customerID TagIDs:(NSString *)tagIDs TimeValid:(int)timeValid StartTime:(NSString *)start EndTime:(NSString *)end success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 删除record Info
- (AFHTTPRequestOperation *)requestDeleteRecordInfoWithRecordId:(NSInteger)recordId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加 record Info
- (AFHTTPRequestOperation *)requestAddRecordInfoWithRecordInfo:(RecordDoc *)recordDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改 record Info
- (AFHTTPRequestOperation *)requestUpdateRecordInfoWithRecordInfo:(RecordDoc *)recordDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Message

// 请求Customer List和最后的聊天记录、时间
// by AccountId    --> Flag = 0  accountId = ?  BrandID = ""  CompandyId = ""
// by BrandId      --> Flag = 1  accountId = ?  BrandID = ?   CompandyId = ""
// by CompandyId   --> Flag = 2  accountId = ?  BrandID = ""  CompandyId = ?
- (AFHTTPRequestOperation *)requestGetCustomerSelectListWithType:(NSInteger)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求Message List byOneToOne
- (AFHTTPRequestOperation *)requestGetMessagesListByOneToOneWithCustomer:(NSInteger)customerId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求Message List byOneToMore
- (AFHTTPRequestOperation *)requestGetMessagesListByOneToMoreSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 发送消息 byOneToOne
- (AFHTTPRequestOperation *)requestSendMessageByOneToOneWithMessage:(MessageDoc *)messageDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 发送消息 byOneToMore
- (AFHTTPRequestOperation *)requestSendMessageByOneToMoreWithMessage:(MessageDoc *)messageDoc toUserIdsStr:(NSString *)toUserIdsStr Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获得历史记录
- (AFHTTPRequestOperation *)requestHistoryMessagesWithCustomerId:(NSInteger)customerId firstMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获得最新消息 byOneToOne
- (AFHTTPRequestOperation *)requestGetNewMessagesWithCustomerId:(NSInteger)customerId lastMessageId:(NSInteger)messageId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获得最新消息总数量
- (AFHTTPRequestOperation *)requestTheTotalCountOfNewMessageWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Marketing

// 获取群消息的历史记录 (每次返回5条信息)
- (AFHTTPRequestOperation *)requestGetGroupMsgWithLastID:(NSInteger)lastID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 更新已经请求的群发消息
- (AFHTTPRequestOperation *)requestRefreshGroupMsgWithTheOldestTime:(NSInteger)recentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Template

// 获得模板list
- (AFHTTPRequestOperation *)requestTemplateListWithType:(NSInteger)type Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加模板
- (AFHTTPRequestOperation *)requestAddTemplateWithTemplate:(TemplateDoc *)templateDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改模板
- (AFHTTPRequestOperation *)requestUpdateTemplateWithTemplate:(TemplateDoc *)templateDoc Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 删除模板
- (AFHTTPRequestOperation *)requestDeleteTemplateWithTemplateID:(NSInteger)templateId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Opportunity && Progress

#pragma mark -- Opportunity

// --add Opportunity
- (AFHTTPRequestOperation *)requestAddOpportunity:(OpportunityDoc *)opp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
// --add Opportunity json
- (AFHTTPRequestOperation *)requestAddOpportunityByJson:(OpportunityDoc *)opp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
// --get Opportunity List
- (AFHTTPRequestOperation *)requestGetOpportunityListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Opportunity List json
- (AFHTTPRequestOperation *)requestGetJsonOpportunityListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Opportunity Detail
- (AFHTTPRequestOperation *)requestGetOpportunityDetailByOppId:(NSInteger)oppId productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Opportunity Detail json
- (AFHTTPRequestOperation *)requestGetJsonOpportunityDetailByOppId:(NSInteger)oppId productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --delete Opportunity
- (AFHTTPRequestOperation *)requestDeleteOpportunityWithOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --delete Opportunity json
- (AFHTTPRequestOperation *)requestJsonDeleteOpportunityWithOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark -- Progress

// --get Progress List
- (AFHTTPRequestOperation *)requestGetProgressHistoryListByOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Progress List json
- (AFHTTPRequestOperation *)requestGetJsonProgressHistoryListByOppId:(NSInteger)oppId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --add Progress
- (AFHTTPRequestOperation *)requestAddProgress:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --add Progress json
- (AFHTTPRequestOperation *)requestAddProgressByJson:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --update Progress
- (AFHTTPRequestOperation *)requestUpdateProgress:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --update Progress json
- (AFHTTPRequestOperation *)requestUpdateProgressByJson:(OpportunityDoc *)opportunityDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Progress Detail
- (AFHTTPRequestOperation *)requestGetProgressDetail:(NSInteger)progressID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get Progress Detail json
- (AFHTTPRequestOperation *)requestGetProgressDetailByJson:(NSInteger)progressID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Order

#pragma mark -- Order

// --get Order Count
- (AFHTTPRequestOperation *)requestGetOrderCountWithCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about AccountID_1_7_4
- (AFHTTPRequestOperation *)requestGetOrderListByAccountIDAndProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid orderId:(NSInteger)orderId viewType:(NSInteger)viewType filterByTime:(NSInteger)filterBytime startTime:(NSString*)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about AccountID_1_7_4 by json

- (AFHTTPRequestOperation *)requestGetOrderListByAccountIDAndProductType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid orderId:(NSInteger)orderId responsePersonID:(NSInteger)responsePersonId customerID:(NSInteger)customerId viewType:(NSInteger)viewType filterByTime:(NSInteger)filterBytime pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize isShowAll:(NSInteger)isShowAll startTime:(NSString*)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get unpaid list
- (AFHTTPRequestOperation *)requestGetUnpaidListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about paymentID
- (AFHTTPRequestOperation *)requestGetOrderListByPaymentID:(NSInteger)paymentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --get payment list by order id
- (AFHTTPRequestOperation *)requestGetPaymentDetailByOrderID:(NSInteger)orderID withSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure;

// --订单列表 about CustomerID
- (AFHTTPRequestOperation *)requestGetOrderListByCustomerID:(NSInteger)customerID productType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单列表 about CustomerID
- (AFHTTPRequestOperation *)requestGetOrderListViaJsonByCustomerID:(NSInteger)customerID productType:(NSInteger)productType status:(NSInteger)status isPaid:(NSInteger)isPaid acccountId:(NSInteger)accountID startTime:(NSString *)startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
// --订单详细
- (AFHTTPRequestOperation *)requestGetOrderDetailWithOrderID:(NSInteger)orderID productType:(NSInteger)productType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --订单详细 json
- (AFHTTPRequestOperation *)requestViaJsonOrderDetailByOrderId:(NSInteger)orderId andProductType:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --添加订单
- (AFHTTPRequestOperation *)requestAddOrder:(OpportunityDoc *)opp oppIdStr:(NSString *)oppIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --添加订单 1_7_6
- (AFHTTPRequestOperation *)requestAddOrderNew:(OpportunityDoc *)opp oppIdStr:(NSString *)oppIdStr success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --修改订单
- (AFHTTPRequestOperation *)requestUpdateOrder:(OrderDoc *)orderDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --删除订单
- (AFHTTPRequestOperation *)requestDeleteOrder:(NSInteger)orderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 备注更新
- (AFHTTPRequestOperation *)updateOrderRemark:(NSInteger)orderId Remark:(NSString *) remark  CustomerID:(NSInteger) customerId UpdaterID:(NSInteger) updateId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//order 修改过期时间
- (AFHTTPRequestOperation *)updateOrderExpirationTime:(NSInteger)orderId ExpirationTime:(NSString *) expirationTime  CustomerID:(NSInteger) customerId UpdaterID:(NSInteger) updateId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//order 添加指定
- (AFHTTPRequestOperation *)updateTreatmentDesignated:(NSInteger)treatmentID OrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID IsDesignated:(BOOL) isDesignated success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//order 添加统计
- (AFHTTPRequestOperation *)updateOrderAddOrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID IsAddUp:(BOOL) isAddUp success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//order 修改价格
- (AFHTTPRequestOperation *)updateOrderTotalSalePriceOrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID TotalSalePrice:(double) salePrice success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 添加treatment
- (AFHTTPRequestOperation *)requestAddNewTreatmentWithOrderID:(NSInteger)orderId andCourseID:(NSInteger)courseId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 删除treatment
- (AFHTTPRequestOperation *)requestdeleteTreatmentWithTreatmentID:(NSInteger)treatmentId andScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 完成treatment
- (AFHTTPRequestOperation *)requestCompleteTreatmentWithScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId addOrderID:(NSInteger)orderID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 完成treatment by course id
- (AFHTTPRequestOperation *)requestCompleteTreatmentByCourseID:(NSInteger)courseId andCustomerID:(NSInteger)customerId  andOrderID:(NSInteger)orderID  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 取消treatment
- (AFHTTPRequestOperation *)requestCancelTreatmentWithTreatmentID:(NSInteger)treatmentId OrderID:(NSInteger)orderID andScheduleID:(NSInteger)scheduleId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 完成treatment
- (AFHTTPRequestOperation *)requestUpdateTreatmentWithTreatment:(TreatmentDoc *)treatment OrderID:(NSInteger)orderID andScheduleTime:(NSString *)time andExecutorID:(NSInteger)executorId andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 完成treatment
- (AFHTTPRequestOperation *)requestUpdateResponsiblePersonWithOrderID:(NSInteger)orderId andResponsiblePersonID:(NSInteger)responsiblePersonId andCustomerID:(NSInteger)customerId andSalesID:(NSInteger)salesId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 更新treatmentremark
- (AFHTTPRequestOperation *)requestUpdateTreatmentRemarkWithTreatment:(TreatmentDoc *)treatment andCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// order 更新treatmentremark
- (AFHTTPRequestOperation *)requestCompleteOrderWithOrderID:(NSInteger)orderId CustomerID:(NSInteger)customerId andOrderType:(NSInteger)orderType andFlag:(BOOL)finishFlag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//order group
- (AFHTTPRequestOperation *)requestAddNewTreatmentGroupWithOrderID:(NSInteger)orderId CourseID:(NSInteger)courseId CustomerID:(NSInteger)customerId CreatorID:(NSInteger)creatorID IsDesign:(int)isDesign andSubServiceIDs:(NSString *)subService success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestdeleteTreatmentWithCustomerID:(NSInteger)customerID OrderID:(NSInteger)orderID UpdaterID:(NSInteger)updaterID AndGroup:(NSString *)group success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestCompleteTreatmentByCustomerID:(NSInteger)customerID OrderID:(NSInteger)orderID Group:(NSString *)group  andUpdaterID:(NSInteger)updaterID  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- Treatment && Contact

// --update Treatment
- (AFHTTPRequestOperation *)requestUpdateTreatmentDetailInfoWith:(TreatmentDoc *)treatmentDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --update Contact
- (AFHTTPRequestOperation *)requestUpdateContactDetailInfoWith:(ContactDoc *)contactDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark --EffectImage

// 获取服务前后的图片URLs
- (AFHTTPRequestOperation *)requestGetEffectDisplayImages:(NSInteger)treatId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark --Pay

// 订单支付页面-- e卡信息获得 by 吴旭
- (AFHTTPRequestOperation *)requestECardInfoByCustomerId:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 订单支付页面-- e卡信息获得 by Json
- (AFHTTPRequestOperation *)requestPaymentInfoViaJsonByOrderID:(NSString *)orderIdList success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 订单支付页面-- e卡支付 by 吴旭
- (AFHTTPRequestOperation *)requestPayAddByEcard:(NSInteger )orderNumber andUserId:(NSInteger)userId andStrPayAmount:(NSString *)strPayAmount andStrOrderId:(NSString *)strOrderId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户支付list一览
- (AFHTTPRequestOperation *)requestGetPaymentListByCustomerID:(NSInteger)customerId Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户支付detail一览
- (AFHTTPRequestOperation *)requestGetPaymentDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
//// 充值页面 by 吴旭
//- (AFHTTPRequestOperation *)requestRechargeToEcardWithUserId:(NSInteger)userId andRechargeWay:(NSInteger)rechargeWay andRechargeAmount:(CGFloat)rechargeAmount success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//ecard 修改过期时间
- (AFHTTPRequestOperation *)updateEcardExpirationTime:(NSInteger)customerId ExpirationTime:(NSString *) expirationTime  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 充值页面 by Hadley
- (AFHTTPRequestOperation *)requestRechargeToEcardWithCustomerID:(NSInteger)customerID
                                                   responsibleID:(NSInteger)responsibleID
                                                     rechargeWay:(NSInteger)rechargeWay
                                                  rechargeAmount:(CGFloat)rechargeAmount
                                                  presentedAmount:(CGFloat)presentedAmount
                                                          remark:(NSString *)remark
                                                    peopleCount:(NSInteger)count
                                                         SlaveID:(NSString *)slaveIDs
                                                         success:(void (^)(id xml))success
                                                         failure:(void (^)(NSError *error))failure;
// 等级修改页面 by 吴旭
- (AFHTTPRequestOperation *)requestLevelChangeToEcardWithLevelId:(NSInteger)levelId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -
#pragma mark - Product And Service

#pragma mark -- Category

// --Get Category List(type = 0 服务 | type = 1 商品)

- (AFHTTPRequestOperation *)requestGetCategoryListByCompanyIdAndBranchIdWithType:(NSInteger)type Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestGetCategoryListByCategoryId:(NSInteger)categoryID type:(NSInteger)type success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -- Product

// --Get Product List

- (AFHTTPRequestOperation *)requestGetCommodityListByCompanyIdAndBranchIdWithCustomerID:(NSInteger)customerID Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
- (AFHTTPRequestOperation *)requestGetCommodityListByCategoryID:(NSInteger)categoryID andCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Get Product Detail

- (AFHTTPRequestOperation *)requestGetCommodityDetail:(long long )commodityID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -- Service

// --Get Service List

- (AFHTTPRequestOperation *)requestGetServiceListByCompanyIdAndBranchIdWithCustomerID:(NSInteger)customerID Success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
- (AFHTTPRequestOperation *)requestGetServiceListByCategoryID:(NSInteger)categoryID andCustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Get Service Detail

- (AFHTTPRequestOperation *)requestGetServiceDetail:(NSInteger)serviceID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
// --Get Service Detail after Version 2.1
- (AFHTTPRequestOperation *)requestGetServiceDetailByJson:(long long)serviceID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;
#pragma mark -
#pragma mark - Setting

#pragma mark -- about Company

// 获取Company信息 (美容院信息)
- (AFHTTPRequestOperation *)requestGetBeautyShopInfoWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取Company图片
- (AFHTTPRequestOperation *)requestGetBeautyShopImages:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改Company信息 (美容院信息)
- (AFHTTPRequestOperation *)requestUpdateBeautyShopInfoWithMerchantDoc:(MerchantDoc *)merchantDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- about Accout

// 获取AccountList
- (AFHTTPRequestOperation *)requestGetAccountInfoListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取Account  by accountId
- (AFHTTPRequestOperation *)requestGetAccountInfoByAccountIWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加Account信息 (美容师信息)
- (AFHTTPRequestOperation *)requestAddAccountInfo:(AccountDoc *)accountDoc success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 修改Account头像 (美容师信息)
- (AFHTTPRequestOperation *)requestUpdateAccountWithHeadImage:(UIImage *)headImage imageType:(NSString *)imageType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//改变account_available
- (AFHTTPRequestOperation *)requestChangeStatus:(NSInteger)available  theAccountId:(NSInteger)accountId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//用户修改密码
- (AFHTTPRequestOperation *)requestChangeAccountPasswordWithNewPassword:(NSString*)nPassword OldPassword:(NSString*)oPassword success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -- about Customer


#pragma mark -- about Part

#pragma mark -- about Item

#pragma mark -- about Product

//获取储值卡余额
- (AFHTTPRequestOperation *)requestGetgetBalanceWithSuccess:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取levelInfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithCustomerID:(NSInteger)customerId success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 增加支付信息
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc paymentXML:(NSString *)payXML orderXML:(NSString *)orderXML isCompletedFlag:(NSInteger)isComFlag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加支付信息 By Json
- (AFHTTPRequestOperation *)requestAddpay:(PayDoc *)payDoc paymentJson:(NSString *)payJson orderJson:(NSString *)orderJson isCompletedFlag:(NSInteger)isComFlag andCreateTime:(NSString*)createTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Remind

//获得用户提醒
- (AFHTTPRequestOperation *)requestMessageWithRemindWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求NoticeList
- (AFHTTPRequestOperation *)requestGetNoticeListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 请求RemindList
- (AFHTTPRequestOperation *)requestGetRemindListWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

//请求levelinfo
- (AFHTTPRequestOperation *)requestGetgetBalanceAndLevelWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取二维码
- (AFHTTPRequestOperation *)requestGetTwoDimensionalCodeWithCompanyCodeOrCustomerID:(NSInteger)code withType:(NSInteger)type withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 添加充值信息
- (AFHTTPRequestOperation *)requestRechargeBalance:(NSString *)rechargeAmount success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取顾客消费充值记录
- (AFHTTPRequestOperation *)requestGetRchargeAndPayWithSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 获取用户充值detail
- (AFHTTPRequestOperation *)requestGetBalanceDetailByID:(NSInteger)Id withSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 顾客等级分类列表
- (AFHTTPRequestOperation *)requestLevelInfoSuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 顾客等级分类列表2_2_2
- (AFHTTPRequestOperation *)requestLevelListByFlag:(int)flag success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// 更改顾客会员等级
- (AFHTTPRequestOperation *)requestChangeCustomerLevel:(NSInteger)levelId  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


// 修改顾客等级分类列表
- (AFHTTPRequestOperation *)requestLevelDetailInfoWithArray:(NSMutableArray *)endSendArray success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -
#pragma mark - Report

// --Report Basic
//  -cycleType:  0=日、   1=月、  2=季、 3=年 、4=自定义
//  -objectType: 0=个人、 1=单店、 2=公司
- (AFHTTPRequestOperation *)requestGetReportBasicWithBranchID:(NSInteger)branchID accountID:(NSInteger)accountID cycleType:(NSInteger)cycleType objectType:(NSInteger)objectType startTime:(NSString*) startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Report Total
// -companyID
- (AFHTTPRequestOperation *)requestGetCompanyTotalReportWithCompanyID:(NSInteger)companyID BranchID:(NSInteger)branchID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Report List
//  -cycleType: 0=日、 1=月、 2=季、 3=年
//  -objectType: 0=个人 1=分店
- (AFHTTPRequestOperation *)requestGetReportListWithCycleType:(NSInteger)cycleType objectType:(NSInteger)objectType startTime:(NSString*) startTime endTime:(NSString *)endTime success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Total List
// -- companyID
- (AFHTTPRequestOperation *)requestgetBranchTotalList:(NSInteger)companyID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

// --Report Detail
//  -flag:        0=个人 1=分店 2=公司
//  -productType: 0=服务 1=商品
//  -cycleType:   0=日、 1=月、 2=季、 3=年
//  -orderType:   0=customer 1=商品或者服务
- (AFHTTPRequestOperation *)requestGetReportDetailWithBranchID:(NSInteger)branchID accountID:(NSInteger)accountID objectType:(NSInteger)objectType productType:(NSInteger)productType cycleType:(NSInteger)cycleType orderType:(NSInteger)orderType itemType:(NSInteger)itemType startTime:(NSString*) startTime endTime:(NSString *)endTime  success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

#pragma mark -
#pragma mark - Review

// 获取评价
- (AFHTTPRequestOperation *)requestGetReviewInfoByTreatmentId:(NSInteger)treatmentID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;




#pragma mark
#pragma mark -Notepad
- (AFHTTPRequestOperation *)requestNoteListCustomerID:(NSInteger)customerId ID:(NSInteger)ID TagsID:(NSString*)tagsID andViewType:(NSInteger)viewType success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestNoteListAccountID:(DFFilterSet *)filter NoteID:(NSInteger)noteID PageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestAddNoteCustomerID:(NSInteger)customerId CreatorID:(NSInteger)creatorID TagIDS:(NSString *)tagIDS andContent:(NSString *)content success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestUpdateNoteCustomerID:(NSInteger)customerId CreatorID:(NSInteger)creatorID TagIDS:(NSString *)tagIDS andContent:(NSString *)content success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestDeleteNoteNotepadID:(NSInteger)notepadID UpdaterID:(NSInteger)updaterID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -Tag
- (AFHTTPRequestOperation *)requestGetTagListsuccess:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestAddTagCreatorID:(NSInteger)creatorID TagName:(NSString *)tagName success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


#pragma mark -EcardLevel
- (AFHTTPRequestOperation *)requestEcardInfoByLevelID:(NSInteger)levelID CustomerID:(NSInteger)customerID success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;

- (AFHTTPRequestOperation *)requestProductInfoListCustomerID:(NSInteger)customerID ProductArray:(NSString *)product success:(void (^)(id xml))success failure:(void (^)(NSError *error))failure;


@end
