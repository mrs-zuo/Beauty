//
//  AppointmentList_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/11.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentList_ViewController.h"
#import "AppointmentListTableViewCell.h"
#import "NavigationView.h"
#import "SVProgressHUD.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "AppointmentDoc.h"
#import "AppointmentFilterDoc.h"
#import "AppointmentDetail_ViewController.h"
#import "AppointmenCreat_ViewController.h"
#import "AppointmentFilter_ViewController.h"
#import "MJRefresh.h"
#import "AppDelegate.h"

NSString *const AppointmentList_ViewControllerFilterData = @"AppointmentList_ViewControllerFilterData";

@interface AppointmentList_ViewController ()<UITableViewDataSource,UITableViewDelegate,appointmentFilterViewControllerDelegate,appointmentCreateViewControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *requestAppointmentList;
@property (strong ,nonatomic) UITableView * myTableView;
@property (strong ,nonatomic) NSMutableArray * appointmentListMuArr;
@property (strong ,nonatomic) AppointmentFilterDoc * filterDoc;
@property (assign, nonatomic) NSInteger recordCount;
@property (strong, nonatomic) NSString * taskScdlStartTime;

@end

@implementation AppointmentList_ViewController
@synthesize myTableView;
@synthesize appointmentListMuArr;
@synthesize filterDoc;
@synthesize taskScdlStartTime;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}

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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"预约"];
    //添加预约
    if ([[PermissionDoc sharePermission] rule_MyOrder_Write]) {
        [navigationView addButtonWithFrameWithTarget:self backgroundImage:[UIImage imageNamed:@"add_Appoinment_ios"] backGroundColor:nil title:nil frame:CGRectMake(245, 1, 36.0f,36.0f) tag:1  selector:@selector(addAppointment)];
    }
    //筛选
    [navigationView addButtonWithFrameWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] backGroundColor:nil title:nil frame:CGRectMake(280, 1, 36, 36) tag:1  selector:@selector(filterAppointment)];
    
    
    [self.view addSubview:navigationView];
    
    appointmentListMuArr = [[NSMutableArray alloc] init];
    
    [self initData];
    [self initTableView];
}

-(void)initData
{
    filterDoc = [[AppointmentFilterDoc alloc] init];
    [filterDoc.taskTypeArrs addObject:@(1)]; //  默认1

    if (![[PermissionDoc sharePermission] rule_BranchOrder_Read]) {
        UserDoc *user = [[UserDoc alloc] init];
        user.user_Name = ACC_ACCOUNTName;
        user.user_Id = ACC_ACCOUNTID;
        [filterDoc.ResponsiblePersonsArr addObject:user];
    }
    
    if (self.viewTag == 1) {
        filterDoc.CustomerID = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
        filterDoc.CustomerName = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name;
    }
}

-(void)initTableView
{
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
    
    [myTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    
    [myTableView addFooterWithTarget:self action:@selector(footerRefresh)];
    
    [self headerRefresh];
}

#pragma mark -refresh
- (void)headerRefresh
{
    if (myTableView.footerHidden == YES) {
        myTableView.footerHidden = NO;
    }
    
    filterDoc.PageIndex  = 1;
    taskScdlStartTime = @"";
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

-(void)addAppointment{
    
    AppointmenCreat_ViewController * create = [[AppointmenCreat_ViewController alloc] init];
    create.viewTag = self.viewTag;
    create.delegate = self;
    [self.navigationController pushViewController:create animated:YES];
}

-(void)filterAppointment
{
    NSData *date =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"FilterDoc_ACCOUNT-%ld-BRANCH-%ld-%@",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID,AppointmentList_ViewControllerFilterData]];
    filterDoc = [NSKeyedUnarchiver unarchiveObjectWithData:date];
    if (!filterDoc) {
        filterDoc = [AppointmentFilterDoc new];
        UserDoc *user  = [[UserDoc alloc] init];
        user.user_Id = ACC_ACCOUNTID;
        user.user_Name = ACC_ACCOUNTName;
        [filterDoc.ResponsiblePersonsArr addObject:user];
    }
    
    AppointmentFilter_ViewController * filter = [[AppointmentFilter_ViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filter];
    filter.delegate = self;
    filter.filterDoc = filterDoc;
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
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
    static NSString * cellIdentify = @"cell";
    AppointmentListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[AppointmentListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(kSCREN_BOUNDS.size.width - 25, (65-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
    
    cell.dateLable.text = [NSString stringWithFormat:@"%@",appointDoc.Appointment_date];
    cell.customerNameLable.text = appointDoc.Appointment_customer;
    cell.serviceNameLable.text = appointDoc.Appointment_servicename;
    cell.statusLable.text = appointDoc.Appointment_statusStr;
    cell.appointPersonalLable.text = appointDoc.Appointment_servicePersonalID > 0? appointDoc.Appointment_servicePersonal:@"到店指定";
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
    AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
    detail.LongID = appointDoc.Appointment_longID;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)dismissViewControllerWithDoc:(AppointmentFilterDoc *)orderFilter
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:orderFilter];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"FilterDoc_ACCOUNT-%ld-BRANCH-%ld-%@",(long)ACC_ACCOUNTID,(long)ACC_BRANCHID,AppointmentList_ViewControllerFilterData]];
    
    filterDoc = orderFilter;
    
    [self headerRefresh];
}
//创建预约返回实现代理
- (void)dismissViewControllerWithCus_ID:(NSInteger)CustomerID
{
    filterDoc.CustomerID = CustomerID;
    [self headerRefresh];
}

#pragma mark  Http request

-(void)requestList
{
    NSInteger branchId = 0;
    branchId = ACC_BRANCHID;
    NSMutableArray * arr;
    if (filterDoc.status == 0) {
        arr = [[NSMutableArray alloc] initWithObjects:@"1",@"2",@"3",@"4", nil];
    }else if(filterDoc.status == -1)
    {
        arr = [[NSMutableArray alloc] initWithObjects:@"1",@"2", nil];
        
    }else{
        arr = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%d",filterDoc.status], nil];
    }

//    NSDictionary * par = @{
//                               @"BranchID":@((long)branchId),
//                               @"TaskType":@(1),
//                               @"Status":arr,
//                               @"FilterByTimeFlag":@((long)filterDoc.FilterByTimeFlag),
//                               @"StartTime":filterDoc.startTime,
//                               @"EndTime":filterDoc.endTime,
//                               @"PageIndex":@((long)filterDoc.PageIndex),
//                               @"PageSize":@((long)10),
//                               @"CustomerID":@((long)filterDoc.CustomerID),
//                               @"TaskScdlStartTime":taskScdlStartTime,
//                               @"ResponsiblePersonIDs":self.slaveID
//                            };

    NSDictionary * par = @{
                           @"BranchID":@((long)branchId),
                           @"TaskType":filterDoc.taskTypeArrs,
                           @"Status":arr,
                           @"FilterByTimeFlag":@((long)filterDoc.FilterByTimeFlag),
                           @"StartTime":filterDoc.startTime,
                           @"EndTime":filterDoc.endTime,
                           @"PageIndex":@((long)filterDoc.PageIndex),
                           @"PageSize":@((long)10),
                           @"CustomerID":@((long)filterDoc.CustomerID),
                           @"TaskScdlStartTime":taskScdlStartTime,
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
                
                [doc setAppointment_status:[[dic objectForKey:@"TaskStatus"] intValue]];
                [doc setAppointment_date:[[dic objectForKey:@"TaskScdlStartTime"] substringToIndex:16]];
                [doc setAppointment_servicename:[dic objectForKey:@"TaskName"]];
                [doc setAppointment_servicePersonal:[dic objectForKey:@"ResponsiblePersonName"]];
                [doc setAppointment_servicePersonalID:[[dic objectForKey:@"ResponsiblePersonID"] integerValue]];
                [doc setAppointment_customer:[dic objectForKey:@"CustomerName"]];
                [doc setAppointment_customerID:[[dic objectForKey:@""]integerValue]];
                [doc setAppointment_longID:[[dic objectForKey:@"TaskID"] longLongValue]];
                [appointmentListMuArr addObject:doc];
                if (count == [[data objectForKey:@"TaskList"] count]-1) {
                    taskScdlStartTime = [dic objectForKey:@"TaskScdlStartTime"];
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
    
}


@end
