//
//  BuyViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "BuyViewController.h"
#import "ServiceOneViewController.h"
#import "RecommendTableViewCell.h"
#import "AppointmentStoreRecommendModel.h"
#import "ServiceDetailViewController.h"
#import "AppointmenCreat_ViewController.h"
@interface BuyViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *getAppointmentRecommendOperation;
@property (strong, nonatomic) NSMutableArray *theRecommendArray;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation BuyViewController

@synthesize getAppointmentRecommendOperation;
@synthesize theRecommendArray;
@synthesize tableView;

- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    [self requestAppointmentRecommendOperation];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    tableView = [[UITableView alloc] init];
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = kColor_Clear;
    tableView.backgroundView = nil;
    tableView.separatorColor = kTableView_LineColor;
    tableView.autoresizingMask = UIViewAutoresizingNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    if ((IOS7 || IOS8)) {
        tableView.separatorInset = UIEdgeInsetsZero;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height -  44 - 49 + 20 - 5);

    [self.view addSubview:tableView];
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:footView];
    [self.tableView registerClass:[RecommendTableViewCell class] forCellReuseIdentifier:@"recommendCell"];
 
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, tableView.frame.origin.y + tableView.frame.size.height + 5, kSCREN_BOUNDS.size.width, 49.0f)];
    bottomView.backgroundColor = kColor_White;
    [self.view addSubview:bottomView];
    
    UIButton *appointmentCancel = [UIButton buttonWithTitle:@"去看看其他服务" target:self selector:@selector(buttonClickAppointment) frame:CGRectMake(0,3, kSCREN_BOUNDS.size.width - 10,49) backgroundImg:nil  highlightedImage:nil];
    appointmentCancel.titleLabel.font=kNormalFont_14;
    [appointmentCancel setTitleColor:kColor_Black forState:UIControlStateNormal];
    [bottomView addSubview:appointmentCancel];

}

- (void)buttonClickAppointment
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceOneViewController *one = [board instantiateViewControllerWithIdentifier:@"ServiceOneViewController"];
    [self.navigationController pushViewController:one animated:YES];
}
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return theRecommendArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    RecommendTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[RecommendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.appointmentButton.tag = indexPath.row + 2000;
        [cell.appointmentButton addTarget:self action:@selector(toAppointment:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.detailButton.tag = indexPath.row + 1000;
        [cell.detailButton addTarget:self action:@selector(toDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    AppointmentStoreRecommendModel *model = self.theRecommendArray[indexPath.row];
    cell.AppointmentStoreRecommend = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (void)toAppointment:(UIButton *)button
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    AppointmentStoreRecommendModel *model = [theRecommendArray objectAtIndex:button.tag - 2000];
    AppointmenCreat_ViewController *create = [[AppointmenCreat_ViewController alloc] init];
    create.BranchID = _BranchID;
    create.branchName = _BranchName;
    create.serviceCode = model.ProductCode ;
    create.serviceName =model.ProductName;
    create.ReservedOrderType = 2;
    create.taskSourceType = 4;
    
    [self.navigationController pushViewController:create animated:YES];
}
- (void)toDetail:(UIButton *)button
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;

    AppointmentStoreRecommendModel * model = [theRecommendArray objectAtIndex:button.tag -1000];
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceDetailViewController * service = (ServiceDetailViewController*)[sb instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
    service.commodityCode = model.ProductCode;
    
    [self.navigationController pushViewController:service animated:YES];
    
}
//网络请求
- (void)requestAppointmentRecommendOperation
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    NSInteger customerID = [[defaults objectForKey:@"CUSTOMER_USERID"] integerValue];
    NSDictionary *para = @{@"BranchID":@(_BranchID),
                           @"CustomerID":@(customerID),
                           @"ImageHeight":@160,
                           @"ImageWidth":@160};
    getAppointmentRecommendOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Service/GetBoughtServiceList" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [array addObject:[[AppointmentStoreRecommendModel alloc] initWithDic:obj]];
            }];
            self.theRecommendArray = [array mutableCopy];
            [self.tableView reloadData];
       
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

@end
