//
//  OppFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-5-6.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "OppFilterViewController.h"
#import "DFUITableView.h"
#import "UIButton+InitButton.h"
#import "NavigationView.h"
#import "FilterTableViewCell.h"
#import "FooterView.h"
#import "DFFilterSet.h"
#import "DFDateView.h"
#import "SelectCustomersViewController.h"   
#import "UserDoc.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "SVProgressHUD.h"


typedef NS_ENUM(NSInteger, SELECTIONTYPE) {
    SELECTIONCUSTOMER = 4,
    SELECTIONPERSON = 1
};

@interface OppFilterViewController ()<UITableViewDelegate, UITableViewDataSource, SelectCustomersViewControllerDelegate>
@property (nonatomic, strong) DFUITableView *filterTableView;
@property (nonatomic, strong) DFFilterSet *priFilter;
@property (nonatomic, assign) SELECTIONTYPE selectType;
@property (nonatomic, strong) NSString *path;

@end

@implementation OppFilterViewController
@synthesize filterTableView;
@synthesize priFilter;
@synthesize selectType;
@synthesize supFilter;


- (NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%ld_%ld", @"Opp", (long)ACC_ACCOUNTID, (long)ACC_BRANCHID]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    
    self.view.backgroundColor = kColor_Background_View;
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"商机筛选"];
    filterTableView = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    filterTableView.delegate = self;
    filterTableView.dataSource = self;
    filterTableView.separatorColor = [UIColor whiteColor];
    
    if (IOS7 || IOS8) {
        filterTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        filterTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footer = [[FooterView alloc] initWithTarget:self submitImg:[UIImage imageNamed:@"filtrate"] submitAction:@selector(filterDateCheck) deleteImg:[UIImage imageNamed:@"reset"] deleteAction:@selector(resetFilter)];
    [footer showInTableView:self.filterTableView];
    [self.view addSubview:navigationView];
    [self.view addSubview:filterTableView];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData {
    
    self.priFilter = [DFFilterSet getFilterDocWithPath:self.path];
//    if (self.priFilter.personsArray.count == 0) {
//        UserDoc *user = [[UserDoc alloc] init];
//        user.user_Name = ACC_ACCOUNTName;
//        user.user_Id = ACC_ACCOUNTID;
//        [self.priFilter.personsArray addObject:user];
//    }
}
#pragma mark 确定 日期检查
- (void)filterDateCheck
{
    NSDateFormatter *dateFor = [[NSDateFormatter alloc] init];
    dateFor.dateFormat = @"yyyy年MM月dd日";
    
    NSDate *dateStar = [dateFor dateFromString:self.priFilter.startTime];
    NSDate *dateEnd = [dateFor dateFromString:self.priFilter.endTime];
    
    if (dateStar == nil && dateEnd == nil) {
        [self filterAndSave];
    } else if (dateStar == nil || dateEnd == nil) {
        [SVProgressHUD showErrorWithStatus2:@"日期有误，请重新设置" touchEventHandle:^{ }];
    } else {
        switch ([dateStar compare:dateEnd]) {
            case NSOrderedDescending:
                [SVProgressHUD showErrorWithStatus2:@"日期有误，请重新设置" touchEventHandle:^{ }];
                break;
            case NSOrderedSame:
            case NSOrderedAscending:
                self.priFilter.timeFlag = 1;
                [self filterAndSave];
                break;
        }
    }

}

#pragma mark 保存条件 并且筛选
- (void)filterAndSave
{
    self.supFilter.timeFlag = self.priFilter.timeFlag;
    self.supFilter.startTime = self.priFilter.startTime;
    self.supFilter.endTime = self.priFilter.endTime;
    self.supFilter.personName = self.priFilter.personName;
    self.supFilter.personID = self.priFilter.personID;
    self.supFilter.customerName = self.priFilter.customerName;
    self.supFilter.customerID = self.priFilter.customerID;
    self.supFilter.oppType = self.priFilter.oppType;
    self.supFilter.oppName = self.priFilter.oppName;
    self.supFilter.personsArray = [self.priFilter.personsArray mutableCopy];
    [self.priFilter saveFilterDocInPath:self.path];
    
    [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark 重置
- (void)resetFilter
{
    self.priFilter = [[DFFilterSet alloc] init];
//    if (kMenu_Type == 0) {
//        UserDoc *user = [[UserDoc alloc] init];
//        user.user_Name = ACC_ACCOUNTName;
//        user.user_Id = ACC_ACCOUNTID;
//        [self.priFilter.personsArray addObject:user];
//    }
    [self.filterTableView reloadData];
}

#pragma mark --tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == ([tableView numberOfSections] - 1)) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *oppFilterCell = @"oppFilterCell";
    FilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:oppFilterCell];
    if (!cell) {
        cell = [[FilterTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:oppFilterCell];
    }
    
    if (indexPath.section == ([tableView numberOfSections] - 1) && indexPath.row == 1) {
        UIView *view = [cell.contentView viewWithTag:1010];
        if (view == nil) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(70, 0, 240, 1)];
            line.backgroundColor = kColor_Background_View;
            line.tag = 1010;
            line.userInteractionEnabled = NO;
            [cell.contentView addSubview:line];
        }
    } else {
        UIView *view = [cell.contentView viewWithTag:1010];
        if (view) {
            [view removeFromSuperview];
        }
    }

    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"商机类型";
            cell.detailTextLabel.text = self.priFilter.oppName;
            break;
        case 1:
            cell.textLabel.text = @"美丽顾问";
            cell.detailTextLabel.text = (self.priFilter.personName.length <= 0 ? @"全部": self.priFilter.personName);
            break;
        case 2:
            cell.textLabel.text = @"顾客";
            cell.detailTextLabel.text = (self.priFilter.customerName.length <= 0 ? @"全部": self.priFilter.customerName);
            break;
        case 3:
            if (indexPath.row == 0) {
                cell.textLabel.text = @"开始日期";
                cell.detailTextLabel.text = (self.priFilter.startTime.length <= 0 ? @"选择开始日期": self.priFilter.startTime);
                
            } else {
                cell.textLabel.text = @"结束日期";
                cell.detailTextLabel.text = (self.priFilter.endTime.length <= 0 ? @"选择结束日期": self.priFilter.endTime);
            }
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self chooseOpportunityType];
    }
    if (indexPath.section == 1) {
        self.selectType = SELECTIONPERSON;
        [self personAndCustomerSelector];
    }
    if (indexPath.section == 2) {
        self.selectType = SELECTIONCUSTOMER;
        [self personAndCustomerSelector];
    }
    if (indexPath.section == 3) {
        [self dateSelector:indexPath];
    }
}

#pragma mark 选择商机类型   全部 -1 服务0 商品1 
- (void)chooseOpportunityType
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"类型选择" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部", @"服务", @"商品", nil];
    [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 1:
                self.priFilter.oppType = OpportunityAll;
                break;
            case 2:
                self.priFilter.oppType = OpportunityService;
                break;
            case 3:
                self.priFilter.oppType = OpportunityCommodity;
                break;
        }
        [self.filterTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

#pragma mark 美丽顾问 顾客选择
- (void)personAndCustomerSelector
{
    SelectCustomersViewController *personView =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    UserDoc *user = [[UserDoc alloc] init];
    switch (self.selectType) {
        case SELECTIONCUSTOMER:
            user.user_Id = self.priFilter.customerID;
            user.user_Name = self.priFilter.customerName;
            break;
        case SELECTIONPERSON:
//            user.user_Id = self.priFilter.personID;
//            user.user_Name = self.priFilter.personName;
            break;
    }
    
    [personView setSelectModel:(self.selectType == SELECTIONCUSTOMER ? 0 : 1) userType:self.selectType customerRange:(self.selectType == SELECTIONCUSTOMER ? CUSTOMEROFMINE :CUSTOMERINBRANCH) defaultSelectedUsers:(self.selectType == SELECTIONCUSTOMER ? @[user] : self.priFilter.personsArray)];
    [personView setNavigationTitle:(self.selectType == SELECTIONCUSTOMER ? @"选择顾客" : @"选择美丽顾问")];
    [personView setPersonType:(self.selectType == SELECTIONCUSTOMER ? CustomePersonDefault : CustomePersonGroup)];
    personView.delegate = self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:personView];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark 美丽顾问 顾客 delegate
- (void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    UserDoc *userDoc = [userArray firstObject];
    switch (self.selectType) {
        case SELECTIONCUSTOMER:
            self.priFilter.customerID = userDoc.user_Id;
            self.priFilter.customerName = userDoc.user_Name;
            break;
        case SELECTIONPERSON:
            self.priFilter.personsArray = [userArray mutableCopy];
            break;
    }
    [self.filterTableView reloadData];
}

#pragma mark 日期选择
- (void)dateSelector:(NSIndexPath *)indexPath
{
    DFDateView *dateView = [[DFDateView alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    
    dateView.startBlock = ^NSDate *{
        if (indexPath.row == 0) {
            return [formatter dateFromString:self.priFilter.startTime];
        } else {
            return [formatter dateFromString:self.priFilter.endTime];
        }
    };
    
    dateView.completionBlock = ^(NSDate *date){
        if (indexPath.row == 0) {
            priFilter.startTime = [formatter stringFromDate:date];
        } else {
            priFilter.endTime = [formatter stringFromDate:date];
        }
        [filterTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];;
    };
    [dateView show];
}

@end
