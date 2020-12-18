//
//  AppointmentExecutingOrderList_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentExecutingOrderList_ViewController.h"
#import "AwaitFinishOrder.h"
#import "CustomerOrderCell.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"
#import "CusMainViewController.h"
#import "GPUniqueArray.h"
#import "SubOrderViewController.h"
#import "UIButton+InitButton.h"
#import "ServiceListViewController.h"
#import "AppointmenCreat_ViewController.h"
#import "NavigationView.h"

@interface AppointmentExecutingOrderList_ViewController ()<UITableViewDelegate,UITableViewDataSource,SelectServiceControllerDelegate>
@property (strong ,nonatomic) UITableView * myTableView;
@property (nonatomic, strong) NSMutableArray *orderList;
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@end

@implementation AppointmentExecutingOrderList_ViewController
@synthesize myTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:[NSString stringWithFormat:@"存单(%@)",self.customerName]];
    [self.view addSubview:navigationView];
    
    [self initTableView];
    
    [self requestPaymentList];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -49)style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        myTableView.sectionFooterHeight = 0;
        myTableView.sectionHeaderHeight = 10;
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    [myTableView registerNib:[UINib nibWithNibName:@"CustomerOrderCell" bundle:nil] forCellReuseIdentifier:@"Payment"];
    if ((IOS7 || IOS8)) {
        myTableView.frame = CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        myTableView.frame = CGRectMake(-5.0f,(kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f-49);
    }
    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 64.0f - 49.0f - 5.0f, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_Background_View;
    [self.view addSubview:footView];
    UIButton *add_Button = [UIButton buttonWithTitle:@"选择新项目" target:self selector:@selector(chooseNewService) frame:CGRectMake(5.0f, 6.5f, 310.0f, 36.0f) backgroundImg:ButtonStyleBlue];
    [footView addSubview:add_Button];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)chooseNewService
{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceListViewController *serviceListVC = [sb instantiateViewControllerWithIdentifier:@"ServiceListViewController"];
    serviceListVC.delegate = self.delegate;
    serviceListVC.returnViewTag = 1;
    [self.navigationController pushViewController:serviceListVC animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orderList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomerOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Payment" forIndexPath:indexPath];
    cell.choiceButton.hidden = YES;
    cell.awaitOrder = self.orderList[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    AwaitFinishOrder *awaitOrder  = self.orderList[indexPath.row];

    NSDictionary * orderDic = @{
                            @"OrderID":@((long)awaitOrder.OrderID),
                            @"OrderObjectID":@((long)awaitOrder.OrderObjectID)
                           
                           };

    NSString * name = awaitOrder.ProductName;

    [self.delegate performSelector:@selector(dismissServiceViewControllerWithSelectedExecutingOrder:userID:) withObject:name withObject:orderDic];

    [self dismissViewControllerAnimated:YES completion:^{}];

}

-(void)requestPaymentList
{
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)self.customerID];
    _requestOrderList = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetExecutingOrderList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        self.orderList = [[NSMutableArray alloc] init];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(NSArray *data, NSInteger code, id message) {
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                int  count = 1;
                if ([[obj objectForKey:@"TotalCount"]intValue] >0) {
                    count = [[obj objectForKey:@"TotalCount"]intValue] -[[obj objectForKey:@"FinishedCount"]intValue]-[[obj objectForKey:@"ExecutingCount"]intValue] ;
                }
                if([[obj objectForKey:@"ProductType"] intValue]==0 && count >0){
                    [self.orderList addObject:[[AwaitFinishOrder alloc] initWithDic:obj type:AwaitOrderFinish customerID:self.customerID]];
                }
            }];
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
