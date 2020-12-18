//
//  SalesPromotionNewViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/24.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

const CGFloat kCell_Height = 113.0;



#import "SalesPromotionNewViewController.h"
#import "GPCHTTPClient.h"
#import "SalesPromotionModel.h"
#import "PromotionDetail_ViewController.h"
#import "IndexTableViewCell.h"

@interface SalesPromotionNewViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) AFHTTPRequestOperation *salesPromotionRequest;
@property (nonatomic, strong) NSMutableArray *promotionArray;
@property (nonatomic ,strong) UITableView * myTableView;
@end

@implementation SalesPromotionNewViewController
static NSString *salesIden = @"salesIden";

@synthesize myTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"促销信息";
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self requestSalesPromotion];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0 , 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 5)style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundView = nil;
    myTableView.backgroundColor = kColor_Clear;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark -  UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.promotionArray count];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier =@"Cell";
    IndexTableViewCell *cell = (IndexTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"IndexTableViewCell" owner:self options:nil] objectAtIndex:0];
        cell.backgroundColor = kColor_White;
        cell.tintColor = kColor_White;
    }
    SalesPromotionModel *sales = self.promotionArray[indexPath.section];
    cell.data = sales;
    return cell;
}

#pragma mark -  UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    PromotionDetail_ViewController *promotionController = [[PromotionDetail_ViewController alloc]init];
    promotionController.promotionCode = [self.promotionArray[indexPath.section] valueForKey:@"PromotionCode"];
    [self.navigationController pushViewController:promotionController animated:YES];
}

#pragma mark - 促销信息的网络请求
- (void)requestSalesPromotion
{
  [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"ImageHeight":@(kCell_Height),
                           @"ImageWidth":@150};
    _salesPromotionRequest = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Promotion/GetPromotionList" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            [SVProgressHUD dismiss];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [array addObject:[[SalesPromotionModel alloc] initWithDic:obj]];
            }];
            self.promotionArray = [array mutableCopy];
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];

        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

@end
