//
//  ZXVisitFilterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ZXVisitFilterViewController.h"
#import "GPBHTTPClient.h"
#import "NavigationView.h"
#import "FooterView.h"
#import "ColorImage.h"
#import "NormalEditCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "NSDate+Convert.h"
#import "SelectCustomersViewController.h"
#import "AppointmentFilterDoc.h"
#import "UIButton+InitButton.h"

@interface ZXVisitFilterViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,SelectCustomersViewControllerDelegate>

@property (nonatomic,strong) NSArray *titleArrs;
@property (nonatomic,strong) NSArray *placeholderTitleArrs;


@property (strong,nonatomic) UITableView * myTableView;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (strong, nonatomic) UIActionSheet *actionSheet;


@end

@implementation ZXVisitFilterViewController
@synthesize myTableView;
@synthesize filterDoc;

- (NSString *)slaveNames
{
    NSMutableArray *nameArray = [NSMutableArray array];
    if (filterDoc.ResponsiblePersonsArr.count) {
        for (UserDoc *user in filterDoc.ResponsiblePersonsArr) {
            [nameArray addObject:user.user_Name];
        }
    }
    NSLog(@"the nameArray is %@", [nameArray componentsJoinedByString:@"、"]);
    return [nameArray componentsJoinedByString:@"、"];
}

- (NSString *)slaveID
{
    NSMutableArray *slaveIdArray = [NSMutableArray array];
    NSMutableString *str = [NSMutableString string];
    if (filterDoc.ResponsiblePersonsArr.count) {
        for (UserDoc *user in filterDoc.ResponsiblePersonsArr) {
            [slaveIdArray addObject:@(user.user_Id)];
        }
        NSString *tmpIds = [slaveIdArray componentsJoinedByString:@","];
        [str appendString:[NSString stringWithFormat:@"[%@]", tmpIds]];
    } else {
        [str appendString:@""];
    }
    NSLog(@"str is %@", str);
    return str;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"回访筛选"];
    [self.view addSubview:navigationView];
    
    _titleArrs = @[@"回访类型",@"任务状态",@"任务担当",@"服务顾客"];
    _placeholderTitleArrs = @[@"选择回访类型",@"选择任务状态",@"选择员工",@"选择顾客"];

    if (!filterDoc.TaskTypeArrs || filterDoc.TaskTypeArrs.count == 2) { 
        filterDoc.TaskType = 0; //默认所有回访
    }else{
        NSNumber *num = filterDoc.TaskTypeArrs.firstObject;
        filterDoc.TaskType = num.integerValue;
    }
    [self initTableView];
    [myTableView reloadData];

}
-(void)initTableView
{
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f )];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f);
    }
    _initialTVHeight = myTableView.frame.size.height;
    
    FooterView * footerView = [[FooterView alloc] initWithTarget:self subTitle:@"筛    选" submitAction:@selector(appointmentConfirm) deleteTitle:@"重    置" deleteAction:@selector(appointmentCancel)];
    [footerView showInTableView:myTableView];
}

- (void)goBack
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:^{}];
}


-(void)initData
{
    filterDoc = [[TaskFilterDoc alloc] init];
    filterDoc.TaskType = 0; //默认所有回访
    UserDoc *user  = [[UserDoc alloc] init];
    user.user_Id = ACC_ACCOUNTID;
    user.user_Name = ACC_ACCOUNTName;
    [filterDoc.ResponsiblePersonsArr addObject:user];
    
    [myTableView reloadData];
}

-(void)appointmentCancel
{
    [self initData];
}

-(void)appointmentConfirm
{
    if (filterDoc.TaskTypeArrs) {
        [filterDoc.TaskTypeArrs removeAllObjects];
    }
    switch (filterDoc.TaskType) {
        case 0:
        {
            [filterDoc.TaskTypeArrs addObject:@(2)]; // 订单回访
            [filterDoc.TaskTypeArrs addObject:@(4)]; // 生日回访

        }
            break;
        case 2:
        {
            [filterDoc.TaskTypeArrs addObject:@(2)]; // 订单回访
        }
            break;
        case 4:
        {
            [filterDoc.TaskTypeArrs addObject:@(4)]; // 生日回访
        }
            break;
            
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(dismissViewControllerWithDoc:)])
    {
        [self.delegate dismissViewControllerWithDoc:filterDoc];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titleArrs.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentify = @"cell";
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.enabled = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = _titleArrs[indexPath.row];
    cell.valueText.placeholder = _placeholderTitleArrs[indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
//            cell.valueText.text = filterDoc.TaskTypeStr;
            if (filterDoc.TaskType == 0) {
                cell.valueText.text = @"所有回访";
            }else if(filterDoc.TaskType == 2){
                cell.valueText.text = @"订单回访";
            }else if (filterDoc.TaskType == 4){
                cell.valueText.text = @"生日回访";
            }
            
        }
            break;
        case 1:
        {
            if (filterDoc.status == 2) {
                cell.valueText.text = @"待回访";
            }else if(filterDoc.status == 3){
                cell.valueText.text = @"已完成";
            }else if (filterDoc.status == 0)
            {
                cell.valueText.text = @"全部";
            }
            
        }
            break;
        case 2:
        {
            cell.valueText.text = self.slaveNames;
            
        }
            break;
        case 3:
        {
            cell.valueText.text =  filterDoc.customerName;
        }
            break;
            
        default:
            break;
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"回访类型" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"所有回访", @"订单回访",@"生日回访", nil];
            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) return ;
                switch (buttonIndex) {
                    case 1:
                        [filterDoc setTaskType:0]; //所有回访
                        break;
                    case 2:
                        [filterDoc setTaskType:2]; //订单回访
                        break;
                    case 3:
                        [filterDoc setTaskType:4]; //生日回访
                        break;
                }
                [myTableView reloadData];
            }];
        }
            break;
            
        case 1:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"任务状态" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部",@"待回访", @"已完成", nil];
            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) return ;
                switch (buttonIndex) {
                    case 1:
                        [filterDoc setStatus:0];
                        break;
                    case 2:
                        [filterDoc setStatus:2];
                        break;
                    case 3:
                        [filterDoc setStatus:3];
                        break;
                }
                [myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];

        }
            break;
        case 2:
        {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            selectCustomer.accRange = ACCBRANCH;
            if ([[PermissionDoc sharePermission] rule_TaskAll_Write])
                selectCustomer.accRange = ACCBRANCH;
            else
                selectCustomer.accRange = ACCACCOUNT;
            
            [selectCustomer setSelectModel:1
                                  userType:2
                             customerRange:([[PermissionDoc sharePermission] rule_TaskAll_Write] ? CUSTOMEROFMINE : CUSTOMERINBRANCH)
                      defaultSelectedUsers:filterDoc.ResponsiblePersonsArr];
            selectCustomer.navigationTitle = @"选择顾问";
            selectCustomer.personType = CustomePersonGroup;
            selectCustomer.delegate = self;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navigationController animated:YES completion:^{}];
        }
            break;
        case 3:
        {
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            SelectCustomersViewController *selectCustomer = [sb instantiateViewControllerWithIdentifier:@"SelectCustomersViewController"];
            selectCustomer.navigationTitle = @"选择顾客";
            CUSTOMERRANGE customerRange = CUSTOMEROFMINE;
            UserDoc *userDoc = [UserDoc new];
            userDoc.user_Type = 0;
            userDoc.user_Available = 1;
            if(filterDoc.customerID!= 0){
                userDoc.user_Id = filterDoc.customerID;
                userDoc.user_Name = filterDoc.customerName;
            }
            
            [selectCustomer setSelectModel:0
                                  userType:4
                             customerRange:customerRange
                      defaultSelectedUsers:userDoc.user_Id != 0 ? @[userDoc] : nil];
            selectCustomer.delegate = self;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectCustomer];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navigationController animated:YES completion:^{}];

        }
            break;
        default:
            break;
    }
}

#pragma mark - dismissViewControllerDelegate
-(void)dismissViewControllerWithSelectedSales:(NSArray *)userArray
{
    filterDoc.ResponsiblePersonsArr = [NSMutableArray arrayWithArray:userArray];
    if (filterDoc.ResponsiblePersonsArr.count == 0) {
        UserDoc *user  = [[UserDoc alloc] init];
        user.user_Id = ACC_ACCOUNTID;
        user.user_Name = ACC_ACCOUNTName;
        [filterDoc.ResponsiblePersonsArr addObject:user];
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:2 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}
-(void)dismissViewControllerWithSelectedUser:(NSArray *)userArray
{
    if (userArray.count == 0) {
        filterDoc.customerName = @"全部";
        filterDoc.customerID = 0;
    }else{
        for ( UserDoc * userDoc in userArray) {
            filterDoc.customerName = userDoc.user_Name;
            filterDoc.customerID = userDoc.user_Id;
        }
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:3 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

@end
