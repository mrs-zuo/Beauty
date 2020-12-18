//
//  PaymentHistoryDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-17.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "PaymentHistoryDetailViewController.h"
#import "TwoElementDoc.h"
#import "AFHTTPClient.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "ZWJson.h"
#import "PayInfoDoc.h"
#import "OrderDetailViewController.h"
#import "OrderDoc.h"
#import "TitleView.h"
#import "GPBHTTPClient.h"
#import "PayInfoDoc.h"

@interface PaymentHistoryDetailViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetPaymentDetailOperation;
@property (strong, nonatomic) NSArray *paymentModeName;
@property (strong, nonatomic) OrderPaymentDoc *orderPaymentDoc;
@property (nonatomic, strong) TitleView *titleView;
@end

@implementation PaymentHistoryDetailViewController
@synthesize titleView;
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    

     titleView = [[TitleView alloc] init];
    [titleView getTitleView:(_page == 0 ? @"支付详情":@"e卡支付详情")];
    [self.view addSubview:titleView];
    _paymentModeName =[NSArray arrayWithObjects:@"现金",@"e卡",@"银行卡", @"其他",nil];
    
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    if (IOS7 || IOS8) {
        _tableView.frame = CGRectMake(5.0f, titleView.frame.origin.y + titleView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
        self.edgesForExtendedLayout= UIRectEdgeNone;
    } else if (IOS6) {
        _tableView.frame = CGRectMake(-5.0f, titleView.frame.origin.y + titleView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [titleView getTitleView:(_page == 0 ? @"支付详情":@"e卡支付详情")];
    [self getPaymentDetailById:_paymentHistoryDoc.paymentId];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetPaymentDetailOperation || [_requestGetPaymentDetailOperation isExecuting]) {
        [_requestGetPaymentDetailOperation cancel];
        _requestGetPaymentDetailOperation = nil;
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
    return self.paymentHistoryDoc.paymentArray.count + 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return  5 + self.paymentHistoryDoc.paymentMode.count + _page + (self.paymentHistoryDoc.paymentRemark.length > 0 ? 2: 0);
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 6 + self.paymentHistoryDoc.paymentMode.count + _page){
        NSInteger height = [self.paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
        return height < 38 ? 38 : height;
    }
    if (indexPath.section == 0 && indexPath.row == 4 + self.paymentHistoryDoc.paymentMode.count + _page) {
        NSString *accString = [self.paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
        NSInteger height = [accString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height + 18;
        return height < 38 ? 38 : height;
    }
    return kTableView_HeightOfRow;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        //备注内容部分
        if(indexPath.row == self.paymentHistoryDoc.paymentMode.count + 6 + _page) {
            NSInteger height = [self.paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 0, ((IOS6) ? 310.f : 300.f), (height <= 38 ? 34 : height))];
            textView.font = kFont_Light_16;
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.text = ((TwoElementDoc *)[[self.paymentHistoryDoc.paymentDispalyArray objectAtIndex:0] objectAtIndex:indexPath.row ]).secondElement;
            textView.backgroundColor = [UIColor clearColor];
            UITableViewCell *cell = [[UITableViewCell alloc]init];
            cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell addSubview:textView];
            cell.backgroundColor = kColor_White;
            return cell;
        }
    }
    CGFloat origin = 10;
    if(IOS6) origin = 20;
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;
    
    TwoElementDoc *twoElement = (TwoElementDoc *)[[self.paymentHistoryDoc.paymentDispalyArray objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
    UILabel *title = (UILabel *)[ cell viewWithTag:1000];
    if(!title){
        title = [[UILabel alloc] initWithFrame:CGRectMake(origin, 8, 100, 20)];
        [cell addSubview:title];
    }

    title.tag = 1000;
    title.font = kFont_Light_16;
    title.text = twoElement.firstElement;
    
    
    UILabel *value = (UILabel *)[ cell viewWithTag:1001];
    if(!value){
        value = [[UILabel alloc] init];
        [cell addSubview:value];
    }
    value.frame = CGRectMake(110 + origin, 8, 180, 20);
    value.textColor = kColor_Black;
    value.font = kFont_Light_16;
    value.tag = 1001;
    
    
    value.text = twoElement.secondElement;
    value.textAlignment  = NSTextAlignmentRight;
    
    //业绩参与 根据内容调整显示的Label高度
    if (indexPath.section == 0 && indexPath.row == 4 + self.paymentHistoryDoc.paymentMode.count + _page) {
        NSInteger height = [twoElement.secondElement sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height;
        if (height > 20) {
            value.frame = CGRectMake(110 + origin, 8, 180, height);
            value.numberOfLines = 0;
            value.textAlignment = NSTextAlignmentLeft;
        }
    }
    if ((indexPath.section == 0 && indexPath.row > 3 && indexPath.row < self.paymentHistoryDoc.paymentMode.count + 4)){
        
        PayInfoDoc *payInfoDoc = [self.paymentHistoryDoc.paymentMode objectAtIndex:indexPath.row-4];
        title.text = [NSString stringWithFormat:@"%@",payInfoDoc.card_name];
        title.textColor = kColor_Black;
        value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon,payInfoDoc.pay_Amount];
        if (payInfoDoc.pay_Mode == 6 || payInfoDoc.pay_Mode ==7) {
            UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(110 + ((IOS6) ? 20.f : 10.f), 8, 80, 20)];
            lable.textColor = kColor_Black;
            lable.font = kFont_Light_16;
            lable.textAlignment  = NSTextAlignmentRight;
            lable.text = [NSString stringWithFormat:@"%.f 抵",payInfoDoc.cardPay_Amount];
            [cell addSubview:lable];
            if (payInfoDoc.pay_Mode == 6){
                value.text = [NSString stringWithFormat:@"%2f",payInfoDoc.pay_Amount];
            }
        }
         title.textColor = kColor_Black;
    }else
        title.textColor = kColor_DarkBlue;
    
    //如果是订单的名字， 则特殊处理
    if(indexPath.section > 0 && indexPath.row == 1){
        title.frame = CGRectMake(origin, 8, 300, 20);
        title.textColor = kColor_Black;
        title.text = twoElement.secondElement;
        value.text = @"";
    }else if(indexPath.section > 0 && indexPath.row == 0){
        value.frame = CGRectMake(110 + origin, 8, 160, 20);
        value.text = twoElement.secondElement;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }

        
    if (_page == 1 && indexPath.section == 0 && indexPath.row == 4) {
        title.text = @"e卡";
    }
    if(_page == 1 && indexPath.section == 0 && indexPath.row == 5){ //从e卡页跳过来时
        title.text = @"余额";
        value.text =  [NSString stringWithFormat:@"%@%.2f", MoneyIcon, self.paymentHistoryDoc.paymentBalanceLeft];
    }

    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0 && indexPath.row == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _orderPaymentDoc = [self.paymentHistoryDoc.paymentArray objectAtIndex:indexPath.section - 1];
        [self performSegueWithIdentifier:@"gotoOrderDetailFromPaymentDetail" sender:self];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoOrderDetailFromPaymentDetail"]) {
        OrderDetailViewController *detailController = segue.destinationViewController;
        detailController.orderID = _orderPaymentDoc.orderId;
        detailController.productType = _orderPaymentDoc.orderType;
    }
}
#pragma mark - 接口
- (void)getPaymentDetailById:(NSInteger)Id
{
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"PaymentID\":%ld, \"BranchID\":%ld}", (long)Id, (long)ACC_BRANCHID];

    
    _requestGetPaymentDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/getPaymentDetail" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            self.paymentHistoryDoc.paymentDispalyArray = [NSMutableArray array];
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            NSDictionary *dict = (NSDictionary *)data;
            
            self.paymentHistoryDoc.paymentTime = [dict objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dict objectForKey:@"PaymentTime"];
            self.paymentHistoryDoc.paymentOperator = [dict objectForKey:@"Operator"];
            self.paymentHistoryDoc.paymentTotalMoney = [[dict objectForKey:@"TotalPrice"] doubleValue];
            //self.paymentHistoryDoc.paymentBalanceLeft = [[dict objectForKey:@"Balance"] doubleValue];
            self.paymentHistoryDoc.paymentCodeString = [dict objectForKey:@"PaymentCode"] == [NSNull null] ? nil : [dict objectForKey:@"PaymentCode"];
            self.paymentHistoryDoc.paymentTime = [self.paymentHistoryDoc.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            if (self.paymentHistoryDoc.paymentCodeString.length) {
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentCodeString forKey:@"支付编号"]];
            }
            NSArray *array = [dict objectForKey:@"ProfitList"] == [NSNull null] ? nil:[dict objectForKey:@"ProfitList"];
            NSMutableArray *accTmp = [NSMutableArray array];
            for (NSDictionary *dict in array) {
                NSString *name = [dict objectForKey:@"AccountName"];
                [accTmp addObject:name];
            }
            
            self.paymentHistoryDoc.accArray = accTmp;
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentTime forKey:@"支付时间"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentOperator forKey:@"操作人"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon,self.paymentHistoryDoc.paymentTotalMoney] forKey:@"支付总金额"]];
            
            
            
//            for (PayInfoDoc *payInfoDoc in self.paymentHistoryDoc.paymentMode) {
//                switch ([payInfoDoc.pay_Mode integerValue]) {
//                    case 2:
//                        payInfoDoc.pay_Amount = [[dict objectForKey:@"BankCard"] doubleValue];
//                        break;
//                    case 1:
//                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Ecard"] doubleValue];
//                        break;
//                    case 0:
//                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Cash"] doubleValue];
//                        break;
//                    case 3:
//                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Others"] doubleValue];
//                        break;
//                }
//                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon,payInfoDoc.pay_Amount] forKey:[_paymentModeName objectAtIndex:[payInfoDoc.pay_Mode integerValue]]]];
//            }
            self.paymentHistoryDoc.paymentRemark = [dict objectForKey:@"Remark"];
            if (_page > 0)
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"余额"]];
            NSString *nameString = [self.paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:(nameString.length > 0 ? nameString : @"无" )forKey:@"业绩参与"]];
            if (self.paymentHistoryDoc.paymentRemark.length > 0){
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"备注"]];
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentRemark forKey:nil]];
            }
            [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
            
            //支付方式modle
            self.paymentHistoryDoc.paymentMode = [[NSMutableArray alloc] init];
            for (int i=0; i<[[dict objectForKey:@"PaymentDetailList"] count]; i++) {
                NSDictionary * dic = [[dict objectForKey:@"PaymentDetailList"] objectAtIndex:i];
                PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                payInfoDoc.pay_Mode = [[dic objectForKey:@""] integerValue];
                payInfoDoc.pay_Amount = [[dic objectForKey:@""] doubleValue];
                payInfoDoc.cardPay_Amount = [[dic objectForKey:@""] doubleValue];
                payInfoDoc.card_name = [dic objectForKey:@""];
                
                [self.paymentHistoryDoc.paymentMode addObject:payInfoDoc];
            }
            
            //多比订单Arr
            NSArray *orderPayArray = [dict objectForKey:@"OrderList"];
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            if((NSNull *)orderPayArray != [NSNull null]){
                for(NSDictionary *obj in orderPayArray)
                {
                    tmpArray = [NSMutableArray array];
                    OrderPaymentDoc *orderPaymentDoc = [[OrderPaymentDoc alloc] init];
                    orderPaymentDoc.orderId = [[obj objectForKey:@"ID"] integerValue];
                    orderPaymentDoc.orderNumber = [obj objectForKey:@"OrderNumber"];
                    orderPaymentDoc.orderPaymentName = [obj objectForKey:@"ProductName"];
                    orderPaymentDoc.orderPaymentMoney = [[obj objectForKey:@"OrderPrice"] doubleValue];
                    orderPaymentDoc.orderType = [[obj objectForKey:@"ProductType"] integerValue];
                    
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderNumber forKey:@"订单编号"]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderPaymentName forKey:nil]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon, orderPaymentDoc.orderPaymentMoney] forKey:@"订单金额"]];
                    [tmpArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
                }
            }
            [_tableView reloadData];

        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        
    }];
    
    /*
    _requestGetPaymentDetailOperation = [[GPHTTPClient shareClient] requestGetPaymentDetailByID:Id withSuccess:^(id xml) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data ,id message) {
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            self.paymentHistoryDoc.paymentDispalyArray = [NSMutableArray array];
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            NSDictionary *dict = (NSDictionary *)data;
            
            self.paymentHistoryDoc.paymentTime = [dict objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dict objectForKey:@"PaymentTime"];
            self.paymentHistoryDoc.paymentOperator = [dict objectForKey:@"Operator"];
            self.paymentHistoryDoc.paymentTotalMoney = [[dict objectForKey:@"TotalPrice"] doubleValue];
            //self.paymentHistoryDoc.paymentBalanceLeft = [[dict objectForKey:@"Balance"] doubleValue];
            self.paymentHistoryDoc.paymentTime = [self.paymentHistoryDoc.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
            
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentTime forKey:@"支付时间"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentOperator forKey:@"操作人"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon,self.paymentHistoryDoc.paymentTotalMoney] forKey:@"支付总金额"]];
            
            for (PayInfoDoc *payInfoDoc in self.paymentHistoryDoc.paymentMode) {
                switch ([payInfoDoc.pay_Mode integerValue]) {
                    case 2:
                        payInfoDoc.pay_Amount = [[dict objectForKey:@"BankCard"] doubleValue];
                        break;
                    case 1:
                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Ecard"] doubleValue];
                        break;
                    case 0:
                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Cash"] doubleValue];
                        break;
                    case 3:
                        payInfoDoc.pay_Amount = [[dict objectForKey:@"Others"] doubleValue];
                        break;
                }
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon,payInfoDoc.pay_Amount] forKey:[_paymentModeName objectAtIndex:[payInfoDoc.pay_Mode integerValue]]]];
            }
            
            self.paymentHistoryDoc.paymentRemark = [dict objectForKey:@"Remark"];
            if (_page > 0)
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"余额"]];
            if (self.paymentHistoryDoc.paymentRemark.length > 0){
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"备注"]];
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentRemark forKey:nil]];
            }
            [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
            
            NSArray *orderPayArray = [dict objectForKey:@"OrderList"];
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            if((NSNull *)orderPayArray != [NSNull null]){
                for(NSDictionary *obj in orderPayArray)
                {
                    tmpArray = [NSMutableArray array];
                    OrderPaymentDoc *orderPaymentDoc = [[OrderPaymentDoc alloc] init];
                    orderPaymentDoc.orderId = [[obj objectForKey:@"ID"] integerValue];
                    orderPaymentDoc.orderNumber = [obj objectForKey:@"OrderNumber"];
                    orderPaymentDoc.orderPaymentName = [obj objectForKey:@"ProductName"];
                    orderPaymentDoc.orderPaymentMoney = [[obj objectForKey:@"OrderPrice"] doubleValue];
                    orderPaymentDoc.orderType = [[obj objectForKey:@"ProductType"] integerValue];
                    
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderNumber forKey:@"订单编号"]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderPaymentName forKey:nil]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@%.2f",MoneyIcon, orderPaymentDoc.orderPaymentMoney] forKey:@"订单金额"]];
                    [tmpArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
                }
            }
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSString *error) {
            [SVProgressHUD dismiss];
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
     */
}

@end
