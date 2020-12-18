//
//  LeftMenuViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by TRY-MAC01 on 13-11-21.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "GPHTTPClient.h"
#import "GDataXMLNode.h"
#import "LoginViewController.h"
#import "DEFINE.h"
#import "UIActionSheet+AddBlockCallBacks.h"
#import "MenuDoc.h"
#import "InitialSlidingViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "NoteListController.h"
#import "GPNavigationController.h"
#import "QuestionnaireListController.h"
#import "PermissionDoc.h"
#import "GPBHTTPClient.h"
#import "TaskList_ViewController.h"
#import "BusinessTabbarViewController.h"
#import "ZXTaskTabbarViewController.h"
#import "CardSignViewController.h"


 
@interface LeftMenuViewController ()
@property (assign, nonatomic) NSInteger count_Remind;
@property (assign, nonatomic) NSInteger count_NewMesg;
@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *accountNameLabel;
@end

@implementation LeftMenuViewController
@synthesize backgroundView;
@synthesize menuItems;
@synthesize myListView;
@synthesize count_Remind, count_NewMesg;

- (void)awakeFromNib
{
//    MenuDoc *menuItem0 = [[MenuDoc alloc] initWithMenuName:@"提醒" Image:[UIImage imageNamed:@"Menu0_Remind"] View:@"RemindNavigation"];
    MenuDoc *menuItem1 = [[MenuDoc alloc] initWithMenuName:@"专业" Image:[UIImage imageNamed:@"Menu0_Major"] View:@"RecordNavigation"];
//    MenuDoc *menuItem2 = [[MenuDoc alloc] initWithMenuName:@"商机" Image:[UIImage imageNamed:@"Menu0_Opp"] View:@"OpportunityNavigation"];
    MenuDoc *menuItem3 = [[MenuDoc alloc] initWithMenuName:@"业务" Image:[UIImage imageNamed:@"Menu0_Order"] View:@"BusinessRootViewController"];
    MenuDoc *menuItem4 = [[MenuDoc alloc] initWithMenuName:@"飞语" Image:[UIImage imageNamed:@"Menu0_Chat"] View:@"ChatNavigation"];
    MenuDoc *menuItem5 = [[MenuDoc alloc] initWithMenuName:@"营销" Image:[UIImage imageNamed:@"Menu0_Marketing"] View:@"MarketingNavigation"];
    MenuDoc *menuItem6 = [[MenuDoc alloc] initWithMenuName:@"报表" Image:[UIImage imageNamed:@"Menu0_Report"] View:@"ReportNavigation"];
    MenuDoc *menuItem7 = [[MenuDoc alloc] initWithMenuName:@"设置" Image:[UIImage imageNamed:@"Menu0_Setting"] View:@"SettingNavigation"];
//    MenuDoc *menuItem8 = [[MenuDoc alloc] initWithMenuName:@"结账" Image:[UIImage imageNamed:@"Menu0_CheckOut"] View:@"PaymentNavigation"];
    MenuDoc *menuItem9 = [[MenuDoc alloc] initWithMenuName:@"笔记" Image:[UIImage imageNamed:@"Menu0_Notepad"] View:nil];
    
    MenuDoc *menuItem10 = [[MenuDoc alloc] initWithMenuName:@"任务" Image:[UIImage imageNamed:@"Menu0_Task"] View:nil];
    
    MenuDoc *menuItem11 = [[MenuDoc alloc] initWithMenuName:@"考勤" Image:[UIImage imageNamed:@"attendance"] View:nil];

//    MenuDoc *menuItem8 = [[MenuDoc alloc] initWithMenuName:@"登出" Image:[UIImage imageNamed:@"Menu0_Exit"] View:nil];

    //menuItem0,{menuItem2,}menuItem3 menuItem0,
    menuItems = [NSMutableArray arrayWithObjects:menuItem10, menuItem3, menuItem1, menuItem9, menuItem4, menuItem5, menuItem6, menuItem11,menuItem7, nil];
    
    NSLog(@"%d", [[PermissionDoc sharePermission] rule_Record_Read]);

    if (![[PermissionDoc sharePermission] rule_Order_Read])  [menuItems removeObject:menuItem3];  // 删除 “业绩”项
    if (![[PermissionDoc sharePermission] rule_Chat_Use])       [menuItems removeObject:menuItem4];  // 删除 “飞语”项
//    if (![[PermissionDoc sharePermission] rule_Payment_Use])       [menuItems removeObject:menuItem8];  // 删除 “飞语”项
//    if (![[PermissionDoc sharePermission] rule_Record_Read]) [menuItems removeObject:menuItem1];  // 删除 “咨询”项 || !RMO(@"|1|")
//    if (![[PermissionDoc sharePermission] rule_ECard_Expiration_Write]) [menuItems removeObject:menuItem10];  // 删除 “任务”项 || !RMO(@"|44|")

//    if (RMO(@"|1|"))[menuItems removeObject:menuItem9]; // 当有咨询记录时，删除“笔记”项
//    if (![[PermissionDoc sharePermission] rule_Oppotunity_Use] || !RMO(@"|2|")) [menuItems removeObject:menuItem2];  // 删除 “商机”项 || ACC_COMPANTSCALE
    if (![[PermissionDoc sharePermission] rule_Marketing_Read] || !RMO(@"|3|")) [menuItems removeObject:menuItem5];  // 删除 “营销”项  || ACC_COMPANTSCALE
    NSLog(@"the string is %@",[[PermissionDoc sharePermission] record_marketing_oppotun]);
    NSLog(@"the RMO_1:%d RMO_2:%d RMO_3:%d RMO_5:%d RMO_s:%d",RMO(@"1"), RMO(@"2"), RMO(@"3"), RMO(@"4"), RMO(@"s"));
    
    
    if (![[PermissionDoc sharePermission] rule_MyReport_Read] && ![[PermissionDoc sharePermission] rule_BusinessReport_Read])
        [menuItems removeObject:menuItem6];  // 删除 “报表”项
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *account_ImageURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_HEADIMAGE"];
    [_headImageView setImageWithURL:[NSURL URLWithString:account_ImageURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    [self requestTheTotalCountOfNewMessage];
#warning 暂时去掉
//    [self requesRemindNumber];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ((IOS7 || IOS8)) {
        self.view.backgroundColor = [UIColor blackColor];
        backgroundView.frame = CGRectMake(0.0f, 20.0f, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 20.0f);
        myListView.separatorInset = UIEdgeInsetsZero;
    }
    
    //初始化头像和名字
    UIView *view = [[UIView alloc]init];
    if((IOS7 || IOS8))
        [view setFrame:CGRectMake(0 ,22 , 160, 140)];
    else
        [view setFrame:CGRectMake(0, 0, 160, 140)];
    _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 18, 80, 80)];
    _accountNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 106, 140, 21)];
    _accountNameLabel.textAlignment = NSTextAlignmentCenter;
    _headImageView.layer.shadowOffset = CGSizeZero;
    _headImageView.layer.shadowOpacity = .8f;
    _headImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:_headImageView.layer.bounds] CGPath];
//    NSString *account_ImageURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_HEADIMAGE"];
    NSString *account_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"];
//    [_headImageView setImageWithURL:[NSURL URLWithString:account_ImageURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
    [_accountNameLabel setText:account_Name];
    UIView *lineView = [[UIView alloc]init];
    if (IOS6) {
        [lineView setFrame:CGRectMake(0, 140, 160, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:223.f/255 green:223.f/255 blue:223.f/255 alpha:1.f];
    }else if((IOS7 || IOS8)){
        [lineView setFrame:CGRectMake(0, 140, 160, .5)];
        lineView.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:1.f];
    }
    [view addSubview:_headImageView];
    [view addSubview:_accountNameLabel];
    
    [view addSubview:lineView];
    [self.view addSubview:view];
    
    
    CGRect rect = self.view.frame;
    rect.origin.x = 0.0f;
    rect.origin.y = 142.0f;
    rect.size.height = kSCREN_BOUNDS.size.height - 162.f;
    rect.size.width = 160.f;
    myListView.frame = rect;

    [self.slidingViewController setAnchorRightPeekAmount:160.0f];
    [self.slidingViewController setUnderLeftWidthLayout:ECFullWidth];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return self.menuItems.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        NSString *cellIdentity = @"UserMenu_PhotoCell";
//        __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity forIndexPath:indexPath];
//        UIImageView *headImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
//        UILabel  *accountNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
//    
//        headImageView.layer.shadowOffset = CGSizeZero;
//        headImageView.layer.shadowOpacity = 0.8f;
//        headImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRect:headImageView.layer.bounds] CGPath];
//
//        NSString *acc_ImgURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_HEADIMAGE"];
//        NSString *acc_Name   = [[NSUserDefaults standardUserDefaults] objectForKey:@"ACCOUNT_NAME"];
//        
//        [headImageView setImageWithURL:[NSURL URLWithString:acc_ImgURL] placeholderImage:[UIImage imageNamed:@"loading_HeadImg80"]];
//        [accountNameLabel setText:acc_Name];
//        return cell;
//        
//    } else {
    NSString *cellIdentifier = @"MenuCell";
    __autoreleasing UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    UIView *lineView = [[UIView alloc]init];
    if(indexPath.row == 0){
        if (IOS6) {
            [lineView setFrame:CGRectMake(0, 0, 160, 1)];
            lineView.backgroundColor = [UIColor whiteColor];
        }
        [cell addSubview:lineView];
    }
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView *accessoryImgView = (UIImageView *)[cell.contentView viewWithTag:102];
    UILabel *accessory_NumberLabel = (UILabel *)[cell.contentView viewWithTag:103];
    
    accessory_NumberLabel.font = kFont_Light_12;
    accessory_NumberLabel.textColor = [UIColor whiteColor];
    accessory_NumberLabel.textAlignment = NSTextAlignmentCenter;
    
    MenuDoc *MenuItem = [self.menuItems objectAtIndex:indexPath.row ];
    imageView.image = MenuItem.Image;
    titleLabel.text = MenuItem.MenuName;
    
    if ([MenuItem.MenuName isEqualToString:@"飞语"] && count_NewMesg > 0) {
        accessoryImgView.hidden = NO;
        accessory_NumberLabel.hidden = NO;
        [accessoryImgView setImage:[UIImage imageNamed:@"newsCount_bgImage"]];
        if (count_NewMesg <= 99)
            [accessory_NumberLabel setText:[NSString stringWithFormat:@"%ld", (long)count_NewMesg]];
        else
            [accessory_NumberLabel setText:@"N"];
        
    } else if ([MenuItem.MenuName isEqualToString:@"提醒"] && count_Remind> 0) {
        accessoryImgView.hidden = NO;
        accessory_NumberLabel.hidden = NO;
        [accessoryImgView setImage:[UIImage imageNamed:@"newsCount_bgImage"]];
        if (count_Remind <= 99)
            [accessory_NumberLabel setText:[NSString stringWithFormat:@"%ld", (long)count_Remind]];
        else
            [accessory_NumberLabel setText:@"N"];
        
    }
    else {
        accessoryImgView.hidden = YES;
        accessory_NumberLabel.hidden = YES;
    }
    titleLabel.font = kFont_Medium_18;
    titleLabel.textColor = kColor_DarkBlue;
    return cell;
    //}
    //return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0)
//        return 140.0f;
//    else
        return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  //  if (indexPath.row == 0) return;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"ACCOUNT_MENU_TYPE"]; 
    
//    if (indexPath.row != [menuItems count] - 1) {
        MenuDoc *MenuItem = [self.menuItems objectAtIndex:indexPath.row];
#pragma mark Test
    if ([MenuItem.MenuName isEqualToString:@"专业"]) {
        QuestionnaireListController *quese = [[QuestionnaireListController alloc] init];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        GPNavigationController *nav = [[GPNavigationController alloc] initWithRootViewController:quese];
        nav.canDragBack = YES;
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = nav;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
        return;
    }
    if ([MenuItem.MenuName isEqualToString:@"任务"]) {
//        TaskList_ViewController * taskList = [[TaskList_ViewController alloc] init];
//        GPNavigationController * navController = [[GPNavigationController alloc] initWithRootViewController:taskList];
//        navController.canDragBack = YES;
//        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
//            CGRect frame = self.slidingViewController.topViewController.view.frame;
//            self.slidingViewController.topViewController = navController;
//            self.slidingViewController.topViewController.view.frame = frame;
//            [self.slidingViewController resetTopView];
//        }];
        ZXTaskTabbarViewController * taskList = [[ZXTaskTabbarViewController alloc] init];
        taskList.selectedIndex = 0 ;
        GPNavigationController * navController = [[GPNavigationController alloc] initWithRootViewController:taskList];
        navController.canDragBack = YES;
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = navController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];        
        return;
    }
    if ([MenuItem.MenuName isEqualToString:@"业务"]) {
        BusinessTabbarViewController * taskList = [[BusinessTabbarViewController alloc] init];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        taskList.selectedIndex = 0 ;
        GPNavigationController * navController = [[GPNavigationController alloc] initWithRootViewController:taskList];
        navController.canDragBack = YES;
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = navController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
        return;
    }
    if ([MenuItem.MenuName isEqualToString:@"考勤"]) {
        CardSignViewController *cardSignVC = [[CardSignViewController alloc] init];
        GPNavigationController *nav = [[GPNavigationController alloc] initWithRootViewController:cardSignVC];
        nav.canDragBack = YES;
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = nav;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
        return;
    }
    if ([MenuItem.MenuName isEqualToString:@"笔记"]) {
        NoteListController *noteList = [[NoteListController alloc] init];
        ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder = 0;
        GPNavigationController *navController = [[GPNavigationController alloc] initWithRootViewController:noteList];
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = navController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];

    } else {
        UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:MenuItem.View];
        [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
            CGRect frame = self.slidingViewController.topViewController.view.frame;
            self.slidingViewController.topViewController = newTopViewController;
            self.slidingViewController.topViewController.view.frame = frame;
            [self.slidingViewController resetTopView];
        }];
     }
    
//    }
    /*
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出当前账号" otherButtonTitles: nil];
        
//        UIView *bgView = [[UIView alloc] init];
//        CGRect rect = self.view.bounds;
//        rect.size.height -= 20.0f;
//        bgView.backgroundColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.5f];
        
        //[self.view addSubview:bgView];
        [actionSheet showActionSheetWithInView:[[UIApplication sharedApplication] keyWindow] handler:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                // 清空缓存
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_USERID"];
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"ACCOUNT_COMPANTID"];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate setCustomer_Selected:nil];
                [appDelegate.serviceArray_Selected removeAllObjects];
                [appDelegate.commodityArray_Selected removeAllObjects];
                double delayInSeconds = 0.8f;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    //循环查找最底层模态视图，再退出
                    UIViewController *viewController = self;
                    while(viewController.presentingViewController) {
                        viewController = viewController.presentingViewController;
                    }
                    if(viewController) {
                        [viewController dismissViewControllerAnimated:YES completion:nil];
                    }
                });
               // [self dismissViewControllerAnimated:YES completion:^{}];
                appDelegate.isNeedGetVersion = NO;
            }
        }];
    }
     */
}

#pragma mark - 接口

// 获取新消息的条目
- (void)requestTheTotalCountOfNewMessage
{
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Message/getNewMessageCount" andParameters:nil failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            count_NewMesg = [[data objectForKey:@"NewMessageCount" ] integerValue];
            [myListView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
/*
    [[GPHTTPClient shareClient] requestTheTotalCountOfNewMessageWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            count_NewMesg = [[[[contentData elementsForName:@"NewMessageCount"] objectAtIndex:0] stringValue] integerValue];
             [myListView reloadData];
        } failure:^{}];
        
    } failure:^(NSError *error) {}];
 */
}

- (void)requesRemindNumber
{
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"BranchID\":%ld}", (long)ACC_ACCOUNTID, (long)ACC_BRANCHID];
    [[GPBHTTPClient sharedClient] requestUrlPath:@"/Notice/GetRemindCountByAccountID" andParameters:par failureHandle:AFRequestFailureNone WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
//            count_Remind = [[data objectForKey:@"RemindCount" ] integerValue];
            count_Remind = [data integerValue];
            [myListView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
    /*
    [[GPHTTPClient shareClient] requestMessageWithRemindWithSuccess:^(id xml) {
        [GDataXMLDocument parseXML2:xml viewController:nil showSuccessMsg:NO showFailureMsg:NO success:^(GDataXMLElement *contentData, NSString *resultMsg) {
            count_Remind= [[contentData stringValue] intValue];
            [myListView reloadData];
        } failure:^{}];
    } failure:^(NSError *error) {
    }];
    */
}

@end

