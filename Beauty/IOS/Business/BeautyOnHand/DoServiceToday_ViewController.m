//
//  DoServiceToday_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/9/14.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "DoServiceToday_ViewController.h"
#import "NavigationView.h"
#import "DoServiceTodayTableViewCell.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "OrderDoc.h"
#import "OrderDetailViewController.h"
#import "BusinessTabbarViewController.h"
#import "ServiceFilterViewController.h"
#import "MJExtension.h"
#import "ServicePara.h"
#import "ServiceRes.h"
#import "TGListRes.h"
#import "AppDelegate.h"
#import "CustomerDoc.h"
#import "NSDate+Convert.h"
#import "MJRefresh.h"

const NSString *kServiceParaIdentifier = @"kServicePara";

@interface DoServiceToday_ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    ServiceRes *_serviceRes;
    NavigationView *_navigationView;
}
@property (nonatomic,strong)UITableView * serviceTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *requestListOperation;
@property (strong ,nonatomic) BusinessTabbarViewController * tabbarViewController;
@property (nonatomic,strong)NSMutableArray * serviceMuArr;

@property (nonatomic,strong)ServicePara *servicePara;

@end

@implementation DoServiceToday_ViewController
@synthesize serviceMuArr;

- (void)addGestureRecognizer
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:swipeRight];
}
- (void) tappedRightButton:(id)sender

{
    
    NSUInteger selectedIndex = [_tabbarViewController selectedIndex];
    
    
    
    NSArray *aryViewController = _tabbarViewController.viewControllers;
    
    if (selectedIndex < aryViewController.count - 1) {
        
        UIView *fromView = [_tabbarViewController.selectedViewController view];
        
        UIView *toView = [[_tabbarViewController.viewControllers objectAtIndex:selectedIndex + 1] view];
        
        [UIView transitionFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            
            if (finished) {
                
                [_tabbarViewController setSelectedIndex:selectedIndex + 1];
            }
        }];
    }
    
}


- (void) tappedLeftButton:(id)sender

{
    NSUInteger selectedIndex = [_tabbarViewController selectedIndex];
    
    if (selectedIndex > 0) {
        
        UIView *fromView = [_tabbarViewController.selectedViewController view];
        
        UIView *toView = [[_tabbarViewController.viewControllers objectAtIndex:selectedIndex - 1] view];
        
        [UIView transitionFromView:fromView toView:toView duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            
            if (finished) {
                
                [_tabbarViewController setSelectedIndex:selectedIndex - 1];
            }
            
        }];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addGestureRecognizer];
    [self initTableView];
    [self initData];
    [self headerRefresh];
}
-(void)initTableView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ((IOS7 || IOS8)){
        self.edgesForExtendedLayout= UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"服务"];
    [self.view addSubview:_navigationView];
    [_navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterButton:)];
    _navigationView.tag = 10;
    [self.view addSubview:_navigationView];
    
    
    _serviceTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, (kORIGIN_Y + 5.0f+HEIGHT_NAVIGATION_VIEW), kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 49)];
    _serviceTableView.showsHorizontalScrollIndicator = NO;
    _serviceTableView.showsVerticalScrollIndicator = NO;
    _serviceTableView.backgroundColor = [UIColor clearColor];
    _serviceTableView.separatorColor = kTableView_LineColor;
    _serviceTableView.autoresizingMask = UIViewAutoresizingNone;
    _serviceTableView.delegate = self;
    _serviceTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_serviceTableView setTableFooterView:view];
    [self.view addSubview:_serviceTableView];
    
    if ((IOS7 || IOS8)) {
        _serviceTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [_serviceTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [_serviceTableView addFooterWithTarget:self action:@selector(footerRefresh)];
}


- (void)initData
{
    serviceMuArr = [[NSMutableArray alloc] init];
    _servicePara = [[ServicePara alloc]init];
}

#pragma mark -  筛选
- (void)filterButton:(id)sender
{
    ServiceFilterViewController *filterVC = [[ServiceFilterViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    filterVC.filterBlock = ^(ServicePara *serPara){
        if (kMenu_Type == 0){
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:serPara];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%@ACCOUNT-%ld-BRANCH-%ld",kServiceParaIdentifier,(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
        }
        [weakSelf convertAttributeWithServiceRes:serPara];
        [weakSelf headerRefresh];
    };
    filterVC.goBackBlock = ^(){
        if (_servicePara.StartTime.length > 0 && _servicePara.EndTime.length > 0) {
            _servicePara.FilterByTimeFlag = 1;
        }else{
            _servicePara.FilterByTimeFlag = 0;
        }
    };
    NSData *data =[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@ACCOUNT-%ld-BRANCH-%ld",kServiceParaIdentifier,(long)ACC_ACCOUNTID,(long)ACC_BRANCHID]];
    ServicePara *serPara = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self convertAttributeWithServiceRes:serPara];
    filterVC.servicePara = _servicePara;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:filterVC];
    navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:navigationController animated:YES completion:^{}];
}
- (void)convertAttributeWithServiceRes:(ServicePara *)serPara
{
    if (serPara) {
        if (serPara.CustomerName == nil) {
            serPara.CustomerName = @"全部";
        }
        _servicePara.ProductType = serPara.ProductType;
        _servicePara.Status = serPara.Status;
        _servicePara.CustomerID = serPara.CustomerID;
        _servicePara.CustomerName = serPara.CustomerName;
        _servicePara.ServicePIC = serPara.ServicePIC;
        _servicePara.ServicePICName = serPara.ServicePICName;
        _servicePara.StartTime = serPara.StartTime;
        _servicePara.EndTime =serPara.EndTime;
        _servicePara.FilterByTimeFlag =serPara.FilterByTimeFlag;        
    }else{
        //默认没有时间
        _servicePara.StartTime = @"";
        _servicePara.EndTime = @"";
        _servicePara.CustomerID = 0;
        _servicePara.CustomerName = @"全部";
    }
}
#pragma mark -refresh
- (void)headerRefresh
{
    [serviceMuArr removeAllObjects];
    if (self.serviceTableView.footerHidden == YES) {
        self.serviceTableView.footerHidden = NO;
    }
    _servicePara.PageIndex = 1;
    _servicePara.PageSize = 10;
    [self requestList];
}

- (void)footerRefresh
{
    if (serviceMuArr.count == _serviceRes.RecordCount) {
        [self.serviceTableView footerEndRefreshing];
        [SVProgressHUD showErrorWithStatus2:@"没有更多数据了" touchEventHandle:^{}];
        self.serviceTableView.footerHidden = YES;
    } else {
        if (_servicePara.PageIndex < _serviceRes.PageCount) {
            _servicePara.PageIndex ++ ;
        }
        if (serviceMuArr.count > 0) {
            TGListRes *tGListRes = serviceMuArr.firstObject;
            _servicePara.TGStartTime = tGListRes.TGStartTime;
        }
        [self requestList];
    }
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return serviceMuArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identify = [NSString stringWithFormat:@"cell_%@",indexPath];
    
    DoServiceTodayTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[DoServiceTodayTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (62-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    TGListRes *tGListRes ;
    if (serviceMuArr.count > 0) {
       tGListRes = [serviceMuArr objectAtIndex:indexPath.row];
    }
    NSString * str = @"";
    if (tGListRes.ProductType == 0) {
        if (tGListRes.TotalCount ==0 ) {
            str = @"不限次";
        }else
        {
            str = [NSString stringWithFormat:@"共%ld次",(long)tGListRes.TotalCount];
        }
        cell.countLabel.text = [NSString stringWithFormat:@"服务%ld次/%@",(long)tGListRes.FinishedCount,str];
    }else
    {
        str = [NSString stringWithFormat:@"共%ld件",(long)tGListRes.TotalCount];
        cell.countLabel.text = [NSString stringWithFormat:@"交付%ld件/%@",(long)tGListRes.FinishedCount,str];
    }
    
    cell.productNameLabel.text = tGListRes.ProductName;
    if (tGListRes.TGStartTime && tGListRes.TGStartTime.length > 16) {
        cell.dateLable.text = [tGListRes.TGStartTime substringToIndex:16];
    }
    cell.customerNameLabel.text = tGListRes.CustomerName;
    cell.stateLabel.text = [NSString stringWithFormat:@"%@|%@",tGListRes.StatusStr,tGListRes.PaymentStatusStr];
    
//    NSDictionary * serviceDic = [serviceMuArr objectAtIndex:indexPath.row];
    //    OrderDoc *orderDoc = [[OrderDoc alloc] init];
    //    [orderDoc setOrder_TGStatus:[[serviceDic objectForKey:@"Status"]intValue]];
    //    [orderDoc setOrder_Ispaid:[[serviceDic objectForKey:@"PaymentStatus"]intValue]];
//    NSDictionary * serviceDic = [serviceMuArr objectAtIndex:indexPath.row];
    
//    OrderDoc *orderDoc = [[OrderDoc alloc] init];
//    [orderDoc setOrder_TGStatus:[[serviceDic objectForKey:@"Status"]intValue]];
//    [orderDoc setOrder_Ispaid:[[serviceDic objectForKey:@"PaymentStatus"]intValue]];
//    
//    NSString * str = @"";
//    if ([[serviceDic objectForKey:@"ProductType"]intValue] ==0) {
//        if ([[serviceDic objectForKey:@"TotalCount"]intValue] ==0 ) {
//            str = @"不限次";
//        }else
//        {
//            str = [NSString stringWithFormat:@"共%d次",[[serviceDic objectForKey:@"TotalCount"]intValue]];
//        }
//         cell.countLabel.text = [NSString stringWithFormat:@"服务%d次/%@",[[serviceDic objectForKey:@"FinishedCount"]intValue],str];
//    }else
//    {
//        str = [NSString stringWithFormat:@"共%d件",[[serviceDic objectForKey:@"TotalCount"]intValue]];
//         cell.countLabel.text = [NSString stringWithFormat:@"交付%d件/%@",[[serviceDic objectForKey:@"FinishedCount"]intValue],str];
//    }
//    
//    cell.productNameLabel.text = [serviceDic objectForKey:@"ProductName"];
//    cell.dateLable.text = [serviceDic objectForKey:@"TGStartTime"];
//    cell.customerNameLabel.text = [serviceDic objectForKey:@"CustomerName"];
//    cell.stateLabel.text = [NSString stringWithFormat:@"%@|%@",orderDoc.order_TGStatusStr,orderDoc.order_IspaidStr];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    OrderDetailViewController *orderDetail = [sb instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    TGListRes *tGListRes = [serviceMuArr objectAtIndex:indexPath.row];
        orderDetail.orderID = tGListRes.OrderID;
        orderDetail.productType = tGListRes.ProductType;
        orderDetail.objectID  = tGListRes.OrderObjectID;

//   NSDictionary * serviceDic = [serviceMuArr objectAtIndex:indexPath.row];
//    orderDetail.orderID = [[serviceDic objectForKey:@"OrderID"] integerValue];
//    orderDetail.productType = [[serviceDic objectForKey:@"ProductType"] integerValue];;
//    orderDetail.objectID  = [[serviceDic objectForKey:@"OrderObjectID"] integerValue];
    [self.navigationController pushViewController:orderDetail animated:YES];
}

#pragma mark - 接口


-(void)requestList
{
//    {"ServicePIC":12163,"ProductType": -1,"Status": 0,"FilterByTimeFlag":0,"StartTime":"2012-12-12","EndTime":"2012-12-12","PageIndex":1,"PageSize":10,"CustomerID":0}
       
    NSDictionary * par = @{@"ServicePIC":@(_servicePara.ServicePIC),
                           @"ProductType":@(_servicePara.ProductType),
                           @"Status":@(_servicePara.Status),
                           @"FilterByTimeFlag":@(_servicePara.FilterByTimeFlag),
                           @"StartTime":_servicePara.StartTime,
                           @"EndTime":_servicePara.EndTime,
                           @"PageIndex":@(_servicePara.PageIndex),
                           @"PageSize":@(_servicePara.PageSize),
                           @"CustomerID":@(_servicePara.CustomerID),
                            @"TGStartTime":_servicePara.TGStartTime,
                           };
    
    _requestListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Order/GetMyTodayDoTGList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {

            NSMutableArray *tempArrs = [NSMutableArray array];
            _serviceRes = [ServiceRes mj_objectWithKeyValues:data];
            [tempArrs addObjectsFromArray:_serviceRes.TGList];
            NSRange range = NSMakeRange([serviceMuArr count], [tempArrs count]);
            NSIndexSet *index_set = [NSIndexSet indexSetWithIndexesInRange:range];
            if (tempArrs.count > 0) {
                [serviceMuArr insertObjects:tempArrs atIndexes:index_set];
            }
            if (_serviceRes.PageCount > 0) {
                [_navigationView  setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)_servicePara.PageIndex,(long)_serviceRes.PageCount]];
            }else{
                [_navigationView  setSecondLabelText:@""];
            }
            [_serviceTableView footerEndRefreshing];
            [_serviceTableView headerEndRefreshing];
            [_serviceTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [_serviceTableView footerEndRefreshing];
            [_serviceTableView headerEndRefreshing];
         [SVProgressHUD showSuccessWithStatus2:error duration:3 touchEventHandle:^{
                [SVProgressHUD dismiss];
            }];
        }];
    } failure:^(NSError *error) {
        [_serviceTableView footerEndRefreshing];
        [_serviceTableView headerEndRefreshing];
    }];
}



@end
