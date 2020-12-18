//
//  PaymentHistoryViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PaymentHistoryViewController.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"
#import "PaymentHistoryDetailViewController.h"
#import "GPHTTPClient.h"
#import "GPBHTTPClient.h"
#import "TitleView.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "OrderPaymentDetailViewController.h"

@interface PaymentHistoryViewController ()
@property (strong ,nonatomic) NSMutableArray *paymentArray;
@property (strong ,nonatomic) PaymentHistoryDoc *paymentHistoryDoc_select;
@property (weak  , nonatomic) AFHTTPRequestOperation *getPaymenListOperation;
@end

@implementation PaymentHistoryViewController
@synthesize paymentArray;

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    paymentArray = [NSMutableArray array];
    //在(IOS7 || IOS8)的情况下重新计算起始点
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    TitleView *titleView = [[TitleView alloc] init];
    [titleView getTitleView:@"支付记录"];
    [self.view addSubview:titleView];
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.frame = CGRectMake( 5.0f, titleView.frame.origin.y + titleView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self getPaymentListByCustomerID:appDelegate.customer_Selected.cus_ID];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_getPaymenListOperation || [_getPaymenListOperation isExecuting]) {
        [_getPaymenListOperation cancel];
        _getPaymenListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UItableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return paymentArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62.f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    PaymentHistoryDoc *paymentHistoryDoc = [paymentArray objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell viewWithTag:9996];
    if(!title) {
        title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 100, 20)];
        [cell addSubview:title];
    }
    title.tag = 9996;
    title.textColor = kColor_DarkBlue;
    title.font = kFont_Light_16;
    title.text = paymentHistoryDoc.paymentTitle;
    
    UILabel *time = (UILabel *)[cell viewWithTag:9997];
    if(!time){
        time = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 160, 20)];
        [cell addSubview:time];
    }
    time.tag = 9997;
    time.textColor = kColor_Editable;
    time.font = kFont_Light_14;
    time.text = paymentHistoryDoc.paymentTime;
    
    UILabel *money = (UILabel *)[cell viewWithTag:9998];
    if(!money){
        money = [[UILabel alloc] initWithFrame:CGRectMake(180, 9, 100, 20)];
        [cell addSubview:money];
    }
    money.tag = 9998;
    money.textColor = kColor_Black;
    money.font = kFont_Light_14;
    money.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon, paymentHistoryDoc.paymentTotalMoney];
    money.textAlignment  = NSTextAlignmentRight;
    
    UIImageView *record = (UIImageView*)[cell viewWithTag:9999];
    if(!record){
        record = [[UIImageView alloc] initWithFrame:CGRectMake(110, 10, 15, 15)];
        record.image = [UIImage imageNamed:@"paymentRecord"];
        [cell addSubview:record];
    }
    record.tag = 9999;
    [record setHidden:!paymentHistoryDoc.isRemark];

    
    for(int i = 0; i < 5; i++){
        UIImageView *view = (UIImageView *)[cell viewWithTag:10000 + i];
        if (view)
            [view removeFromSuperview];
    }
    
    
    NSInteger payModeCount = 5;
    
    for (PayInfoDoc *payment in paymentHistoryDoc.paymentMode) {
        if (payment.pay_Mode == 2) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135 + payModeCount * 25, 36, 21, 15)];
            imageView.image = [UIImage imageNamed:@"yinhangka.png"];
            [cell addSubview:imageView];
            payModeCount--;
            imageView.tag = 10000;
        }
        
        if (payment.pay_Mode  == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135 + payModeCount * 25, 36, 21, 15)];
            imageView.image = [UIImage imageNamed:@"Eka.png"];
            [cell addSubview:imageView];
            payModeCount--;
            imageView.tag = 10001;
        }
        
        if (payment.pay_Mode  == 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135 + payModeCount * 25, 36, 21, 15)];
            imageView.image = [UIImage imageNamed:@"xianjin.png"];
            [cell addSubview:imageView];
            payModeCount--;
            imageView.tag = 10002;
        }
        
        if (payment.pay_Mode  == 3) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135 + payModeCount * 25, 36, 21, 15)];
            imageView.image = [UIImage imageNamed:@"otherPayment.png"];
            [cell addSubview:imageView];
            payModeCount--;
            imageView.tag = 10003;
        }
        
        if (payment.pay_Mode  == 8) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(135 + payModeCount * 25, 36, 21, 15)];
            imageView.image = [UIImage imageNamed:@"weChat.png"];
            [cell addSubview:imageView];
            payModeCount--;
            imageView.tag = 10004;
        }
    }
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _paymentHistoryDoc_select = [paymentArray objectAtIndex:indexPath.row];
//    [self performSegueWithIdentifier:@"gotoDetailFromPaymentHistory" sender:self];
    
    [self performSegueWithIdentifier:@"OrderPaymentHistoryFromOrderDetail" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ([segue.identifier isEqualToString:@"gotoDetailFromPaymentHistory"]) {
//        PaymentHistoryDetailViewController *detailController = segue.destinationViewController;
//        detailController.paymentHistoryDoc = _paymentHistoryDoc_select;
//        detailController.page = 0;
//    }
    
    if ([segue.identifier isEqualToString:@"OrderPaymentHistoryFromOrderDetail"]) {
        OrderPaymentDetailViewController *detailController = segue.destinationViewController;
        detailController.paymentId = _paymentHistoryDoc_select.paymentId;
    }
}

#pragma mark - 接口

- (void)getPaymentListByCustomerID:(NSInteger)customerID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"CustomerID\":%ld,\"BranchID\":%ld}", (long)customerID, (long)ACC_BRANCHID];

    _getPaymenListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/getPaymentList" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if(!paymentArray)
                paymentArray = [NSMutableArray array];
            else
                [paymentArray removeAllObjects];
            
            for (NSDictionary *dic in data){
                PaymentHistoryDoc *paymentDoc = [[PaymentHistoryDoc alloc] init];
                paymentDoc.paymentId = [[dic objectForKey:@"ID"] integerValue];
                paymentDoc.paymentTime = [dic objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dic objectForKey:@"PaymentTime"];
                paymentDoc.paymentTitle = [dic objectForKey:@"Describe"];
                paymentDoc.paymentTotalMoney = [[dic objectForKey:@"TotalPrice"] doubleValue];
                paymentDoc.isRemark = [[dic objectForKey:@"IsRemark"] boolValue];
                paymentDoc.paymentMode = [NSMutableArray array];
                
                NSString * paymentModes = [dic objectForKey:@"PaymentModes"];
                for (int i = 0; i < 4; i++) {
                    if ([paymentModes rangeOfString:[NSString stringWithFormat:@"|%d|",i]].length > 0){
                        PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                        payInfoDoc.pay_Mode = [[NSString stringWithFormat:@"%d",i] integerValue];
                        [paymentDoc.paymentMode addObject:payInfoDoc];
                    }
                }
                
                if ([paymentModes rangeOfString:[NSString stringWithFormat:@"|%d|",8]].length > 0){
                    PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                    payInfoDoc.pay_Mode = [[NSString stringWithFormat:@"%d",8] integerValue];
                    [paymentDoc.paymentMode addObject:payInfoDoc];
                }
                
                paymentDoc.paymentTime = [paymentDoc.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                [paymentArray addObject:paymentDoc];
            }
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _getPaymenListOperation = [[GPHTTPClient shareClient] requestGetPaymentListByCustomerID:customerID Success:^(id xml) {
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data ,id message) {
            if(!paymentArray)
                paymentArray = [NSMutableArray array];
            else
                [paymentArray removeAllObjects];
            
            for (NSDictionary *dic in data){
                PaymentHistoryDoc *paymentDoc = [[PaymentHistoryDoc alloc] init];
                paymentDoc.paymentId = [[dic objectForKey:@"ID"] integerValue];
                paymentDoc.paymentTime = [dic objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dic objectForKey:@"PaymentTime"];
                paymentDoc.paymentTitle = [dic objectForKey:@"Describe"];
                paymentDoc.paymentTotalMoney = [[dic objectForKey:@"TotalPrice"] doubleValue];
                paymentDoc.isRemark = [[dic objectForKey:@"IsRemark"] boolValue];
                paymentDoc.paymentMode = [NSMutableArray array];
                for (int i = 0; i < 4; i++) {
                    NSString * paymentModes = [dic objectForKey:@"PaymentModes"];
                    if ([paymentModes rangeOfString:[NSString stringWithFormat:@"|%d|",i]].length > 0){
                        PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                        payInfoDoc.pay_Mode = [NSString stringWithFormat:@"%d",i];
                        [paymentDoc.paymentMode addObject:payInfoDoc];
                    }
                }
                paymentDoc.paymentTime = [paymentDoc.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                [paymentArray addObject:paymentDoc];
            }
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSString *error) {
            [SVProgressHUD dismiss];
        }];
    }
    failure:^(NSError *error) {
         [SVProgressHUD dismiss];
    }];
     */
}



@end
