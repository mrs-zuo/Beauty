//
//  AppointmentExecutingOrderList_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/8/13.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AppointmentExecutingOrderList_ViewController.h"
#import "AwaitFinishOrder.h"
#import "CertificateCell.h"
#import "UIButton+InitButton.h"
#import "ServiceListViewController.h"

@interface AppointmentExecutingOrderList_ViewController ()<UITableViewDelegate,UITableViewDataSource,SelectServiceControllerDelegate,SelectExecutingControllerDelegate>
@property (strong ,nonatomic) UITableView * myTableView;
@property (nonatomic, strong) NSMutableArray *orderList;
@property (nonatomic, weak) AFHTTPRequestOperation *requestOrderList;
@end

@implementation AppointmentExecutingOrderList_ViewController
@synthesize myTableView;

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = [NSString stringWithFormat:@"存单(%@)",self.customerName];
    [self initTableView];
    
    [self requestPaymentList];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 90.0f-44)style:UITableViewStyleGrouped];

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
    [myTableView registerNib:[UINib nibWithNibName:@"CustomerOrderCell" bundle:nil] forCellReuseIdentifier:@"Payment"];
    if ((IOS7 || IOS8)) {
        myTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
    }
    myTableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height -90-44);

    
    UIButton *goBackButton = [UIButton buttonWithTitle:@""
                                                target:self
                                              selector:@selector(goBack)
                                                 frame:CGRectMake(10.0f, 7, 45.0f, 29.0f)
                                         backgroundImg:[UIImage imageNamed:@"button_GoBack"]
                                      highlightedImage:nil];
    
    
    UIBarButtonItem *goBackBarButton = [[UIBarButtonItem alloc] initWithCustomView:goBackButton];
    self.navigationItem.leftBarButtonItem = goBackBarButton;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f, 320.0f, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    
    UIButton *add_Button = [UIButton buttonWithTitle:@"选择新项目"
                                              target:self
                                            selector:@selector(chooseNewService)
                                               frame:CGRectMake(5.0f, 6.5f, kSCREN_BOUNDS.size.width - 10, 36.0f)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    [footView addSubview:add_Button];
    add_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
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
    static NSString * cellIdentify = @"cell";
    CertificateCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[CertificateCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
    }
    AwaitFinishOrder * awaitOrder = self.orderList[indexPath.row];
    cell.productName.text = awaitOrder.ProductName;
    cell.dateLabel.text = awaitOrder.OrderTime;
    cell.progressLabel.text = awaitOrder.processString;
    cell.accountLabel.text = awaitOrder.AccountName;
    cell.stateLabel.text = awaitOrder.executingString;
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
    return 70;
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

    [self.navigationController popViewControllerAnimated:YES];

}

-(void)requestPaymentList
{
     self.orderList = [[NSMutableArray alloc] init];
    NSString *para = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)self.customerID];
    _requestOrderList = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetExecutingOrderList" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
            [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
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
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
