//
//  TaskFilter_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "TaskFilter_ViewController.h"
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

@interface TaskFilter_ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,SelectCustomersViewControllerDelegate>
@property (strong,nonatomic) UITableView * myTableView;
@property (assign, nonatomic) CGFloat initialTVHeight;
@property (strong, nonatomic) UIActionSheet *actionSheet;
@end

@implementation TaskFilter_ViewController

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
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"任务筛选"];
    [self.view addSubview:navigationView];
    
    [self initTableView];
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
    if (filterDoc.TaskType == 2 || filterDoc.TaskType == 4) {
         return 3;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    switch (indexPath.row) {
        case 0:
            cell.titleLabel.text = @"任务类型";
            cell.valueText.text = filterDoc.TaskTypeStr;
            cell.valueText.placeholder = @"选择任务类型";
            break;
        case 1:
        {
            cell.titleLabel.text = @"任务担当";
            cell.valueText.text = self.slaveNames;
            cell.valueText.placeholder = @"选择员工";
            [cell setAccessoryText:@"    "];
            
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
        }
            break;
        case 2:
            cell.titleLabel.text = @"任务状态";
            [cell setAccessoryText:@"    "];
            if (filterDoc.status == 2) {
               cell.valueText.text = @"待回访";
            }else if(filterDoc.status == 3){
                cell.valueText.text = @"已完成";
            }else if (filterDoc.status == 0)
            {
                cell.valueText.text = @"全部";
            }
            cell.valueText.tag = 1001;
            cell.valueText.placeholder = @"选择任务状态";
            cell.valueText.tintColor = [UIColor clearColor];
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"任务类型" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"所有任务", @"服务预约", @"订单回访",@"联系任务",@"生日回访", nil];
            [alert showAlertViewWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) return ;
                switch (buttonIndex) {
                    case 1:
                        [filterDoc setTaskType:0];
                        break;
                    case 2:
                        [filterDoc setTaskType:1];
                        break;
                    case 3:
                        [filterDoc setTaskType:2];
                        break;
                    case 4:
                        [filterDoc setTaskType:3];
                        break;
                    case 5:
                        [filterDoc setTaskType:4];
                        break;
                }
                [myTableView reloadData];
            }];
        }
            break;
            
        case 1:
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
            
        case 2:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"订单状态" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"全部",@"待回访", @"已完成", nil];
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
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [myTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
