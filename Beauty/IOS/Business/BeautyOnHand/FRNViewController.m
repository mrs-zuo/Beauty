//
//  FRNViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15-1-27.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "FRNViewController.h"
#import "DFUITableView.h"
#import "DFFilterSet.h"
#import "NavigationView.h"
#import "FilterTableViewCell.h"
#import "DFDateView.h"
#import "UIButton+InitButton.h"
#import "GPNavigationController.h"
#import "LabelChooseController.h"
#import "SelectCustomersViewController.h"
#import "FooterView.h"
#import "SVProgressHUD.h"
#import "ColorImage.h"
#import "AppDelegate.h"


typedef NS_ENUM(NSInteger, SELECTIONTYPE) {
    SELECTIONCUSTOMER = 4,
    SELECTIONPERSON = 1
};
@interface FRNViewController ()<UITableViewDataSource, UITableViewDelegate, SelectCustomersViewControllerDelegate>
@property (nonatomic, strong) DFUITableView *filterTable;
@property (nonatomic, assign) SELECTIONTYPE selectType;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) DFFilterSet *priFilter;
@end

@implementation FRNViewController
@synthesize filterTable;
@synthesize supFilter;
@synthesize filterTitle;
@synthesize selectType;
@synthesize priFilter;
@synthesize filePath;
@synthesize delegate;

- (NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%ld_%ld", self.filePath, (long)ACC_ACCOUNTID, (long)ACC_BRANCHID]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Background_View;
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    [self filterDocInit:self.path];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:filterTitle];
    filterTable = [[DFUITableView alloc] initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y,310.0f, kSCREN_BOUNDS.size.height) style:UITableViewStyleGrouped];
    filterTable.delegate = self;
    filterTable.dataSource = self;
    filterTable.separatorColor = [UIColor whiteColor];
    
    if (IOS7 || IOS8) {
        filterTable.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    } else if (IOS6) {
        filterTable.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
    
    FooterView *footer = [[FooterView alloc] initWithTarget:self subTitle:@"筛选" submitAction:@selector(filterDateCheck) deleteTitle:@"重置" deleteAction:@selector(resetFilter)];
                          
    [footer showInTableView:self.filterTable];
    [self.view addSubview:navigationView];
    [self.view addSubview:filterTable];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

}

- (void)filterDocInit:(NSString *)path
{
    if (kMenu_Type == 0 &&  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        self.priFilter = [DFFilterSet getFilterDocWithPath:path];
//        if (self.priFilter.personsArray.count == 0) {
//            UserDoc *user = [[UserDoc alloc] init];
//            user.user_Name = ACC_ACCOUNTName;
//            user.user_Id = ACC_ACCOUNTID;
//            [self.priFilter.personsArray addObject:user];
//        }
    } else {
        self.priFilter = [[DFFilterSet alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.filterTable reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goBack
{
    if ([self.delegate respondsToSelector:@selector(didnotRefresh)]) {
        [self.delegate performSelector:@selector(didnotRefresh)];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 日期检查
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
//    self.supFilter.personName = self.priFilter.personName;
//    self.supFilter.personID = self.priFilter.personID;
    self.supFilter.tagsArray = self.priFilter.tagsArray;
    self.supFilter.personsArray = self.priFilter.personsArray;
    if (kMenu_Type == 0 &&  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        self.supFilter.customerName = self.priFilter.customerName;
        self.supFilter.customerID = self.priFilter.customerID;
        [self.priFilter saveFilterDocInPath:self.path];
    }
     [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 重置筛选条件
- (void)resetFilter
{
    self.priFilter = [[DFFilterSet alloc] init];
//    if (kMenu_Type == 0) {
//        UserDoc *user = [[UserDoc alloc] init];
//        user.user_Name = ACC_ACCOUNTName;
//        user.user_Id = ACC_ACCOUNTID;
//        [self.priFilter.personsArray addObject:user];
//    }
    [self.filterTable reloadData];
}
#pragma mark FilterTableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (kMenu_Type == 1 || (kMenu_Type == 0 &&((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 1)) {
        return 3;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    static NSString *fCell = @"filterCell";

    FilterTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:fCell];
    if (!filterCell) {
        filterCell = [[FilterTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:fCell];
    }
    
    if (indexPath.section == ([tableView numberOfSections] - 1) && indexPath.row == 1) {
        UIView *view = [filterCell.contentView viewWithTag:1010];
        if (view == nil) {
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(70, 0, 240, 1)];
            line.backgroundColor = kColor_Background_View;
            line.tag = 1010;
            line.userInteractionEnabled = NO;
            [filterCell.contentView addSubview:line];
        }
    } else {
        UIView *view = [filterCell.contentView viewWithTag:1010];
        if (view) {
            [view removeFromSuperview];
        }
    }

   int section =  [self sectionNum:indexPath];
    switch (section) {
        case 0:
            filterCell.textLabel.text = @"选择标签";
            filterCell.detailTextLabel.text =(self.priFilter.tagIDs.length <= 0 ? @"全部": self.priFilter.tagString);
            break;
        case 1:
            filterCell.textLabel.text = @"美丽顾问";
            filterCell.detailTextLabel.text = (self.priFilter.personName.length <= 0 ? @"全部": self.priFilter.personName);
            break;
        case 2:
            filterCell.textLabel.text = @"选择顾客";
            filterCell.detailTextLabel.text = (self.priFilter.customerName.length <= 0 ? @"全部": self.priFilter.customerName);
            break;
        case 3:
            if (indexPath.row == 0) {
                filterCell.textLabel.text = @"开始日期";
                filterCell.detailTextLabel.text = (self.priFilter.startTime.length <= 0 ? @"选择开始日期": self.priFilter.startTime);
                
            } else {
                filterCell.textLabel.text = @"结束日期";
                filterCell.detailTextLabel.text = (self.priFilter.endTime.length <= 0 ? @"选择结束日期": self.priFilter.endTime);
            }
            break;
    }
    return filterCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [self labelSelector];
    }
    if (indexPath.section == 1) {
        self.selectType = SELECTIONPERSON;
        [self personAndCustomerSelector];
    }
    if (indexPath.section == 2 && kMenu_Type == 0 &&  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        self.selectType = SELECTIONCUSTOMER;
        [self personAndCustomerSelector];
    }
    if (indexPath.section == ([tableView numberOfSections] - 1)) {
        [self dateSelector:indexPath];
    }
}

- (int)sectionNum:(NSIndexPath *)index
{
    NSLog(@"kmune =%d",kMenu_Type);
     if (kMenu_Type == 1 ||(kMenu_Type == 0  &&((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 1)){
        if (index.section == 2) {
            return 3;
        }
    }
    return index.section;
}
#pragma mark 标签选择
- (void)labelSelector
{
    LabelChooseController *labChoose = [[LabelChooseController alloc] init];
    labChoose.chooseArray = self.priFilter.tagsArray;
    
    labChoose.type = CHOOSESEARCH;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:labChoose];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:^{}];
}

#pragma mark 美丽顾问 顾客选择
- (void)personAndCustomerSelector
{
    SelectCustomersViewController *personView =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
    UserDoc *user = [[UserDoc alloc] init];
    if (self.selectType == SELECTIONCUSTOMER) {
        user.user_Id = self.priFilter.customerID;
        user.user_Name = self.priFilter.customerName;
    }
//
//    switch (self.selectType) {
//        case SELECTIONCUSTOMER:
//            user.user_Id = self.priFilter.customerID;
//            user.user_Name = self.priFilter.customerName;
//            break;
//        case SELECTIONPERSON:
//            user.user_Id = self.priFilter.personID;
//            user.user_Name = self.priFilter.personName;
//            break;
//    }

    [personView setSelectModel:(self.selectType == SELECTIONCUSTOMER ? 0 : 1) userType:self.selectType customerRange:(self.selectType == SELECTIONCUSTOMER ? CUSTOMEROFMINE: (kMenu_Type == 1 &&  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 1? CUSTOMEROFMINE: CUSTOMERINBRANCH))  defaultSelectedUsers:(self.selectType == SELECTIONCUSTOMER ? @[user] : self.priFilter.personsArray)];
    [personView setNavigationTitle:(self.selectType == SELECTIONCUSTOMER ? @"选择顾客" : @"选择美丽顾问")];
    [personView setPersonType:(self.selectType == SELECTIONCUSTOMER ? CustomePersonDefault : CustomePersonGroup)];
    personView.delegate = self;
    
    if ( kMenu_Type != 1 &&  ((AppDelegate *)[[UIApplication sharedApplication] delegate]).noteForOrder == 0) {
        personView.viewFor = 1 ;
    }
    
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
    [self.filterTable reloadData];
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
        [filterTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];;
    };
    [dateView show];
}
@end
