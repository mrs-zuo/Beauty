//
//  AccountInAndOutList_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/25.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//
#import "AccountInAndOutList_ViewController.h"
#import "DEFINE.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "AccountCellTableViewCell.h"
#import "CardPayanInDetailViewController.h"

@interface AccountInAndOutList_ViewController ()<UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) AFHTTPRequestOperation *getPayAndRechargeOperation;
@property (nonatomic) NSMutableArray *payAndRechageArray;
@property (strong, nonatomic)  UITableView *tableView;
@end

@implementation AccountInAndOutList_ViewController

@synthesize payAndRechageArray;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;

    self.title = @"账户交易记录";

    _tableView = [[UITableView alloc] init];
    _tableView.allowsSelection = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate =self;
    _tableView.dataSource =self;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20)];

    [self.view addSubview:_tableView];
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    
    [self requestPayAndRechargeList];
 
}

#pragma mark -  UITableViewDataSource

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
    }
    cell.titleNameLabel.textColor = kColor_Editable;
    cell.titleNameLabel.font = kNormalFont_14;
    cell.contentText.textColor = [UIColor blackColor];
    cell.contentText.font = kNormalFont_14;
    cell.contentText.userInteractionEnabled = NO;
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    cell.titleNameLabel.text = [[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"ChangeTypeName"];
    cell.contentText.text = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"CreateTime"] substringToIndex:16];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}
#pragma mark - UITableViewDelegate 

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CardPayanInDetailViewController *cardPayanInDetail = (CardPayanInDetailViewController*)[sb instantiateViewControllerWithIdentifier:@"CardPayan"];
    cardPayanInDetail.cardType = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"TargetAccount"] integerValue] ;
    cardPayanInDetail.changeType = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"ChangeType"] integerValue];
    cardPayanInDetail.ID = [[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"BalanceID"] integerValue];
    [self.navigationController pushViewController:cardPayanInDetail animated:YES];
    
}
#pragma mark - 接口

- (void)requestPayAndRechargeList
{
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld}", (long)CUS_CUSTOMERID];
    
    _getPayAndRechargeOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetBalanceListByCustomerID"  showErrorMsg:YES  parameters:par WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            payAndRechageArray = [NSMutableArray array];

            [payAndRechageArray addObjectsFromArray:data];
            
            [_tableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}


@end
