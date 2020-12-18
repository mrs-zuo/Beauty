//
//  CustomerListViewController.h
//  Customers
//
//  Created by MAC_Lion on 13-5-20.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCustomersCell.h"
#import "UserDoc.h"
typedef NS_ENUM(NSInteger,ACCOUNTRANGE){
    ACCBRANCH = 0,
    ACCACCOUNT = 2
};

typedef NS_ENUM(NSInteger,CUSTOMERRANGE){
    CUSTOMERALL = 1, //公司
    CUSTOMERINBRANCH = 2, //分店  我及我的下级账户
    CUSTOMEROFMINE = 0 //与我相关 当前门店所有的
};

typedef NS_ENUM(NSInteger, CustomPersonType) {
    CustomePersonDefault = 0,
    CustomePersonGroup = 1
};
@protocol SelectCustomersViewControllerDelegate;

@interface SelectCustomersViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate, SelectCustomersCellDelegate>
@property (assign, nonatomic) id<SelectCustomersViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *myListView;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (assign, nonatomic) int pushOrpop; // push 1  pop 0
@property (assign, nonatomic) int prevView; // 上一个页面 9:orderDetailViewController 8:增加美丽顾问（顾客基本信息页） 10:增加销售顾问
@property (assign, nonatomic) NSInteger orderId; //orderDetailViewController页面用
@property (strong, nonatomic) NSString *navigationTitle;
@property (assign, nonatomic) NSInteger customerId; 
@property (assign, nonatomic) NSInteger salesId;
@property (nonatomic)         ACCOUNTRANGE accRange;
@property (nonatomic, assign) CustomPersonType personType;
@property (nonatomic ,strong) NSDictionary * groupDic;
@property (nonatomic ,assign) NSString * serveType;
@property (nonatomic ,assign) NSInteger productType;
@property (nonatomic ,assign) NSInteger orderObjectID;

@property (nonatomic ,assign) NSInteger viewFor; //1.来自笔记 2.专业

// selectModel=0 单选   selectModel = 1 多选 
// userType=0  customer(必须选择)    userType=1 account(可选择无美丽顾问)  userType = 2 sales userType = 3 必须选择美丽顾问  userType = 4 选择顾客 可以不选
// type: 顾客类型：1 所有，2 本店，0 我的
- (void)setSelectModel:(int)selectModel userType:(int)userType customerRange:(CUSTOMERRANGE)_range defaultSelectedUsers:(NSArray *)selectedArray;

@end

@protocol SelectCustomersViewControllerDelegate <NSObject>
@optional
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray;
- (void)dismissViewControllerWithSelectedSales:(NSArray *)userArray;
- (void)dismissViewControllerWithServe:(NSInteger )userId groupDic:(NSDictionary *)groupDic;
@end

