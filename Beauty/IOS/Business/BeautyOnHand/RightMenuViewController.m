//
//  MenuViewController.m
//  BeautyPromise02
//
//  Created by ZhongHe on 13-5-22.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RightMenuViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "LoginViewController.h"
#import "DEFINE.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "GPNavigationController.h"
#import "UIImageView+WebCache.h"
#import "SVProgressHUD.h"
#import "GPNavigationController.h"
#import "AppDelegate.h"
#import "CustomerListViewController.h"
#import "CommodityOrServiceDoc.h"
#import "ServiceListViewController.h"
#import "ProductListViewController.h"
#import "CustomerListViewController.h"
#import "FavouritesListViewController.h"
#import "PermissionDoc.h"
#import "NoteListController.h"
#import "QuestionnaireListController.h"
#import "AppointmentList_ViewController.h"

#import "CusMainViewController.h"
#import "CompletionOrderController.h"   

@interface RightMenuViewController ()
@property (assign, nonatomic) NSInteger count_NewMesg;

@property (strong, nonatomic) CustomerDoc *customer_Selected;
@property (strong, nonatomic) NSMutableArray *commodityArray_Selected;
@property (strong, nonatomic) NSMutableArray *serviceArray_Selected;
@property (strong, nonatomic) NSMutableArray *commodityOrServiceArray_Selected;
@end

@implementation RightMenuViewController
@synthesize menuItems;
@synthesize myListView;
@synthesize count_NewMesg;

@synthesize customer_Selected;
@synthesize commodityArray_Selected;
@synthesize serviceArray_Selected,commodityOrServiceArray_Selected;

- (void)initData
{
    [menuItems removeAllObjects];
    
    MenuDoc *menuItem0 = [[MenuDoc alloc] initWithMenuName:@"首页" Image:[UIImage imageNamed:@"Menu1_FirstNew"] View:@"FirstNavigation"];
    MenuDoc *menuItem1 = [[MenuDoc alloc] initWithMenuName:@"顾客" Image:[UIImage imageNamed:@"Menu1_Customer"] View:@"CustomerNavigation"];
    
    MenuDoc *menuItem2 = [[MenuDoc alloc] initWithMenuName:@"服务" Image:[UIImage imageNamed:@"Menu1_Service"] View:@"ServiceNavigation"];
    MenuDoc *menuItem3 = [[MenuDoc alloc] initWithMenuName:@"商品" Image:[UIImage imageNamed:@"Menu1_Commodity"] View:@"ProductNavigation"];
    MenuDoc *menuItem4 = [[MenuDoc alloc] initWithMenuName:@"开单" Image:[UIImage imageNamed:@"Menu1_OrderConfirm"] View:@"OrderConfireNavigation"];
    MenuDoc *menuItem5 = [[MenuDoc alloc] initWithMenuName:@"结单" Image:[UIImage imageNamed:@"Menu1_CompletionNew"] View:@""];

    MenuDoc *menuItem6 = [[MenuDoc alloc] initWithMenuName:@"结账" Image:[UIImage imageNamed:@"Menu0_CheckOut"] View:@"PaymentNavigation"];

    MenuDoc *menuItem7 = [[MenuDoc alloc] initWithMenuName:@"扫一扫"  Image:[UIImage imageNamed:@"Menu1_ScanQRCode"] View:@"ScanQRCodeNavigation"];

    MenuDoc *menuItem8 = [[MenuDoc alloc] initWithMenuName:[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANYABBREVIATION"] Image:[UIImage imageNamed:@"Menu1_CompanyInfo"] View:@"BusinessNavigation"];
    MenuDoc *menuItem9 = [[MenuDoc alloc] initWithMenuName:@"预约" Image:[UIImage imageNamed:@"Menu1_AppointNew"] View:@"PaymentNavigation"];

    
    menuItems = [NSMutableArray arrayWithObjects:menuItem0, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem9,menuItem6, menuItem7, menuItem8, nil];
    
    if (customer_Selected) {
        MenuDoc *menuItemAdd = [[MenuDoc alloc] initWithMenuName:@"姓名" Image:[UIImage imageNamed:customer_Selected.cus_HeadImgURL] View:@"CustomerNavigation"];
        [menuItems insertObject:menuItemAdd atIndex:2];
    }
    
    
//    MenuDoc *menuItem4 = [[MenuDoc alloc] initWithMenuName:@"基本信息" Image:[UIImage imageNamed:@"Menu1_TheCustomer"] View:@"CusTabBarController"];
//    MenuDoc *menuItem5 = [[MenuDoc alloc] initWithMenuName:@"专业记录" Image:[UIImage imageNamed:@"Menu1_TheRecord"] View:@"RecordNavigation"];
//    MenuDoc *menuItem6 = [[MenuDoc alloc] initWithMenuName:@"订单" Image:[UIImage imageNamed:@"Menu1_TheOrder"] View:@"OrderNavigation"];
//    MenuDoc *menuItem7 = [[MenuDoc alloc] initWithMenuName:@"e卡"  Image:[UIImage imageNamed:@"Menu1_TheECard"] View:@"EcardNavigation"];
//    MenuDoc *menuItem10 = [[MenuDoc alloc] initWithMenuName:@"收藏" Image:[UIImage imageNamed:@"Menu1_Favourites"] View:@"FavouritesNavigation"];
//    MenuDoc *menuItem12 = [[MenuDoc alloc] initWithMenuName:@"笔记" Image:[UIImage imageNamed:@"Menu1_Notepad"] View:@""];
//    MenuDoc *menuItem13 = [[MenuDoc alloc] initWithMenuName:@"支付记录" Image:[UIImage imageNamed:@"Menu1_PaymentHistory"] View:@"PaymentHistoryNavigation"];
    
//    if(ACC_BRANCHID == 0){
//        if (![[PermissionDoc sharePermission] rule_Record_Read]) {//!RMO(@"|1|") ||
//        menuItems = [NSMutableArray arrayWithObjects:menuItem0, menuItem11, menuItem1, menuItem2, menuItem3, menuItem4, menuItem6, menuItem7, menuItem12,  menuItem8, menuItem9, nil];
//        } else {
//        menuItems = [NSMutableArray arrayWithObjects:menuItem0, menuItem11, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem6, menuItem7, menuItem12, menuItem8, menuItem9, nil];
//        }
//    }
//    else {
//        if (![[PermissionDoc sharePermission] rule_Record_Read]) { //!RMO(@"|1|") ||
//        menuItems = [NSMutableArray arrayWithObjects:menuItem0, menuItem11, menuItem10, menuItem1, menuItem2, menuItem3, menuItem4, menuItem6, menuItem7, menuItem12 , menuItem8, menuItem9, nil];
//        } else {
//        menuItems = [NSMutableArray arrayWithObjects:menuItem0, menuItem11,  menuItem10, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5, menuItem6, menuItem7, menuItem12 ,menuItem8, menuItem9, nil];
//        }
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    customer_Selected = appDelegate.customer_Selected;
    commodityArray_Selected = appDelegate.commodityArray_Selected;
    serviceArray_Selected = appDelegate.serviceArray_Selected;
    commodityOrServiceArray_Selected =appDelegate.commodityOrServiceArray_Selected;
    [self initData];

    if ((IOS7 || IOS8)) {
        CGRect rect = self.view.frame;
        rect.origin.y = 20.0f;
        self.view.frame = rect;
        myListView.separatorInset = UIEdgeInsetsZero;
    }
    
    CGRect rect = self.view.frame;
    rect.origin.x = 0.0f;
    rect.origin.y = 0.0f;
    if (IOS7 || IOS8)
        rect.size.height -= 20;
    myListView.frame = rect;
    
    [self.myListView reloadData];
    [self scrollToBottom];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.slidingViewController setAnchorLeftRevealAmount:160.0f];
    [self.slidingViewController setUnderRightWidthLayout:ECFixedRevealWidth];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)scrollToBottom
{
    CGPoint set = myListView.contentOffset;
    if ((myListView.contentSize.height + 20 - self.view.bounds.size.height) > 0) {
        set.y = myListView.contentSize.height - self.view.bounds.size.height + 20;
    }
    myListView.contentOffset = set;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    [self initData];
    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    Boolean IsMyCustomer = appDelegate.customer_Selected.cus_IsMyCustomer;
    
    NSMutableSet *keySet = [NSMutableSet set];
    if (![[PermissionDoc sharePermission] rule_Service_Read])     [keySet addObject:@"服务"];      // 删除 “服务”
    if (![[PermissionDoc sharePermission] rule_Commodity_Read])   [keySet addObject:@"商品"];      // 删除 “商品”
    if (![[PermissionDoc sharePermission] rule_MyCustomer_Read])  [keySet addObject:@"顾客"];      // 删除 “顾客”
    
#pragma mark 权限  No.6 管理我的订单 右侧菜单 开单 结单
    if (![[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        [keySet addObject:@"开单"];
        [keySet addObject:@"结单"];
    }
    
    if (![[PermissionDoc sharePermission] rule_Order_Read]) {
        [keySet addObject:@"预约"];
    }
    if (![[PermissionDoc sharePermission] rule_Payment_Use]) {
        [keySet addObject:@"结账"];
    }
    
    /*
    if ((![[PermissionDoc sharePermission] rule_CustomerInfo_Read]) && !IsMyCustomer)  [keySet addObject:@"基本信息"];  // 删除 “个人信息”
    if (![[PermissionDoc sharePermission] rule_Record_Read]) [keySet addObject:@"专业记录"];        // 删除 “咨询记录”
    if (![[PermissionDoc sharePermission] rule_Order_Read])  [keySet addObject:@"订单"];           // 删除 “个人订单”
    if (![[PermissionDoc sharePermission] rule_ECard_Read]) {
        [keySet addObject:@"e卡"];            // 删除 “e卡”
        [keySet addObject:@"支付记录"];
    }
     */
//    if (RMO(@"|1|")) {
//        [keySet addObject:@"笔记"];   //如果有咨询记录 则移除笔记
//    }
//    if (customer_Selected && ([serviceArray_Selected count] > 0 || [commodityArray_Selected count] > 0)) {
//        
//    } else {
//        [keySet addObject:@"开单"];
//    }
    
    /*
    if (!customer_Selected) {
        [keySet addObject:@"基本信息"];
        [keySet addObject:@"笔记"];
        [keySet addObject:@"专业记录"];
        [keySet addObject:@"订单"];
        [keySet addObject:@"e卡"];
        [keySet addObject:@"支付记录"];
    }
     */
    for (NSString *keyStr in keySet) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.MenuName == %@", keyStr];
        NSArray *array = [menuItems filteredArrayUsingPredicate:predicate];
        [menuItems removeObjectsInArray:array];
    }

     return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIButton *clearButton  = (UIButton *)[cell.contentView viewWithTag:102];
    
    MenuDoc *MenuItem = [self.menuItems objectAtIndex:indexPath.row];
    imageView.image = MenuItem.Image;
    
    
    if ([MenuItem.MenuName isEqualToString:@"姓名"] && customer_Selected)  {
        titleLabel.text = customer_Selected.cus_Name;
        [imageView setImageWithURL:[NSURL URLWithString:customer_Selected.cus_HeadImgURL]
                  placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
    } else {
        titleLabel.text = MenuItem.MenuName;
    }

    
    /*
    if (([MenuItem.MenuName isEqualToString:@"服务"] && [serviceArray_Selected   count] > 0)) {
        titleLabel.text = [NSString stringWithFormat:@"%@（%ld）", MenuItem.MenuName, (long)[serviceArray_Selected count]];
    } else if (([MenuItem.MenuName isEqualToString:@"商品"] && [commodityArray_Selected count] > 0) ){
        titleLabel.text = [NSString stringWithFormat:@"%@（%ld）", MenuItem.MenuName, (long)[commodityArray_Selected count]];
    } else {
        titleLabel.text = MenuItem.MenuName;
    } */

//    if ([MenuItem.MenuName isEqualToString:@"顾客"] && customer_Selected)  {
//        titleLabel.text = customer_Selected.cus_Name;
//        [imageView setImageWithURL:[NSURL URLWithString:customer_Selected.cus_HeadImgURL]
//                  placeholderImage:[UIImage imageNamed:@"loading_HeadImg40"]];
//    }
    
//    if (([MenuItem.MenuName isEqualToString:@"顾客"] && customer_Selected)  ||
//        ([MenuItem.MenuName isEqualToString:@"服务"] && [serviceArray_Selected   count] > 0) ||
//        ([MenuItem.MenuName isEqualToString:@"商品"] && [commodityArray_Selected count] > 0))
//    {
//        [clearButton setHidden:NO];
//        [clearButton setImage:[UIImage imageNamed:@"Menu1_ClearButton"] forState:UIControlStateNormal];
//        [clearButton addTarget:self action:@selector(clearAction:) forControlEvents:UIControlEventTouchUpInside];
//    } else {
        [clearButton  setHidden:YES];
//    }
    
    if (   ([MenuItem.MenuName isEqualToString:@"基本信息"] )
        || ([MenuItem.MenuName isEqualToString:@"专业记录"] )
        || ([MenuItem.MenuName isEqualToString:@"订单"] )
        || ([MenuItem.MenuName isEqualToString:@"e卡"] )
        || ([MenuItem.MenuName isEqualToString:@"支付记录"] )
        || ([MenuItem.MenuName isEqualToString:@"笔记"])
        || ([MenuItem.MenuName isEqualToString:@"姓名"])
        ) {
        CGRect imgRect = imageView.frame;
        CGRect lblRect = titleLabel.frame;
        imgRect.origin.x = 20.0f + 10.0f;
        lblRect.origin.x = 50.0f + 10.0f;
        imageView.frame = imgRect;
        titleLabel.frame = lblRect;
        
        titleLabel.font = kFont_Medium_16;
    }  else {
        
        CGRect imgRect = imageView.frame;
        CGRect lblRect = titleLabel.frame;
        imgRect.origin.x = 20.0f;
        lblRect.origin.x = 50.0f;
        imageView.frame = imgRect;
        titleLabel.frame = lblRect;
        titleLabel.font = kFont_Medium_18;
    }
    if([MenuItem.MenuName isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_COMPANYABBREVIATION"]])
    {
        CGRect lblRect = titleLabel.frame;
        lblRect.size.width = 100;
        titleLabel.frame = lblRect;
    }
    titleLabel.textColor = kColor_DarkBlue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:1] forKey:@"ACCOUNT_MENU_TYPE"];
    
    MenuDoc *MenuItem = [self.menuItems objectAtIndex:indexPath.row];
    NSString *identifier = MenuItem.View;
    
    UIViewController *newTopViewController = nil;
    if ([MenuItem.MenuName isEqualToString:@"开单"]) {
//        UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
//        GPNavigationController *navigationController = [[GPNavigationController alloc] initWithRootViewController:viewController];
//        newTopViewController = navigationController;
        CusMainViewController *cusMain = [[CusMainViewController alloc] init];
        cusMain.viewOrigin = CusMainViewOriginMenu;
        GPNavigationController *nav = [[GPNavigationController alloc] initWithRootViewController:cusMain];
        //nav.navigationBar.translucent = YES;
        nav.canDragBack = YES;
        newTopViewController = nav;
        
    } else if ([MenuItem.MenuName isEqualToString:@"姓名"]) {
        CusMainViewController *cusMain = [[CusMainViewController alloc] init];
        GPNavigationController *nav = [[GPNavigationController alloc] initWithRootViewController:cusMain];
        //nav.navigationBar.translucent = YES;
        cusMain.viewOrigin = CusMainViewOriginMenu;
        nav.canDragBack = YES;
        newTopViewController = nav;
    } else if ([MenuItem.MenuName isEqualToString:@"笔记"]) {
        NoteListController *noteList = [[NoteListController alloc] init];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        GPNavigationController *navController = [[GPNavigationController alloc] initWithRootViewController:noteList];
        newTopViewController = navController;
        
    } else if ([MenuItem.MenuName isEqualToString:@"专业记录"]) {
        QuestionnaireListController *questList = [[QuestionnaireListController alloc] init];
        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:questList];
        navCon.canDragBack = YES;
        newTopViewController = navCon;
    } else if ([MenuItem.MenuName isEqualToString:@"结单"]) {
        CompletionOrderController *completionVC = [[CompletionOrderController alloc] init];
        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:completionVC];
        navCon.canDragBack = YES;
        newTopViewController = navCon;
    }else if ([MenuItem.MenuName isEqualToString:@"预约"]) {
        AppointmentList_ViewController *questList = [[AppointmentList_ViewController alloc] init];
        GPNavigationController *navCon = [[GPNavigationController alloc] initWithRootViewController:questList];
        navCon.canDragBack = YES;
        newTopViewController = navCon;
    } else {
        newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    }
    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

- (void)clearAction:(id)sender
{
    UIButton *clearButton = (UIButton *)sender;
    UITableViewCell *cell = nil;
    if (IOS6 || IOS8) {
        cell = (UITableViewCell *)clearButton.superview.superview;
    } else {
        cell = (UITableViewCell *) clearButton.superview.superview.superview;
    }
    NSIndexPath *indexPath = [myListView indexPathForCell:cell];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    //根据权限排列右侧列表 --->>根据此顺序处理点击事件
    if ([[PermissionDoc sharePermission] rule_Service_Read]) {
//        if (indexPath.row == 5) {
//            [appDelegate.serviceArray_Selected removeAllObjects];
//            [self removeCommodityOrServiceArray_SelectedAtIndexes:1];//1是服务
//            [appDelegate setFlag_Selected:0];
//            serviceArray_Selected = nil;
//        }
        
        if ([[PermissionDoc sharePermission] rule_Commodity_Read]) {
            if (ACC_BRANCHID != 0){
                if (indexPath.row == 6) {
                    [appDelegate.commodityArray_Selected removeAllObjects];
                    [self removeCommodityOrServiceArray_SelectedAtIndexes:0];//0是商品
                    [appDelegate setFlag_Selected:0];
                    commodityArray_Selected = nil;
                }
                if (indexPath.row == 5) { //indexPath.row == 5
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            } else{
                if (indexPath.row == 5) { //indexPath.row == 4
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            }
        } else {
            if (indexPath.row == 5) { //indexPath.row == 4
                appDelegate.customer_Selected = nil;
                customer_Selected = nil;
            }
        }
    } else {
        if ([[PermissionDoc sharePermission] rule_Commodity_Read]) {
            if (ACC_BRANCHID != 0) {
                if (indexPath.row == 6) {
                    [appDelegate.commodityArray_Selected removeAllObjects];
                    [self removeCommodityOrServiceArray_SelectedAtIndexes:0];//0是商品
                    [appDelegate setFlag_Selected:0];
                    commodityArray_Selected = nil;
                }
                if (indexPath.row == 5) { //indexPath.row == 4
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            }else{
                if (indexPath.row == 5) { //indexPath.row == 3
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            }
        } else {
            if (ACC_BRANCHID != 0) {
                if (indexPath.row == 5) { //indexPath.row == 3
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            }else{
                if (indexPath.row == 5) {
                    appDelegate.customer_Selected = nil;
                    customer_Selected = nil;
                }
            }
        }
    }
    
    //-- 初始化topViewController数据
    // [self.slidingViewController resetTopView];
    
    [myListView reloadData];
    UINavigationController *navigationC = (UINavigationController *)self.slidingViewController.topViewController;
    UIViewController *viewController = [navigationC visibleViewController];
    
    if ([viewController isKindOfClass:[ServiceListViewController class]] || [viewController isKindOfClass:[ProductListViewController class]] || [viewController isKindOfClass:[FavouritesListViewController class]]) {
        for (UIView *view in viewController.view.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                [((UITableView *)view) reloadData];
            }
        }
    }
    
    if ([viewController isKindOfClass:[CustomerListViewController class]]) {
        CustomerListViewController *customerListVC = (CustomerListViewController *)viewController;
        [customerListVC.myListView reloadData];
    }
}
-(void)removeCommodityOrServiceArray_SelectedAtIndexes:(NSInteger)type
{
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"SELF.productType == %d", ((CommodityOrServiceDoc *)commodityOrServiceArray_Selected).productType];
    NSArray *array = [commodityOrServiceArray_Selected filteredArrayUsingPredicate:predicate];
    for (int i = 0;i < [array count]; i++)
            [commodityOrServiceArray_Selected removeObject:[array objectAtIndex:i]];
    
}
@end
