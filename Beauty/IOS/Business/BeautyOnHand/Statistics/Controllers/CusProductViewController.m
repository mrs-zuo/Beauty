//
//  CusProductViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by Bizapper VM MacOS  on 15/11/24.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//
#define kBtn_WitheColor   [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1]

#define kBtn_BuleColor   [UIColor colorWithRed:2.0 /225.0 green:87.0 /255.0 blue:155.0/255 alpha:1]
#define kBackgroundColor [UIColor colorWithRed:208.0/255.0 green:235.0/255.0 blue:245.0/255 alpha:1]

#define kLineViewColor [UIColor colorWithRed:196.0/255.0 green:230.0/255.0 blue:244.0/255 alpha:1]

#define kKindView_Width kSCREN_BOUNDS.size.width / 2
#define kKindView_Height 20

#import "CusProductViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "CusProductTableViewCell.h"

@interface CusProductViewController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *productTableView;
    NSMutableArray *productData;
    AFHTTPRequestOperation *_requestProductOperation;
    
    UIButton *serverBtn;
    UIButton *productBtn;
    
    BOOL isSelectServer;
}
@end

@implementation CusProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"消费倾向分析(%@)", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name]];
  [self.view addSubview:navigationView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height, self.view.frame.size.width - 10, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"消费产品排行榜"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [self.view addSubview:viewLine];
    [self.view addSubview:lab];
    
    productTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if ((IOS7 || IOS8)) {
        productTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 41, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f - 40.0f - 41  - 5);
    } else {
        productTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f  - 40.0f - 41  - 5);
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        productTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height + 6, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f - 40.0f - 41  - 5);
    }
    productTableView.delegate = self;
    productTableView.dataSource = self;
    productTableView.separatorColor = kTableView_LineColor;
    productTableView.backgroundView = nil;
    productTableView.backgroundColor = nil;
    
    if ((IOS7 || IOS8)) productTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:productTableView];

    
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width  , 40)];
    [self.view addSubview:btnView];
    
    serverBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    serverBtn.frame =  CGRectMake(5, 0 , btnView.frame.size.width  / 2 - 5, 40);
    [serverBtn setTitle:@"服务" forState:UIControlStateNormal];
    [serverBtn addTarget:self action:@selector(serverBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:serverBtn];
    
    
    productBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    productBtn.frame =  CGRectMake(serverBtn.frame.origin.x +serverBtn.frame.size.width, 0 , btnView.frame.size.width  / 2 - 5, 40);
    [productBtn setTitle:@"商品" forState:UIControlStateNormal];
    
    [productBtn addTarget:self action:@selector(productBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnView addSubview:productBtn];
    
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_BuleColor;
    [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_WitheColor;
    
     productData = [NSMutableArray array];
    isSelectServer = YES;
    
    [self requestWithObjectType:0];
    
}
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (productData) {
        [productData removeAllObjects];
    } else {
        productData = [NSMutableArray array];
    }
    
    NSInteger ExtractItemType = 1;
    NSInteger MonthCount = 0;
    
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ObjectType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"MonthCount\":%ld,\"ExtractItemType\":%ld}", (long)customer.cus_ID,  (long)ObjectType,@"",@"",(long)MonthCount,(long)ExtractItemType];
    _requestProductOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"Statistics/GetDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSArray *arr = data;
            for (int i = 0; i < arr.count; i++) {
                NSDictionary *dic = arr[i];
                ChartModel *chart = [[ChartModel alloc]init];
                if ([dic objectForKey:@"ObjectCount"]) {
                    chart.ObjectCount = [dic objectForKey:@"ObjectCount"];
                }
                if ([dic objectForKey:@"ObjectName"]) {
                    chart.ObjectName = [dic objectForKey:@"ObjectName"];
                }
                if ([dic objectForKey:@"ConsumeAmout"]) {
                    chart.ConsumeAmout = [dic objectForKey:@"ConsumeAmout"];
                }
                if ([dic objectForKey:@"RechargeAmout"]) {
                    chart.RechargeAmout = [dic objectForKey:@"RechargeAmout"];
                }
                if ([dic objectForKey:@"TotalAmout"]) {
                    chart.TotalAmout = [dic objectForKey:@"TotalAmout"];
                }
                [productData addObject:chart];
            }
            [productTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

#pragma mark - 按钮事件
- (void)serverBtnClick:(UIButton *)sender
{
    isSelectServer = YES;
    [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_BuleColor;
    [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:0];
}
- (void)productBtnClick:(UIButton *)sender
{
    isSelectServer = NO;
    [productBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    productBtn.backgroundColor = kBtn_BuleColor;
    [serverBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
    serverBtn.backgroundColor = kBtn_WitheColor;
    
    [self requestWithObjectType:1];
}


#pragma mark - tableViewDelegate && dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static  NSString *identifier = @"Cell";

    CusProductTableViewCell *cell = (CusProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CusProductTableViewCell" owner:self options:nil] objectAtIndex:0];
    }
    cell.indexPath = indexPath;
    cell.isSelectServer = isSelectServer;
    cell.data = productData[indexPath.row];
    return cell;
}


@end
