//
//  CusChartViewController.m
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

#import "CusPriceViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "PCPieChart.h"
#import "ServeKindView.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "ChartModel.h"
#import "DEFINE.h"

@interface CusPriceViewController ()
{
    PCPieChart *pieChart ;
    
    UIView *chartView;
    
    UIButton *serverBtn;
    UIButton *productBtn;
    
    AFHTTPRequestOperation *_requestCusCharOperation;
    
    NSMutableArray *chartData;
    NSMutableArray *colorData;
    
    BOOL isSelectServer;
}

@end

@implementation CusPriceViewController

- (void)initPieChartView
{
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:[NSString stringWithFormat:@"消费倾向分析(%@)", ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_Name]];
    [self.view addSubview:navigationView];
    
    //wugang->
    //self.view.backgroundColor = kBackgroundColor;
    self.view.backgroundColor = kColor_Background_View;
    //-<wugang
    
    
    chartView = [[UIView alloc]initWithFrame:CGRectMake(5, navigationView.frame.origin.y + navigationView.frame.size.height + 5 , kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height -(navigationView.frame.origin.y + navigationView.frame.size.height + 5) - 40 - 5 - 64 - 5)];
    chartView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:chartView];
    
    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, chartView.frame.size.width, 40)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.textColor = KColor_Blue;
    [lab setText:@"消费价格分析图表"];
    lab.backgroundColor = [UIColor whiteColor];
    UIView *viewLine = [[UIView alloc]initWithFrame:CGRectMake(5,   40.5, kSCREN_BOUNDS.size.width - 10 , 0.5)];
    viewLine.backgroundColor = kLineViewColor;
    [chartView addSubview:viewLine];
    [chartView addSubview:lab];
    
    
    UIView *btnView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREN_BOUNDS.size.height - 40 - 64 - 5 , kSCREN_BOUNDS.size.width , 40)];
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
    
    
    if (isSelectServer) {
        [serverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //wugang->
        //serverBtn.backgroundColor = kBtn_BuleColor;
        serverBtn.backgroundColor = kColor_ButtonBlue;
        //<-wugang
        [productBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
        productBtn.backgroundColor = kBtn_WitheColor;
    }else{
        [productBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //wugang->
        //productBtn.backgroundColor = kBtn_BuleColor;
        productBtn.backgroundColor = kColor_ButtonBlue;
        //<-wugang
        [serverBtn setTitleColor:kColor_ButtonBlue forState:UIControlStateNormal];
        serverBtn.backgroundColor = kBtn_WitheColor;
    }
    
    int height = [self.view bounds].size.width/3*2.; // 220;
    int width = [self.view bounds].size.width; //320;
    pieChart = [[PCPieChart alloc] initWithFrame:CGRectMake(5,41,width - 5,height)];
    [pieChart setShowArrow:NO];
    [pieChart setSameColorLabel:NO];
    [pieChart setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
    [pieChart setDiameter:width / 2];
    [chartView addSubview:pieChart];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    chartData = [NSMutableArray array];
    colorData = [NSMutableArray  arrayWithObjects:ChartColor_1,ChartColor_2,ChartColor_3,ChartColor_4,ChartColor_5,ChartColor_6,ChartColor_7,ChartColor_8,ChartColor_9,ChartColor_10,ChartColor_11, nil];
    
    isSelectServer = YES;
    [self requestWithObjectType:0];
    
}

- (void)readData
{
    for (UIView *vi in self.view.subviews) {
        [vi removeFromSuperview];
    }
    [self initPieChartView];
    
    NSMutableArray *components = [NSMutableArray array];
    double  total = [self totalValue];
    double percentageValue = [self percentageValue];
    
    if (chartData.count <= 10) {
        for (int i =0 ; i < chartData.count; i++) {
            ChartModel *chart = chartData[i];
            double value  = (chart.ObjectCount.doubleValue  / total) *100;
            PCPieComponent *component = [PCPieComponent pieComponentWithTitle:nil value:value];
            [component  setColour:colorData[i]];
            [components addObject:component];
            ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake((i % 2) * kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2), kKindView_Width, kKindView_Height)];
            
            NSString  *temp = [NSString stringWithFormat:@"%.2lf",value];
            [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%@%%",temp] nameTitle:chart.ObjectName viewColor: colorData[i] value:1];
            [chartView addSubview:kindView];
        }
        [pieChart setComponents:components];
    }
    if (chartData.count > 10) {
        for (int i =0 ; i < chartData.count; i++) {
            ChartModel *chart = chartData[i];
            double value  = (chart.ObjectCount.doubleValue  / total) * 100;
            if (i < 11) {
                if (i == 10) { // 其他
                    double  otherValue = 0;
                    if (percentageValue >= 0) {
                        otherValue = (1 - percentageValue) * 100;
                    }
                    if (otherValue >= 0) {
                        PCPieComponent *component = [PCPieComponent pieComponentWithTitle:nil value:otherValue];
                        [component setColour:colorData[i]];
                        [components addObject:component];
                        
                        ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake((i % 2) * kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2) + 5, kKindView_Width, kKindView_Height)];
                        [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%.2lf%%",otherValue] nameTitle:@"其他" viewColor: colorData[i]value:1];
                        [chartView addSubview:kindView];
                    }
                }else{  // 前十种
                    PCPieComponent *component = [PCPieComponent pieComponentWithTitle:nil value:value];
                    [component setColour:colorData[i]];
                    [components addObject:component];
                    ServeKindView *kindView = [[ServeKindView alloc]initWithFrame:CGRectMake((i % 2) * kKindView_Width , (pieChart.frame.origin.y + pieChart.frame.size.height ) + kKindView_Height *(i / 2) + 5, kKindView_Width, kKindView_Height)];
                    
                    [kindView kindViewWithPercentageTitle:[NSString stringWithFormat:@"%.2lf%%",value] nameTitle:chart.ObjectName viewColor:colorData[i] value:1];
                    [chartView addSubview:kindView];
                }
            }
        }
        [pieChart setComponents:components];
    }
}
-(void)requestWithObjectType:(NSInteger)ObjectType
{
    CustomerDoc *customer = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected;
    [SVProgressHUD showWithStatus:@"Loading..."];
    if (chartData) {
        [chartData removeAllObjects];
    } else {
        chartData = [NSMutableArray array];
    }
    
    NSInteger ExtractItemType = 2;
    NSInteger MonthCount = 0;
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"ObjectType\":%ld,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"MonthCount\":%ld,\"ExtractItemType\":%ld}", (long)customer.cus_ID,  (long)ObjectType,@"",@"",(long)MonthCount,(long)ExtractItemType];
    
    _requestCusCharOperation = [[GPBHTTPClient sharedClient]requestUrlPath:@"Statistics/GetDataStatisticsList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
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
                [chartData addObject:chart];
            }
            [self readData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark - 计算

- (double)totalValue
{
    double total = 0;
    for (int i =0 ; i < chartData.count; i++) {
        ChartModel *chart = chartData[i];
        total += chart.ObjectCount.doubleValue;
    }
    return total;
}
- (double)percentageValue
{
    double percentage = 0;
    double total = [self totalValue];
    for (int i =0 ; i < chartData.count; i++) {
        ChartModel *chart = chartData[i];
        if (i < 10 ) {
            percentage += chart.ObjectCount.doubleValue / total;
        }
    }
    if (percentage > 1) {
        return 1;
    }
    return percentage;
}

- (void)serverBtnClick:(UIButton *)sender
{
    
    isSelectServer = YES;
    
    [self requestWithObjectType:0];
}
- (void)productBtnClick:(UIButton *)sender
{
    isSelectServer = NO;
    [self requestWithObjectType:1];
}

@end
