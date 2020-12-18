//
//  Appointment_new_DetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/25.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "Appointment_new_DetailViewController.h"
#import "AppointmentDoc.h"
#import "AppointmentListTableViewCell.h"
#import "ServiceOneViewController.h"
#import "RecommendViewController.h"
#import "DepositReceiptViewController.h"
#import "BuyViewController.h"
#import "WMPageController.h"
#import "GPNavigationController.h"


@interface Appointment_new_DetailViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getAppointmentList;
@property (strong,nonatomic) UITableView *myTableView;
@property (strong,nonatomic) NSMutableArray *appointmentListMuArr;
@property (strong,nonatomic) UIView *lineView;
@property (assign,nonatomic) NSInteger status;

@end

@implementation Appointment_new_DetailViewController
@synthesize myTableView;
@synthesize appointmentListMuArr;
@synthesize lineView;
@synthesize status;
- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)viewDidLoad
{
    self.isShowButton = YES;
    [super viewDidLoad];
    WMPageController *pageController = [self getDefaultController];
    
    NSArray*ary=[NSArray arrayWithObject:pageController];
    NSLog(@"%@",ary);
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 4, 44)];
    titleLabel.text=@"新闻资讯";
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:18.f];
    titleLabel.textColor=[UIColor colorWithRed:1 green:0.97 blue:0 alpha:1];
    
    pageController.navigationItem.titleView = titleLabel;
    
    [self.navigationController pushViewController:pageController animated:YES];
    
   
}
-(WMPageController *)getDefaultController
{
    NSMutableArray *viewControllers=[[NSMutableArray alloc] init];
    NSMutableArray *titles=[[NSMutableArray alloc] init];
    for (int i =0; i < 3; i++) {
        Class vcClass;
        NSString *title;
        switch (i%3) {
            case 0:
                vcClass =[RecommendViewController class];
                title=@"推荐";
                break;
            case 1:
                vcClass =[DepositReceiptViewController class];
                title=@"存单";
                break;
            case 2:
                vcClass=[BuyViewController class];
                title=@"买过";
                break;
         
            default:
                break;
        }
        [viewControllers addObject:vcClass];
        [titles addObject:title];
    }
    WMPageController *pageVC=[[WMPageController alloc] initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    pageVC.titleSizeSelected=15;
    pageVC.pageAnimatable=YES;
    pageVC.menuViewStyle=WMMenuViewStyleFoold;
    pageVC.titleColorSelected = [UIColor whiteColor];
    pageVC.titleColorNormal=[UIColor blackColor];
    pageVC.progressColor=[UIColor whiteColor];
    return pageVC;
}
/*
 
 //分段控制器
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
//    NSMutableArray *array = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//    NSInteger count = array.count;
//    for(int i = 0; i < count-1 ; i++) {
//        [array removeObjectAtIndex:0];
//    }
//    [self.navigationController setViewControllers:array];
//    
//    GPNavigationController *navigation = (GPNavigationController *)self.navigationController;
//    navigation.canDragBack = YES;
    
    [self requestListWithStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kColor_BackgroundView;
    
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


-(void)initSegmentControl
{
    NSArray *arr = [[NSArray alloc]initWithObjects:@"推荐",@"存单",@"买过", nil];
    //先创建一个数组用于设置标题
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:arr];
    [segment setApportionsSegmentWidthsByContent:YES];//时，每个的宽度按segment的宽度平分
    segment.frame = CGRectMake(5, 5, 310, 40);
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

-(void)initView
{
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, 45, 310.0f, kSCREN_BOUNDS.size.height - 50.0f-40-49)];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    [myTableView setTableFooterView:view];
    
    [self.view addSubview:myTableView];
    
    // 新增预约按钮
    UIButton *appointmentCancel = [UIButton buttonWithTitle:@"查看全部服务" target:self selector:@selector(buttonClickAppointment) frame:CGRectMake(0.0, kSCREN_BOUNDS.size.height-90, kSCREN_BOUNDS.size.width,49 ) backgroundImg:[UIImage imageNamed:@"button_BuyTotal"]  highlightedImage:nil];
    [self.view addSubview:appointmentCancel];
}
- (void)buttonClickAppointment
{

    UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    ServiceOneViewController *one = [board instantiateViewControllerWithIdentifier:@"ServiceOneViewController"];
    [self.navigationController pushViewController:one animated:YES];
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
            listFrame = CGRectMake(10.0f, 44.0f, 100, 0.5f);
            break;
        case 1:
            status = 1;
            listFrame = CGRectMake(110.0f, 44.0f, 100, 0.5f);
            break;
        case 2:
            status = 3;
            listFrame = CGRectMake(210.0f, 44.0f, 100, 0.5f);
            break;
        default:
            break;
    }
    lineView.frame = listFrame;
    [UIImageView commitAnimations];
    [self requestListWithStatus];
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
        
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (65 -12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    
    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
    
    cell.dateLable.text = [NSString stringWithFormat:@"%@",appointDoc.Appointment_date];
    cell.titleLable.text = @"指定顾问";
    cell.serviceNameLable.text = appointDoc.Appointment_servicename;
    cell.statusLable.text = appointDoc.Appointment_statusStr;
    cell.appointPersonalLable.text = appointDoc.Appointment_servicePersonalID > 0? appointDoc.Appointment_servicePersonal:@"到店指定";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    AppointmentDoc * appointDoc = [appointmentListMuArr objectAtIndex:indexPath.row];
//    AppointmentDetail_ViewController * detail = [[AppointmentDetail_ViewController alloc] init];
//    detail.LongID = appointDoc.Appointment_longID;
//    [self.navigationController pushViewController:detail animated:YES];
}


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
    // Dispose of any resources that can be recreated.
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
