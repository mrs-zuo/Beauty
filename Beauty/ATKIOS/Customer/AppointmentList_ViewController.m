//
//  AppointmentList_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

const CGFloat kCell_Height = 100;

#import "AppointmentList_ViewController.h"
#import "AppointmentDoc.h"
#import "AppointmentListTableViewCell.h"
#import "AppointmentDetail_ViewController.h"
#import "AppointmenCreat_ViewController.h"
#import "AppointmentNewViewController.h"
#import "AppointmentStoreModel.h"
#import "WMPageController.h"
#import "RecommendViewController.h"
#import "BuyViewController.h"
#import "DepositReceiptViewController.h"

@interface AppointmentList_ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *getAppointmentList;
@property (weak, nonatomic) AFHTTPRequestOperation *appointmentListOperation;
@property (strong ,nonatomic) UITableView * myTableView;
@property (assign, nonatomic) NSInteger recordCount;
@property (strong ,nonatomic) NSMutableArray * appointmentListMuArr;
@property (assign ,nonatomic) NSInteger status;
@property (strong ,nonatomic) UIView * lineView;
@property (strong, nonatomic) NSMutableArray *dataArr;
@end

@implementation AppointmentList_ViewController
@synthesize myTableView;
@synthesize appointmentListMuArr;
@synthesize status;
@synthesize lineView;
@synthesize appointmentListOperation;
@synthesize dataArr;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.title = @"预约";
    [self requestListWithStatus];
}

- (void)viewDidLoad {
    self.isShowButton = NO;
    [super viewDidLoad];
    
    UIButton *rightBtn  = [UIButton buttonWithTitle:@" + " target:self selector:@selector(buttonClickAppointment) frame:CGRectMake(kSCREN_BOUNDS.size.width - 50.0f, 10 , 30, 30) backgroundImg:nil  highlightedImage:nil];
    rightBtn.titleLabel.font = kNormalFont_28;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    status = 2;
    if (self.index == 1) {
        status = 1; 
    }
    [self initSegmentControl];
    
    [self initView];
}

-(void)Appointment
{
    AppointmenCreat_ViewController * create = (AppointmenCreat_ViewController *)[[AppointmenCreat_ViewController alloc] init];
    [self.navigationController pushViewController:create animated:YES];
}

-(void)initSegmentControl
{
    NSArray *arr = [[NSArray alloc]initWithObjects:@"已确认",@"待确认",@"已开单",@"已取消", nil];
    //先创建一个数组用于设置标题
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:arr];
    [segment setApportionsSegmentWidthsByContent:YES];//时，每个的宽度按segment的宽度平分
    segment.frame = CGRectMake(5, 5, kSCREN_BOUNDS.size.width - 10, 40);
    segment.selectedSegmentIndex= self.index;
    segment.tintColor = kColor_Clear;
    segment.backgroundColor = kColor_White;
    
    //修改字体的默认颜色与选中颜色
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:kColor_TitlePink,UITextAttributeTextColor,  [UIFont fontWithName:@"Helvetica" size:14.f],UITextAttributeFont ,kColor_TitlePink,UITextAttributeTextShadowColor ,nil];
    [segment setTitleTextAttributes:dic forState:UIControlStateSelected];
    [segment setTitleTextAttributes:dic forState:UIControlStateNormal];
    
    [self.view addSubview:segment];

    segment.segmentedControlStyle = UISegmentedControlStylePlain;//设置样式
    [segment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged];
    
    UIView * lightLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44,320, 0.5f)];
    lightLineView.backgroundColor = kTableView_LineColor;
    [self.view addSubview:lightLineView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 80, 0.5f)];
    lineView.backgroundColor = kColor_TitlePink;
    [self.view addSubview:lineView];
    
}
-(void)segmentedAction:(id)sender{
    
    [UIImageView beginAnimations:@"anim" context:NULL];
    [UIImageView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIImageView setAnimationBeginsFromCurrentState:YES];
    [UIImageView setAnimationDuration:0.5];
    CGRect listFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    UISegmentedControl *control = (UISegmentedControl *)sender;
    switch (control.selectedSegmentIndex) {
        case 0:
            status = 2;
            listFrame = CGRectMake(0.0f, 44.0f, 80, 0.5f);
            break;
        case 1:
            status = 1;
            listFrame = CGRectMake(80.0f, 44.0f, 80, 0.5f);
            break;
        case 2:
            status = 3;
            listFrame = CGRectMake(160.0f, 44.0f, 80, 0.5f);
            break;
        case 3:
            status = 4;
            listFrame = CGRectMake(240.0f, 44.0f, 80, 0.5f);
            break;
            
        default:
            break;
    }
    lineView.frame = listFrame;
    [UIImageView commitAnimations];
    [self requestListWithStatus];
}
-(void)initView
{
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 10.0f, 45, kSCREN_BOUNDS.size.width - 20, kSCREN_BOUNDS.size.height- kNavigationBar_Height + 20 -  40  - kToolBar_Height)];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = kColor_Clear;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview:myTableView];

}
- (void)buttonClickAppointment
{
    appointmentListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/GetCustomerBranch"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *salonArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [salonArray addObject:[[AppointmentStoreModel alloc] initWithDic:obj]];
            }];
            dataArr = salonArray;
            if (dataArr.count == 1) {
                self.hidesBottomBarWhenPushed = YES;
                WMPageController *pageController = [self getDefaultController:0];
                pageController.menuHeight = 44;
                pageController.menuItemWidth =  (kSCREN_BOUNDS.size.width / 3);
                pageController.menuBGColor = kColor_White;
                pageController.progressColor = kColor_TitlePink;
                [self.navigationController pushViewController:pageController animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            } else if(dataArr.count == 0){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"没有可预约的门店" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                self.hidesBottomBarWhenPushed = YES;
                AppointmentNewViewController *new = [[AppointmentNewViewController alloc] init];
                [self.navigationController pushViewController:new animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            }
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}

-(WMPageController *)getDefaultController:(NSInteger)index
{
    NSMutableArray *viewControllers=[[NSMutableArray alloc] init];
    NSMutableArray *titles=[[NSMutableArray alloc] init];
    for (int i =0; i < 3; i++) {
        NSString *title;
        switch (i%3) {
            case 0:{
                //                vcClass =[RecommendViewController class];
                //                vcClass.bachId =[dataArr[index] valueForKey:@"BranchID"];
                RecommendViewController *recommd= [[RecommendViewController alloc] init];
                recommd.BranchID =[[dataArr[index] valueForKey:@"BranchID"] integerValue];
                recommd.BranchName = [dataArr[index] valueForKey:@"BranchName"];
                title=@"推荐";
                [viewControllers addObject:recommd];
            }
                break;
            case 1:{
                DepositReceiptViewController *dep= [[DepositReceiptViewController alloc] init];
                dep.BranchID =[[dataArr[index] valueForKey:@"BranchID"] integerValue];
                dep.BranchName = [dataArr[index] valueForKey:@"BranchName"];
                title=@"存单";
                [viewControllers addObject:dep];
            }
                break;
            case 2:
            {
                BuyViewController *buy = [[BuyViewController alloc]init];
                title=@"买过";
                buy.BranchID =[[dataArr[index] valueForKey:@"BranchID"] integerValue];
                buy.BranchName = [dataArr[index] valueForKey:@"BranchName"];
                [viewControllers addObject:buy];
            }
                break;
                
            default:
                break;
        }
        
        //        [viewControllers addObject:vcClass];
        [titles addObject:title];
        
        
    }
    WMPageController *pageVC=[[WMPageController alloc] initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    pageVC.titleSizeSelected=15;
    pageVC.pageAnimatable=YES;
    pageVC.menuViewStyle=WMMenuViewStyleLine;
    pageVC.titleColorSelected = kColor_TitlePink;
    pageVC.titleColorNormal=kColor_TitlePink;
    
    pageVC.progressColor=kColor_TitlePink;
    return pageVC;
}

#pragma mark -  UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
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
    }
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
    cell.dateLable.text = [NSString stringWithFormat:@"%@",appointDoc.Appointment_date];
    cell.titleLable.text = @"指定顾问";
    cell.serviceNameLable.text = appointDoc.Appointment_servicename;
    cell.statusLable.text = appointDoc.Appointment_statusStr;
    cell.appointPersonalLable.text = appointDoc.Appointment_servicePersonalID > 0? appointDoc.Appointment_servicePersonal:@"到店指定";
    
    return cell;
}
#pragma mark -  UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
    AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
    detail.LongID = appointDoc.Appointment_longID;
    [self.navigationController pushViewController:detail animated:YES];
    self.hidesBottomBarWhenPushed = NO;

}
#pragma mark - 接口
-(void)requestListWithStatus
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSMutableArray * arr = [[NSMutableArray alloc] initWithObjects:@(status),nil];

    NSDictionary * para = @{
                           @"TaskType":@(1),
                           @"Status":arr,
                           @"PageIndex":@(1),
                           @"PageSize":@((long)999999),
                           };

    _getAppointmentList = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Task/GetScheduleList" showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
           
            appointmentListMuArr = [[NSMutableArray alloc] init];
            
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
            }

        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [myTableView reloadData];
    } failure:^(NSError *error) {
        
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
