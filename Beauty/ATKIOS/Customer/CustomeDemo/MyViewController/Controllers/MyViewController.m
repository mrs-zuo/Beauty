//
//  MyViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/12/18.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//
#define KMyTopView_Height 180


#import "MyViewController.h"
#import "MyTopView.h"
#import "SetViewController.h"
#import "CollectListViewController.h"
#import "AppointmentList_ViewController.h"
#import "OrderConfirmViewController.h"
#import "OrderPayViewController.h"
#import "AppraiseViewController.h"
#import "OrderViewController.h"
#import "RechargeViewController.h"
#import "PhotosListViewController.h"
#import "CustomerInfoRes.h"
#import "GPCHTTPClient.h"
#import "RecordListViewController.h"
#import "GPCHTTPClient.h"
#import "OrderListViewController.h"
#import "BeautyRecordViewController.h"

@interface MyViewController () <UITableViewDataSource,UITableViewDelegate,MyTopViewDelegate,CLLocationManagerDelegate>
{
    UIScrollView *scrollView;
    MyTopView *topView;
    UITableView *myTableView;
}

@property (nonatomic,strong) NSArray *myDataTitle;
@property (nonatomic,strong) NSArray *myDataImgName;

@property (weak, nonatomic) AFHTTPRequestOperation *GetCustomerInfoOperation;
@property (weak  , nonatomic) AFHTTPRequestOperation *getTwoDimensionalCodeOperation;

@property (nonatomic,strong) NSMutableArray *customerInfoList;
@property (copy  , nonatomic) NSString *codeUrlString;


@end

@implementation MyViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_GetCustomerInfoOperation || [_GetCustomerInfoOperation isExecuting]) {
        [_GetCustomerInfoOperation cancel];
        _GetCustomerInfoOperation = nil;
    }
    if (_getTwoDimensionalCodeOperation || [_getTwoDimensionalCodeOperation isExecuting]) {
        [_getTwoDimensionalCodeOperation cancel];
        _getTwoDimensionalCodeOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kToolBar_Height + 20)];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = kDefaultBackgroundColor;
    [self.view addSubview:scrollView];
    _customerInfoList = [NSMutableArray array];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = NO;
    self.title = @"我的";
    [super viewWillAppear:animated];
    
    [self requestTwoDimensionalCode];
    [self requestGetCustomerInfo];
  
}

- (void)initView
{
    
    if (!topView) {
        topView = (MyTopView *)[[[NSBundle mainBundle]loadNibNamed:@"MyTopView" owner:self options:nil] objectAtIndex:0];
        topView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width, KMyTopView_Height);
        topView.delegate = self;
        topView.data = self.customerInfoList;
        topView.codeUrlString = _codeUrlString;
        [scrollView addSubview:topView];
    }else{
        topView.data = self.customerInfoList;
        topView.codeUrlString = _codeUrlString;
    }
  
    
    _myDataTitle = @[@"e账户",@"美丽记录",@"专业",@"收藏",@"设置"];
    _myDataImgName = @[@"myECard",@"myPhoto",@"mySpecialty",@"myCollect",@"mySetting"];

    if (!myTableView) {
        myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,topView.frame.size.height + 10, kSCREN_BOUNDS.size.width, (kTableView_DefaultCellHeight * _myDataTitle.count)) style:UITableViewStylePlain];
        myTableView.backgroundColor = [UIColor blueColor];
        myTableView.separatorColor = kTableView_LineColor;
        myTableView.backgroundColor = kColor_Clear;
        myTableView.backgroundView = nil;
        myTableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);
        myTableView.showsHorizontalScrollIndicator = NO;
        myTableView.showsVerticalScrollIndicator = NO;
        myTableView.delegate = self;
        myTableView.dataSource = self;
        myTableView.separatorInset = UIEdgeInsetsZero;
        myTableView.scrollEnabled = NO;
        [scrollView addSubview:myTableView];
    }
    scrollView.contentSize = CGSizeMake(kSCREN_BOUNDS.size.width, topView.frame.size.height + 10 + myTableView.frame.size.height + 10);
    
    NSNumber *longitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"longitude"];
    NSNumber *latitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"latitude"];
        if ([CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)) {
        if (longitude.floatValue != 0 && latitude.floatValue != 0) {
            [self requestGetCustomerLocation];
        }
    }
}

#pragma mark --   UITableViewDelegate && datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _myDataTitle.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier =@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Identifier];
    }
    cell.imageView.image = [UIImage imageNamed:_myDataImgName[indexPath.row]];
    cell.textLabel.text = _myDataTitle[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryView.backgroundColor = kColor_TitlePink;
    cell.textLabel.font = kNormalFont_14;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self enterPage:indexPath];
}
#pragma mark - 进入不同的页面

- (void)enterPage:(NSIndexPath *)indexPath
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    switch (indexPath.row) {
        case 0: // e账户
        {
            RechargeViewController *RechargeVC = [board instantiateViewControllerWithIdentifier:@"RechargeNew"];
            [self.navigationController pushViewController:RechargeVC animated:YES];
        }
            break;
        case 1: //美丽记录
        {
            BeautyRecordViewController *beautyVC = [[BeautyRecordViewController alloc]init];
            [self.navigationController pushViewController:beautyVC animated:YES];
        }
            break;
        case 2: //专业
        {
            RecordListViewController * RecordListVC = [board instantiateViewControllerWithIdentifier:@"RecordListViewController"];
            [self.navigationController pushViewController:RecordListVC animated:YES];
        }
            break;
        case 3: //收藏
        {
            CollectListViewController *CollectListVC = [board instantiateViewControllerWithIdentifier:@"CollectList"];
            [self.navigationController pushViewController:CollectListVC animated:YES];
        }
            break;
        case 4: // 设置
        {
            SetViewController *SetVC = [board instantiateViewControllerWithIdentifier:@"Set"];
            [self.navigationController pushViewController:SetVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    self.hidesBottomBarWhenPushed = NO;
}
#pragma mark - MyTopView代理
-(void)MyTopView:(MyTopView *)myTopView button:(UIButton *)butt
{
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.hidesBottomBarWhenPushed = YES;
    switch (butt.tag) {
        case 1: //全部订单
        {           
            OrderListViewController *orderListVC = [board instantiateViewControllerWithIdentifier:@"OrderListViewController"];
            orderListVC.requestType = - 1; //默认全部
            orderListVC.requestStatus = -1; //默认全部
            orderListVC.requestIsPaid = - 1; //默认全部；
            [self.navigationController pushViewController:orderListVC animated:YES];
        }
            break;
        case 2: //待付款
        {
            OrderPayViewController *OrderPayVC = [board instantiateViewControllerWithIdentifier:@"OrderPayController"];
            [self.navigationController pushViewController:OrderPayVC animated:YES];
        }
            break;
        case 3: //待确认
        {
            OrderConfirmViewController *OrderConfirmVC = [board instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
            [self.navigationController pushViewController:OrderConfirmVC animated:YES];
        }
            break;
        case 4: //待评价
        {
            AppraiseViewController *AppraiseVC = [board instantiateViewControllerWithIdentifier:@"AppraiseController"];
            [self.navigationController pushViewController:AppraiseVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    self.hidesBottomBarWhenPushed = NO;

}

#pragma mark - 接口

- (void)requestGetCustomerInfo
{
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    NSDictionary *para = nil;
    _GetCustomerInfoOperation = [[GPCHTTPClient sharedClient]requestUrlPath:@"/Customer/GetCustomerInfo" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [self.customerInfoList removeAllObjects];
            CustomerInfoRes * cusinfoRes = [[CustomerInfoRes alloc]initWithDict:data];
            [self.customerInfoList addObject:cusinfoRes];
            [self initView];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        
    }];
}
- (void)requestGetCustomerLocation
{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    NSNumber *longitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"longitude"];
    NSNumber *latitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"latitude"];
    NSDictionary *para = @{@"Longitude":longitude,
             @"Latitude":latitude,
             };
        _GetCustomerInfoOperation = [[GPCHTTPClient sharedClient]requestUrlPath:@"/WebUtility/CustomerLocation" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];

            
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        
    }];
}

-(void)requestTwoDimensionalCode
{
    NSDictionary *para = @{@"Code":@(CUS_CUSTOMERID),
                           @"Type":@0,
                           @"CompanyCode":CUS_COMPANYCODE,
                           @"QRCodeSize":@9};
    
    _getTwoDimensionalCodeOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/WebUtility/getQRCode"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (data)
                _codeUrlString = data;
            else
                [SVProgressHUD showErrorWithStatus2:@"获取二维码失败！"];
        } failure:^(NSInteger code, NSString *error) {
            
        }];

    } failure:^(NSError *error) {
        
    }];
}


@end
