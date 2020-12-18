//
//  AccountInAndOutList_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//
#import "AccountInAndOutList_ViewController.h"
#import "AccountInAndOutDetail_ViewController.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "NavigationView.h"
#import "MJRefresh.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"
#import "AccountCellTableViewCell.h"

@interface AccountInAndOutList_ViewController ()<UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *getPayAndRechargeOperation;
@property (nonatomic) NSMutableArray *payAndRechageArray;
@property (strong, nonatomic)  UITableView *tableView;
@end

@implementation AccountInAndOutList_ViewController
@synthesize payAndRechageArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Background_View;
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self requestPayAndRechargeList];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"账户交易记录"];
    [self.view addSubview:navigationView];
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    _tableView = [[UITableView alloc] init];
    _tableView.allowsSelection = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate =self;
    _tableView.dataSource =self;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    [self.view addSubview:_tableView];
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
 
}
-(void)headerRefresh
{
    [self requestPayAndRechargeList];
}
#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [payAndRechageArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellindity = @"RechargeEditCell";
    AccountCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellindity];
    if (cell == nil){
        cell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
        cell.backgroundColor = [UIColor whiteColor];
        
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    cell.titleNameLabel.textColor = kColor_DarkBlue;
    cell.titleNameLabel.font = kFont_Medium_16;
    cell.contentText.textColor = [UIColor blackColor];
    cell.contentText.font = kFont_Light_16;
    cell.contentText.userInteractionEnabled = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    cell.titleNameLabel.text = [[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"ChangeTypeName"];
    cell.contentText.text = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"CreateTime"] substringToIndex:16];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AccountInAndOutDetail_ViewController * detail = [[AccountInAndOutDetail_ViewController alloc] init];
    detail.accountCardType = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"TargetAccount"] integerValue];
    detail.BalanceID = [[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"BalanceID"];
    detail.changeType = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"ChangeType"] integerValue];
    detail.accountCardType = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"TargetAccount"] integerValue];
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark - 接口

- (void)requestPayAndRechargeList
{
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID];
    
    _getPayAndRechargeOperation= [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBalanceListByCustomerID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            
            if (payAndRechageArray == nil){
                payAndRechageArray = [NSMutableArray array];
            } else {
                [payAndRechageArray removeAllObjects];
            }
            [payAndRechageArray addObjectsFromArray:data];
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
