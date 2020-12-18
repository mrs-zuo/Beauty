//
//  AppointmentNewViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/11/24.
//  Copyright © 2015年 MAC_Lion. All rights reserved.
//

#import "AppointmentNewViewController.h"
#import "Appointment_new_DetailViewController.h"
#import "AppointmentStoreModel.h"
#import "RecommendViewController.h"
#import "DepositReceiptViewController.h"
#import "BuyViewController.h"
#import "WMPageController.h"
@interface AppointmentNewViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak,nonatomic) AFHTTPRequestOperation *appointmentListOperation;
@property (strong, nonatomic) NSArray *dataArr;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation AppointmentNewViewController
@synthesize appointmentListOperation;
@synthesize dataArr;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    [self requestAppointList];
    self.title = @"请选择您要预约的门店";
    _tableView = [[UITableView alloc] init];
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _tableView.frame = CGRectMake(0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height -kNavigationBar_Height  + 20);

    [self.view addSubview:_tableView];
    UIView *footView = [[UIView alloc] init];
    footView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:footView];
}

#pragma mark - UITableViewDateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    AppointmentStoreModel *appointment =[self.dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",appointment.BranchName];
    cell.textLabel.font = kNormalFont_14;
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    WMPageController *pageController = [self getDefaultController:indexPath.row];
    pageController.menuHeight = 40;
    pageController.menuItemWidth = (kSCREN_BOUNDS.size.width - 10) / 3;
    pageController.pageAnimatable=YES;
    pageController.menuViewStyle=WMMenuViewStyleLine;
    pageController.progressColor=KColor_NavBarTintColor;
    [self.navigationController pushViewController:pageController animated:YES];
}
-(WMPageController *)getDefaultController:(NSInteger)index
{
    NSMutableArray *viewControllers=[[NSMutableArray alloc] init];
    NSMutableArray *titles=[[NSMutableArray alloc] init];
    for (int i =0; i < 3; i++) {
        NSString *title;
        switch (i%3) {
            case 0:{
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
        [titles addObject:title];
    }
    WMPageController *pageVC=[[WMPageController alloc] initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    pageVC.titleSizeSelected=15;
    pageVC.pageAnimatable=YES;
    pageVC.menuViewStyle=WMMenuViewStyleLine;
    pageVC.titleColorSelected = kColor_TitlePink;
    pageVC.titleColorNormal=kColor_TitlePink;
    pageVC.progressColor= KColor_NavBarTintColor;
    pageVC.menuBGColor = kColor_White;
    return pageVC;
}

- (void)requestAppointList
{
   
    appointmentListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/GetCustomerBranch"  showErrorMsg:YES  parameters:nil WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray *salonArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [salonArray addObject:[[AppointmentStoreModel alloc] initWithDic:obj]];
            }];
            dataArr = salonArray;
         
               [self.tableView reloadData];
        
            
            NSLog(@"---%@---",dataArr);
       
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
    
}




@end
