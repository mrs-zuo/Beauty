//
//  PaymentHistoryViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "PaymentHistoryViewController.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"
#import "PaymentHistoryDetailViewController.h"
#import "GPHTTPClient.h"
#import "ZWJson.h"
#import "SVProgressHUD.h"

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
//    TitleView *titleView = [[TitleView alloc] init];
//    [titleView getTitleView:@"支付记录"];
//    [self.view addSubview:titleView];
    self.title = @"支付记录";
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.backgroundView = nil;
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.frame = CGRectMake( 0, 0, kSCREN_BOUNDS.size.width , kSCREN_BOUNDS.size.height - 90.0f);
    
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getPaymentListByCustomerID];
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
    return kTableView_HeightOfRow_Multiline;
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
    title.textColor = kColor_TitlePink;
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
    money.text = [NSString stringWithFormat:@"%@  -%.2Lf",CUS_CURRENCYTOKEN, paymentHistoryDoc.paymentTotalMoney];
    money.textAlignment  = NSTextAlignmentRight;

    UIImageView *record = (UIImageView*)[cell viewWithTag:9999];
    if(!record){
        record = [[UIImageView alloc] initWithFrame:CGRectMake(110, 10, 15, 15)];
        record.image = [UIImage imageNamed:@"paymentRecord"];
        [cell addSubview:record];
    }
    record.tag = 9999;
    [record setHidden:!paymentHistoryDoc.isRemark];
    
    for(int i = 0; i < 4; i++){
        UIImageView *view = (UIImageView *)[cell viewWithTag:10000 + i];
        if (view)
           [view removeFromSuperview];
    }
    
    NSInteger payModeCount = 4;
    for (int i = 0; i < paymentHistoryDoc.paymentMode.count ; i++){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(160 + payModeCount * 25, 36, 21, 15)];
        PayInfoDoc *payInfoDoc = (PayInfoDoc *)[paymentHistoryDoc.paymentMode objectAtIndex:i];
        
        if([payInfoDoc.pay_Mode integerValue] == 2)
            imageView.image = [UIImage imageNamed:@"yinhangka.png"];
        if([payInfoDoc.pay_Mode integerValue] == 1)
            imageView.image = [UIImage imageNamed:@"Eka.png"];
        if([payInfoDoc.pay_Mode integerValue] == 0)
            imageView.image = [UIImage imageNamed:@"xianjin.png"];
        if([payInfoDoc.pay_Mode integerValue] == 3)
            imageView.image = [UIImage imageNamed:@"otherPayment.png"];
        
        imageView.tag = 10000 + i;
        payModeCount -- ;
        
        [cell addSubview:imageView];
    }
    
    return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _paymentHistoryDoc_select = [paymentArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"gotoDetailForHistoryList" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"gotoDetailForHistoryList"]) {
        PaymentHistoryDetailViewController *detailController = segue.destinationViewController;
        detailController.paymentHistoryDoc = _paymentHistoryDoc_select;
        detailController.page = 0;
    }
}

#pragma mark - 接口

- (void)getPaymentListByCustomerID
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _getPaymenListOperation = [[GPHTTPClient shareClient] requestGetPaymentListSuccess:^(id xml) {
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data , NSInteger code, id message) {
            if(!paymentArray)
                paymentArray = [NSMutableArray array];
            else
                [paymentArray removeAllObjects];
            
            for (NSDictionary *dic in data){
                PaymentHistoryDoc *paymentDoc = [[PaymentHistoryDoc alloc] init];
                paymentDoc.paymentCode = dic[@"PaymentCode"];
                paymentDoc.paymentId = [dic[@"ID"] integerValue];
                paymentDoc.paymentTime = [ dic objectForKey:@"PaymentTime"];
                paymentDoc.paymentTitle = dic[@"Describe"];
                paymentDoc.paymentTotalMoney = [dic[@"TotalPrice"] doubleValue];
                paymentDoc.isRemark = [dic[@"IsRemark"] boolValue];
                paymentDoc.paymentMode = [NSMutableArray array];
                for (int i = 0; i < 4; i++) {
                    NSString * paymentModes = dic[@"PaymentModes"];
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
        } failure:^( NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
    }
    failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


@end
