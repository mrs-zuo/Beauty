//
//  RechargeAndPayViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-8-15.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RechargeAndPayViewController.h"
#import "RechargeAndPayCell.h"
#import "DEFINE.h"
#import "PayDoc.h"
#import "RechargeAndPayCell.h"
#import "GPHTTPClient.h"
#import "InitialSlidingViewController.h"
#import "GDataXMLNode.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "NavigationView.h"
#import "MJRefresh.h"
//#import "RechargeDetailViewController.h"
#import "PaymentHistoryDetailViewController.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"
#import "GPBHTTPClient.h"
#import "AppDelegate.h"
#import "AccountInAndOutDetail_ViewController.h"

@interface RechargeAndPayViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *getPayAndRechargeOperation;

@property (nonatomic) NSMutableArray *payAndRechageArray;
@end

@implementation RechargeAndPayViewController
@synthesize payAndRechageArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self requestPayAndRechargeList];

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"充值消费记录"];
    [self.view addSubview:navigationView];
    
    if ((IOS7 || IOS8)) {
        _tableView.separatorInset = UIEdgeInsetsZero;
    }
    _tableView.allowsSelection = YES;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    [_tableView addHeaderWithTarget:self action:@selector(headerRefresh)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    NSDictionary * recordDic = [payAndRechageArray objectAtIndex:indexPath.row];
    RechargeAndPayCell *cell = nil;
    if([[recordDic objectForKey:@"ActionType"] intValue] == 1 && payAndRechageArray.count > 0){
        NSString *cellindity =@"ConsumeCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellindity];
        if (cell == nil ) {
            cell=[[RechargeAndPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (60-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
        }
    }else{

        NSString *cellindity =@"RechargeCell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellindity];
        if (cell == nil ) {
            cell=[[RechargeAndPayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
            UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (60-12)/2, 10, 12)];
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
        }
    }
    
    [cell.titleLabel setText:[recordDic objectForKey:@"ActionModeName"]];
    [cell.titleLabel setFont:kFont_Light_16];
    if (self.accountType ==2) {
        [cell.balanceLabel setText:[NSString stringWithFormat:@"%.2f" ,[[recordDic objectForKey:@"Balance"] doubleValue]]];
    }else{
        [cell.balanceLabel setText:[NSString stringWithFormat:@"%@ %.2f", MoneyIcon ,[[recordDic objectForKey:@"Balance"] doubleValue]]];
    }
    [cell.balanceLabel setFont:kFont_Light_14];
    [cell.dateLabel setText:[recordDic objectForKey:@"CreateTime"]];
    
    if([[recordDic objectForKey:@"ActionType"] intValue]== 0){
        [cell.payLabel setTextColor:[UIColor greenColor]];
        [cell.payLabel setFont:kFont_Light_14];
        [cell.payLabel setText:[NSString stringWithFormat:@"+%.2f",[[recordDic objectForKey:@"Amount"] doubleValue]]];
    } else{
        [cell.payLabel setTextColor:[UIColor redColor]];
        [cell.payLabel setFont:kFont_Light_14];
        [cell.payLabel setText:[NSString stringWithFormat:@"%.2f",[[recordDic objectForKey:@"Amount"] doubleValue]]];
        if(payAndRechageArray.count > 1)
            [cell.titleLabel setText: [NSString stringWithFormat:@"%@",cell.titleLabel.text]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
      return 60.0f;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * dic =[payAndRechageArray objectAtIndex:indexPath.row];
//    if([[[payAndRechageArray objectAtIndex:indexPath.row] objectForKey:@"ActionType"] intValue] == 1 && payAndRechageArray.count >0)
//    {
//        PaymentHistoryDetailViewController *PayDetail = [[self storyboard] instantiateViewControllerWithIdentifier:@"PaymentHistoryDetailViewController"];
//        PaymentHistoryDoc *paymentHistory = [[PaymentHistoryDoc alloc] init];
//        paymentHistory.paymentId = [[dic objectForKey:@"BalanceID"]intValue];
//        paymentHistory.paymentBalanceLeft = [[dic objectForKey:@"Balance"]doubleValue];
//        paymentHistory.paymentMode = [NSMutableArray array];
//        PayInfoDoc *pay = [[PayInfoDoc alloc] init];
//        pay.pay_Mode = [NSString stringWithFormat:@"%ld",(long)1];
//        [paymentHistory.paymentMode  addObject:pay];
//        PayDetail.page = 1;
//        PayDetail.paymentHistoryDoc = paymentHistory;
//        [self.navigationController pushViewController:PayDetail animated:YES];
//    } else {
        AccountInAndOutDetail_ViewController * detail = [[AccountInAndOutDetail_ViewController alloc] init];
        detail.accountCardType = self.accountType;
        detail.BalanceID = [dic objectForKey:@"BalanceID"];
        detail.changeType = [[dic objectForKey:@"ChangeType"] integerValue];
        [self.navigationController pushViewController:detail animated:YES];
//    }
}
#pragma mark - 接口

- (void)requestPayAndRechargeList
{
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"UserCardNo\":%@,\"CardType\":%d}", (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID,self.userCardId,self.accountType];
    _getPayAndRechargeOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardBalanceByUserCardNo" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {

            NSArray * arr =data;
            if (payAndRechageArray == nil){
                payAndRechageArray = [NSMutableArray array];
            } else {
                [payAndRechageArray removeAllObjects];
            }
            [payAndRechageArray addObjectsFromArray:arr];
            
            [_tableView headerEndRefreshing];
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
        }];
    } failure:^(NSError *error) {
    }];
}


@end
