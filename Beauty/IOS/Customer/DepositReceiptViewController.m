//
//  DepositReceiptViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/27.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "DepositReceiptViewController.h"
#import "ServiceOneViewController.h"
#import "DepositReceiptTableViewCell.h"
#import "AppointmentBuyModel.h"
#import "AppointmenCreat_ViewController.h"
#import "ServiceDetailViewController.h"
#import "OrderDetailAboutServiceViewController.h"
#import "OrderDoc.h"
@interface DepositReceiptViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) AFHTTPRequestOperation *getAppointmentDepositReceiptOperation;
@property (strong, nonatomic) NSMutableArray *theDepositArray;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString *appointment;
@property (strong, nonatomic) OrderDoc *orderDoc_Selected;

@end

@implementation DepositReceiptViewController
@synthesize tableView;
@synthesize theDepositArray;
@synthesize getAppointmentDepositReceiptOperation;


- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    [self requestAppointmentDepositReceiptOperation];
    
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
    tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height -  44 - 49 + 20  - 5);
    [self.view addSubview:tableView];
    
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:footView];
    
    [self.tableView registerClass:[DepositReceiptTableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,  tableView.frame.origin.y + tableView.frame.size.height + 5, kSCREN_BOUNDS.size.width, 49.0f)];
    bottomView.backgroundColor = kColor_White;
    [self.view addSubview:bottomView];
    
    
    UIButton *appointmentCancel = [UIButton buttonWithTitle:@"去看看其他服务" target:self selector:@selector(buttonClickAppointment) frame:CGRectMake(0,3, kSCREN_BOUNDS.size.width - 10,49) backgroundImg:nil  highlightedImage:nil];
    appointmentCancel.titleLabel.font=kNormalFont_14;
    appointmentCancel.backgroundColor  = kColor_White;
    [bottomView addSubview:appointmentCancel];
    [appointmentCancel setTitleColor:kColor_Black forState:UIControlStateNormal];
}
- (void)buttonClickAppointment
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;
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
    return theDepositArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"depositCell_%@",indexPath];
    DepositReceiptTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[DepositReceiptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.appointButton.tag = indexPath.row + 3000;
        [cell.appointButton addTarget:self action:@selector(sumbit:) forControlEvents:UIControlEventTouchUpInside];
    }

    cell.nameLabel.text = [[theDepositArray objectAtIndex:indexPath.row] valueForKey:@"productName"];
    cell.dateLabel.text = [[theDepositArray objectAtIndex:indexPath.row] valueForKey:@"tGEndTime"];
    cell.accounNameLabel.text = [[theDepositArray objectAtIndex:indexPath.row] valueForKey:@"responsiblePersonName"];
    cell.numberLabel.text = [[theDepositArray objectAtIndex:indexPath.row] valueForKey:@"productTypeStatus"];
    return cell;
}
-(void)sumbit:(UIButton *)button
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;

    OrderDoc *model = [theDepositArray objectAtIndex:button.tag - 3000];
    AppointmenCreat_ViewController *create = [[AppointmenCreat_ViewController alloc] init];
    create.BranchID = _BranchID;
    create.branchName = _BranchName;
    create.serviceName =model.productName;
    create.ReservedOrderType = 1;
    create.taskSourceType = 3;
    create.orderID = model.orderID;
    create.serviceID = model.orderObjectID.integerValue;
    
    

    [self.navigationController pushViewController:create animated:YES];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_ThirdCellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        _orderDoc_Selected = [theDepositArray objectAtIndex:indexPath.row];
    
    self.parentViewController.hidesBottomBarWhenPushed = YES;

    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[sb instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
    serve.orderDoc = _orderDoc_Selected;
    [self.navigationController pushViewController:serve animated:YES];
}
- (void)requestAppointmentDepositReceiptOperation
{
    [SVProgressHUD showErrorWithStatus:@"Loading"];
    NSDictionary *para = @{@"BranchID":@(_BranchID),
                           @"ProductType":@0};
    getAppointmentDepositReceiptOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/GetUnfinishOrder" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            theDepositArray = [NSMutableArray new];
            for (NSDictionary  *dict  in  data) {
                OrderDoc *model =[[OrderDoc alloc] init];
                model.orderID = [[dict objectForKey:@"OrderID"] longLongValue];
                model.productName = [dict objectForKey:@"ProductName"];
                model.tGEndTime =  [dict objectForKey:@"OrderTime"];
                model.responsiblePersonName = [dict objectForKey:@"ResponsiblePersonName"];
                model.finisHedCount = [[dict objectForKey:@"TGFinishedCount"] integerValue];
                model.totalCount = [[dict objectForKey:@"TGTotalCount"] integerValue];
                model.productType = 0;
                model.branchID = [[dict objectForKey:@"BranchID"] integerValue];
                model.order_ObjectID =  [[dict objectForKey:@"OrderObjectID"] integerValue];
                model.orderObjectID = [dict objectForKey:@"OrderObjectID"];
                [theDepositArray addObject:model];

            }
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}


@end
