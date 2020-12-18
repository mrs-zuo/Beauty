
//
//  ReportCustomerDetailViewController.h
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15-3-25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportDetailViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString *reportTitle;
@property (assign, nonatomic) double totalMoney;
@property (assign, nonatomic) NSInteger totalCases;

@property (strong, nonatomic) UITextField *beginTime;
@property (strong, nonatomic) UITextField *endTime;
@property (strong, nonatomic) UILabel *timeGap;
@property (strong, nonatomic) UIImageView *queryPad;

@property (assign, nonatomic) NSInteger branchID;
@property (assign, nonatomic) NSInteger accountID;

// objectType = 0 个人  | objectType = 1 分店 | objectType = 2 公司
@property (assign, nonatomic) NSInteger objectType;

// productType = 0 服务  |  productType = 1 商品
@property (assign, nonatomic) NSInteger productType;

// cycleType = 0 日  | cycleType = 1 月 | cycleType = 2 季 | cycleType = 3 年
@property (assign, nonatomic) NSInteger cycleType;


// orderType = 0 顾客为主  | orderType = 1 商品或服务为主
@property (assign, nonatomic) NSInteger orderType;


// itemType = 0 销售额  | itemType = 1 件数  |  itemType = 2 服务次数(员工专用)
@property (assign, nonatomic) NSInteger itemType;


/// 商品服务下的子类型 大服务 小服务
@property (assign, nonatomic) NSInteger statementCategoryID  ;

@end