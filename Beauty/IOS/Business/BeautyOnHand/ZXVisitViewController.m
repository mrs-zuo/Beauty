//
//  ZXVisitViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/1/18.
//  Copyright © 2016年 ace-009. All rights reserved.
//


#import "ZXVisitViewController.h"
//#import "Task_TableViewCell.h"
#import "NavigationView.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "AppointmentDoc.h"
#import "UserDoc.h"
#import "MJRefresh.h"
#import "TaskDetail_ViewController.h"
#import "AppointmentDetail_ViewController.h"
#import "TaskFilterDoc.h"
#import "ZXVisitFilterViewController.h"
#import "ZXVisitTableViewCell.h"

NSString *const  ZXVisitViewControllerFilterData = @"ZXVisitViewControllerFilterData";


@interface ZXVisitViewController () <UITableViewDataSource,UITableViewDelegate,ZXVisitViewControllerDelegate>


@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentList;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong ,nonatomic) NSMutableArray * appointmentListMuArr;
@property (strong ,nonatomic) TaskFilterDoc * filterDoc;
@property (assign, nonatomic) NSInteger recordCount;
@property (strong ,nonatomic) NSString * taskScdStartTime;

@end

@implementation ZXVisitViewController

@synthesize myTableView;
@synthesize appointmentListMuArr;
@synthesize filterDoc;
@synthesize taskScdStartTime;

- (NSArray *)slaveID
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
    return slaveIdArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"回访"];
    //筛选
    [navigationView addButtonWithFrameWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] backGroundColor:nil title:nil frame:CGRectMake(280, 1, 36, 36) tag:1  selector:@selector(filterAppointment)];
    
    [self.view addSubview:navigationView];
    
    [self initData];
    
    appointmentListMuArr = [[NSMutableArray alloc] init];

    [self initTableView];
}

-(void)initData
{
    filterDoc = [[TaskFilterDoc alloc] init];
    [filterDoc.TaskTypeArrs addObject:@(2)]; // 订单回访
    [filterDoc.TaskTypeArrs addObject:@(4)]; // 生日回访
    filterDoc.status = 2;
    if (![[PermissionDoc sharePermission] rule_TaskAll_Write]) {
        UserDoc *user = [[UserDoc alloc] init];
        user.user_Name = ACC_ACCOUNTName;
        user.user_Id = ACC_ACCOUNTID;
        [filterDoc.ResponsiblePersonsArr removeAllObjects];
        [filterDoc.ResponsiblePersonsArr addObject:user];
    }
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49)];
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
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [myTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    [myTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self headerRefresh];
}
#pragma mark -refresh
- (void)headerRefresh
{
    if (myTableView.footerHidden == YES) {
        myTableView.footerHidden = NO;
    }
    filterDoc.PageIndex  = 1;
    taskScdStartTime = @"";
    [self requestList];
}

- (void)footerRefresh
{
    if (appointmentListMuArr.count == _recordCount) {
        [myTableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus2:@"没有更多数据了" touchEventHandle:^{}];
        myTableView.footerHidden = YES;
    } else {
        filterDoc.PageIndex ++ ;
        [self requestList];
    }
}

-(void)filterAppointment
{
    NSData *date =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"TaskFilterDoc_ACCOUNT-%ld-BRANCH-%ld-%@",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID,ZXVisitViewControllerFilterData]];
    filterDoc = [NSKeyedUnarchiver unarchiveObjectWithData:date];
    if (!filterDoc) {
        filterDoc = [[TaskFilterDoc alloc] init];
        UserDoc *user  = [[UserDoc alloc] init];
        user.user_Id = ACC_ACCOUNTID;
        user.user_Name = ACC_ACCOUNTName;
        [filterDoc.ResponsiblePersonsArr addObject:user];
    }
    
    ZXVisitFilterViewController *filter = [[ZXVisitFilterViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filter];
    filter.delegate = self;
    filter.filterDoc = filterDoc;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return appointmentListMuArr.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier= @"Cell";
    ZXVisitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NSBundle mainBundle]loadNibNamed:@"ZXVisitTableViewCell" owner:self options:nil].firstObject;
    }
    cell.data = [appointmentListMuArr objectAtIndex:indexPath.row];
    
    
//    static NSString * cellIdentify = @"cell";
//    Task_TableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
//    if (cell == nil) {
//        cell = [[Task_TableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
//        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width - 25, (45-12)/2, 10, 12)];
//        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
//        [cell.contentView addSubview:arrowsImage];
//    }
//    
//    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
//    
////    cell.dateLable.text = [NSString stringWithFormat:@"%@",appointDoc.Appointment_date];
//    
////    cell.dateLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_statusStr,appointDoc.Appointment_date];
//    cell.dateLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.visit_statusStr,appointDoc.Appointment_date];
//
//    
//    cell.serviceNameLable.text = appointDoc.Appointment_servicename;
//    
////    cell.statusLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_customer,appointDoc.Appointment_TaskTypeStr];
//    cell.statusLable.text = [NSString stringWithFormat:@"%@|%@",appointDoc.Appointment_customer,appointDoc.visit_TypeStr];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
   
    TaskDetail_ViewController *taskDetail = [[TaskDetail_ViewController alloc]init];
    taskDetail.LongID = appointDoc.Appointment_longID;
    [self.navigationController pushViewController:taskDetail animated:YES];

//    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
//    if (appointDoc.Appointment_TaskType ==2) {
//        TaskDetail_ViewController * detail = [[TaskDetail_ViewController alloc] init];
//        detail.LongID = appointDoc.Appointment_longID;
//        [self.navigationController pushViewController:detail animated:YES];
//    }else if(appointDoc.Appointment_TaskType ==1)
//    {
//        AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
//        detail.LongID = appointDoc.Appointment_longID;
//        [self.navigationController pushViewController:detail animated:YES];
//    }else if(appointDoc.Appointment_TaskType == 4) // 生日回访
//    {
//        TaskDetail_ViewController *taskDetail = [[TaskDetail_ViewController alloc]init];
//        taskDetail.LongID = appointDoc.Appointment_longID;
//        [self.navigationController pushViewController:taskDetail animated:YES];
//    }
}

- (void)dismissViewControllerWithDoc:(TaskFilterDoc *)taskFilter
{
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:taskFilter];
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"TaskFilterDoc_ACCOUNT-%ld-BRANCH-%ld-%@",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID,ZXVisitViewControllerFilterData]];
    
    filterDoc = taskFilter;
    
    [self headerRefresh];
}

#pragma mark  Http request

-(void)requestList
{
    NSInteger branchId = 0;
    branchId = ACC_BRANCHID;
    NSMutableArray * arr;
    if (filterDoc.status == 0) {
        arr = [[NSMutableArray alloc] initWithObjects:@"2",@"3",nil];
    }else{
        arr = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",filterDoc.status], nil];
    }
    
//    if (filterDoc.TaskType == 2 || filterDoc.TaskType == 4) {
//        if (filterDoc.status == 0) {
//            arr = [[NSMutableArray alloc] initWithObjects:@"2",@"3",nil];
//        }else{
//            arr = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",filterDoc.status], nil];
//        }
//    }else{
//        arr = [[NSMutableArray alloc] initWithObjects:@"2",nil];
//    }
    //    NSDictionary * par = @{
    //                           @"BranchID":@((long)branchId),
    //                           @"TaskType":@((long)filterDoc.TaskType),
    //                           @"Status":arr,
    //                           @"FilterByTimeFlag":@(0),
    //                           @"PageIndex":@((long)filterDoc.PageIndex),
    //                           @"PageSize":@((long)filterDoc.PageSize),
    //                           @"CustomerID":@((long)filterDoc.customerID),
    //                           @"TaskScdlStartTime":taskScdStartTime,
    //                           @"ResponsiblePersonIDs":self.slaveID
    //                           };
    NSDictionary * par = @{
                           @"BranchID":@((long)branchId),
                           @"TaskType":filterDoc.TaskTypeArrs,
                           @"Status":arr,
                           @"FilterByTimeFlag":@(0),
                           @"PageIndex":@((long)filterDoc.PageIndex),
                           @"PageSize":@((long)filterDoc.PageSize),
                           @"CustomerID":@((long)filterDoc.customerID),
                           @"TaskScdlStartTime":taskScdStartTime,
                           @"ResponsiblePersonIDs":self.slaveID
                           };
    
    _requestAppointmentList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (filterDoc.PageIndex ==1) {
                [appointmentListMuArr removeAllObjects];
            }
            
            _recordCount = [[data objectForKey:@"RecordCount"] integerValue];
            
            int  count = 0;
            for (NSDictionary * dic in [data objectForKey:@"TaskList"]) {
                AppointmentDoc * doc = [[AppointmentDoc alloc] init];
                
//                [doc setAppointment_status:[[dic objectForKey:@"TaskStatus"] intValue]];
                [doc setVisit_status:[[dic objectForKey:@"TaskStatus"] intValue]];
                [doc setAppointment_date:[[dic objectForKey:@"TaskScdlStartTime"]substringToIndex:16]];
                [doc setAppointment_servicename:[dic objectForKey:@"TaskName"]];
                [doc setAppointment_servicePersonal:[dic objectForKey:@"ResponsiblePersonName"]];
                [doc setAppointment_customer:[dic objectForKey:@"CustomerName"]];
                [doc setAppointment_customerID:[[dic objectForKey:@""]integerValue]];
                [doc setAppointment_longID:[[dic objectForKey:@"TaskID"] longLongValue]];
//                [doc setAppointment_TaskType:[[dic objectForKey:@"TaskType"] integerValue]];
                [doc setVisit_Type:[[dic objectForKey:@"TaskType"] integerValue]];
                [appointmentListMuArr addObject:doc];
                if (count == [[data objectForKey:@"TaskList"] count]-1) {
                    
                    taskScdStartTime = [dic objectForKey:@"TaskScdlStartTime"];
                }
                count ++ ;
            }
            
            [myTableView footerEndRefreshing];
            [myTableView headerEndRefreshing];
            
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [myTableView footerEndRefreshing];
            [myTableView headerEndRefreshing];
        }];
    } failure:^(NSError *error) {
        [myTableView footerEndRefreshing];
        [myTableView headerEndRefreshing];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
