//
//  PermissionDoc.h
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-2-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OrderDoc;
@interface PermissionDoc : NSObject

+ (id)sharePermission;
+ (void)saveUserRsa:(NSString *)userID andPassword:(NSString *)pwd;

@property (nonatomic, copy) NSString *userGUID;

@property (assign, nonatomic) NSInteger roleID;
/**
 *显示店内动态否则显示欢迎界面 No.2
 */
@property (assign, nonatomic) BOOL rule_FirstTop_Read;     //显示店内动态否则显示欢迎界面 No.2

@property (assign, nonatomic) BOOL rule_BillPrice_Write;    //开单时编辑价格(开单确认页) No.34

/**
 *管理订单(右侧;开单、结单 )No.6
 */
@property (assign, nonatomic) BOOL rule_MyOrder_Write;      //顾客服务页【开单】、右侧菜单【开单】、右侧菜单【结单】、预约列表页【新增预约】、预约详情页、订单详情页、结单页   No.6

/**
 *管理订单（所有订单)订单详情页、结单页、预约详情页 No.45
 */
@property (assign, nonatomic) BOOL rule_AllOrder_Write;


@property (assign, nonatomic) BOOL rule_MyCustomer_Read;	  // 显示和选择我的顾客(右侧[顾客]菜单) No.1
@property (assign, nonatomic) BOOL rule_AllCustomer_Read;  // 显示和选择所有顾客 No.3
@property (assign, nonatomic) BOOL rule_CustomerInfo_Read; // 查看顾客个人信息

/**
 *编辑顾客信息 专属顾问无视此权限 No.4
 */
@property (assign, nonatomic) BOOL rule_CustomerInfo_Write;// 编辑顾客个人信息 专属顾问无视此权限 No.4

/**
 *编辑联系信息 No.28 查看及修改顾客的联系信息（电话、地址、邮件）。注：顾客的专属顾问无视此权限。
 */
@property (assign, nonatomic) BOOL rule_Record_Read;	      // 查看顾客咨询记录

/**
 *编辑专业记录（所有顾客） 查看及修改顾客的专业记录。注：顾客的专属顾问无视此权限 No.29
 */
@property (assign, nonatomic) BOOL rule_Record_Write;	  // 编辑顾客咨询记录 No.29
/**
 *查看订单（我的订单、顾客订单 No.5
 */
@property (assign, nonatomic) BOOL rule_Order_Read;	      // 查看顾客订单
/**
 *管理订单（我的订单）No.6 原来
 */
//@property (assign, nonatomic) BOOL rule_Order_Write;	      // 编辑顾客订单

/**
 *查看订单（所有订单） No.39
 */
@property (assign, nonatomic) BOOL rule_BranchOrder_Read;	      // 查看本店所有的订单
/**
 *订单结帐 No.7 顾客服务页【结帐】、订单详情页【结帐】、右侧菜单【结帐】
 */
@property (assign, nonatomic) BOOL rule_Payment_Use;       // 使用结帐功能

/**
 *查看顾客e账户 No.8 顾客服务页 查看顾客的所有账户信息（储值卡、积分、券）。
 */
@property (assign, nonatomic) BOOL rule_ECard_Read;	      // 查看e卡信息

/**
 * 任务顾问筛选范围 No.44
 */
@property (assign, nonatomic) BOOL rule_TaskAll_Write;	// 修改e卡有效期
/**
 *创建顾客e账户 	对顾客账户进行开卡操作。 No.9
 */
@property (assign, nonatomic) BOOL rule_Recharge_Use;	  // e卡充值[废止]
/**
 *管理顾客e账户 对顾客账户进行直充、直扣等操作。 No.10
 */
@property (assign, nonatomic) BOOL rule_CustomerLevel_Write;//编辑顾客的会员等级
@property (assign, nonatomic) BOOL rule_Service_Read;	  // 查看和选择服务
// --@property (assign, nonatomic) BOOL Service_Write;	  // 设置服务及其分类信息
@property (assign, nonatomic) BOOL rule_Commodity_Read;	  // 查看和选择商品
// --@property (assign, nonatomic) BOOL Commodity_Write;	  // 设置商品及其分类信息
@property (assign, nonatomic) BOOL rule_Oppotunity_Use;	  // 使用商机功能
@property (assign, nonatomic) BOOL rule_Chat_Use;	      // 使用飞语功能
@property (assign, nonatomic) BOOL rule_MyReport_Read;	  // 查看我的报表
@property (assign, nonatomic) BOOL rule_BusinessReport_Read;	//查看商家报表 
@property (assign, nonatomic) BOOL rule_Marketing_Read;	  // 查看市场营销信息
@property (assign, nonatomic) BOOL rule_Marketing_Write;	  // 发送市场营销信息
// --@property (assign, nonatomic) BOOL Notice_Write;	  // 编辑公告
// --@property (assign, nonatomic) BOOL Promotion_Write;	  // 编辑促销信息
// --@property (assign, nonatomic) BOOL BusinessInfo_Write;// 编辑商家信息
@property (assign, nonatomic) BOOL rule_MyInfo_Write;	  // 编辑帐户信息(不含角色) ？？？
// --@property (assign, nonatomic) BOOL AccountRole_Write; // 编辑所有帐户角色
// --@property (assign, nonatomic) BOOL Hierarchy_Write;	  // 编辑下属帐户层级
// --@property (assign, nonatomic) BOOL Relationship_Write;// 编辑帐户顾客关系
// --@property (assign, nonatomic) BOOL RolePermission_Write;	// 设置角色权限
// --@property (assign, nonatomic) BOOL LevelPolicy_Write;	// 设置会员等级政策
// --@property (assign, nonatomic) BOOL Question_Write;	    // 设置专业信息
// --@property (assign, nonatomic) BOOL Step_Write;	        // 设置销售步骤
@property (assign, nonatomic) BOOL rule_IsAccountPayEcard;  //是否可以用e卡支付
@property (assign, nonatomic) BOOL rule_OrderTotalSalePrice_Write;  //是否可以修改优惠价  1可修改0不可修改
@property (assign, nonatomic) BOOL rule_Money_Out;          //是否可以转出e卡金额
@property (nonatomic, assign) BOOL rule_Part_Pay;           //是否支持分次支付
@property (nonatomic, assign) BOOL rule_attendance_code;           //是否考勤码
@property (nonatomic, assign) BOOL rule_PastPayment;        //是否可以填写过去支付金额
@property (nonatomic, assign) BOOL rule_PastFinished;       //是否可以填写过去完成次数
@property (nonatomic, assign) BOOL rule_BalanceCharge;      //是否可以余额转入
@property (nonatomic, assign) BOOL rule_DirectExpend;       //是否可以直扣
@property (nonatomic, assign) BOOL rule_TerminateOrder;     //是否可以终止订单
@property (nonatomic, assign) BOOL rule_PayAmountWrite;     //是否可以修改应付款

@property (nonatomic, strong) NSString *record_marketing_oppotun;
-(void)setPermission:(NSString *)sourceString;
-(void)resetPermission:(NSString *)record_marketing_oppotun;
@end
