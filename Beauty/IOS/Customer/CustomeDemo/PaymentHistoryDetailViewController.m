//
//  PaymentHistoryDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-7.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "PaymentHistoryDetailViewController.h"
#import "TwoElementDoc.h"
#import "AFHTTPClient.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "ZWJson.h"
#import "PayInfoDoc.h"
#import "OrderDetailAboutServiceViewController.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "OrderDoc.h"

@interface PaymentHistoryDetailViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetPaymentDetailOperation;
@property (strong, nonatomic) NSArray *paymentModeName;
@property (strong, nonatomic) OrderPaymentDoc *orderPaymentDoc;
@property (strong, nonatomic) TitleView *titleView;
@end

@implementation PaymentHistoryDetailViewController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        _tableView.frame = CGRectMake(0, 40.0f, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 87.0f);
    }

    _paymentModeName =[NSArray arrayWithObjects:@"现金",@"e卡",@"银行卡", @"其他",nil];
    
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
//    [_titleView getTitleView:(_page == 0 ? @"支付详情":@"e卡支付详情")];
    self.title = (_page == 0 ? @"支付详情":@"e卡支付详情");
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
        return  4 + self.paymentHistoryDoc.paymentMode.count + _page + (self.paymentHistoryDoc.isRemark ? 2 : 0);
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.row == 4 + self.paymentHistoryDoc.paymentMode.count + _page){
        NSInteger height = [self.paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
        return height < 38 ? 38 : height;
    }
    return kTableView_HeightOfRow;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        //备注内容部分
        if(indexPath.row == self.paymentHistoryDoc.paymentMode.count + 4  + _page) {
            NSInteger height = [self.paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, 300, (height <= 38 ? 34 : height))];
            textView.font = kFont_Light_16;
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.text = ((TwoElementDoc *)[[self.paymentHistoryDoc.paymentDispalyArray objectAtIndex:0] objectAtIndex:indexPath.row - _page]).secondElement;
            UITableViewCell *cell = [[UITableViewCell alloc]init];
            cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell addSubview:textView];
            return cell;
        }
    }
    
    static NSString *identify = @"MyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    TwoElementDoc *twoElement = (TwoElementDoc *)[[self.paymentHistoryDoc.paymentDispalyArray objectAtIndex:indexPath.section] objectAtIndex: indexPath.row];
    UILabel *title = (UILabel *)[ cell viewWithTag:1000];
    if(!title){
        title = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 100, 20)];
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
    value.frame = CGRectMake(120, 8, 180, 20);
    value.textColor = kColor_Black;
    value.font = kFont_Light_16;
    value.tag = 1001;
    //如果是订单的名字， 则特殊处理
    if(indexPath.section > 0 && indexPath.row == 1){
        title.frame = CGRectMake(10, 8, 300, 20);
        title.textColor = kColor_Black;
        title.text = twoElement.secondElement;
        value.text = @"";
    }else if(indexPath.section > 0 && indexPath.row == 0){
        value.frame = CGRectMake(120, 8, 160, 20);
        value.text = twoElement.secondElement;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }else
        value.text = twoElement.secondElement;
    value.textAlignment  = NSTextAlignmentRight;
    
    if ((indexPath.section == 0 && indexPath.row > 2 && indexPath.row < self.paymentHistoryDoc.paymentMode.count + 3)  && _page == 0)
        title.textColor = kColor_Black;
    else
        title.textColor = kColor_TitlePink;
    
    //如果是订单的名字， 则特殊处理
    if (_page == 1 && indexPath.section > 0 && indexPath.row == 1)
        title.textColor = kColor_Black;
    
    if (_page == 1 && indexPath.section == 0 && indexPath.row == 4) {
        title.text = @"e卡";
        title.textColor = kColor_Black;
    }
    if(_page == 1 && indexPath.section == 0 && indexPath.row == 5){ //从e卡页跳过来时
        title.text = @"余额";
        value.text =  [NSString stringWithFormat:@"%@ %.2Lf", CUS_CURRENCYTOKEN, self.paymentHistoryDoc.paymentBalanceLeft];
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section > 0 && indexPath.row == 0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        _orderPaymentDoc = [self.paymentHistoryDoc.paymentArray objectAtIndex:indexPath.section - 1];
        if (_orderPaymentDoc.orderType == 1)
            [self performSegueWithIdentifier:@"gotoCommodityOrderDetailFromHistory" sender:self];
        else
            [self performSegueWithIdentifier:@"gotoServiceOrderDetailFromHistory" sender:self];
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
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"gotoCommodityOrderDetailFromHistory"]){
        OrderDetailAboutServiceViewController *service  = segue.destinationViewController;
        service.orderDoc = [[OrderDoc alloc] init];
        service.orderDoc.order_ID = _orderPaymentDoc.orderId;
        service.orderDoc.order_Type = _orderPaymentDoc.orderType;
    }else {
        OrderDetailAboutCommodityViewController *commodity  = segue.destinationViewController;
        commodity.orderDoc = [[OrderDoc alloc] init];
        commodity.orderDoc.order_ID = _orderPaymentDoc.orderId;
        commodity.orderDoc.order_Type = _orderPaymentDoc.orderType;
    }
}

#pragma mark - 接口
- (void)getPaymentDetailById:(NSInteger)Id
{
    [SVProgressHUD showWithStatus:@"Loading"];

    NSDictionary *para = @{ @"PaymentID":@(Id) };
    _requestGetPaymentDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Payment/getPaymentDetail"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            self.paymentHistoryDoc.paymentDispalyArray = [NSMutableArray array];
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            NSDictionary *dict = (NSDictionary *)data;
            self.paymentHistoryDoc.paymentCode = dict[@"PaymentCode"] == [NSNull null] ? nil : dict[@"PaymentCode"];
            self.paymentHistoryDoc.paymentTime = dict[@"PaymentTime"] == [NSNull null] ? nil : dict[@"PaymentTime"];
            self.paymentHistoryDoc.paymentOperator = dict[@"Operator"] == [NSNull null] ? nil : dict[@"Operator"];
            self.paymentHistoryDoc.paymentTotalMoney = [dict[@"TotalPrice"] doubleValue];
            
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentCode forKey:@"支付编号"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentTime forKey:@"支付时间"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentOperator forKey:@"操作人"]];
            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,self.paymentHistoryDoc.paymentTotalMoney] forKey:@"支付总金额"]];
            
            for (PayInfoDoc *payInfoDoc in self.paymentHistoryDoc.paymentMode) {
                switch ([payInfoDoc.pay_Mode integerValue]) {
                    case 2: payInfoDoc.pay_Amount = [dict[@"BankCard"] doubleValue]; break;
                    case 1: payInfoDoc.pay_Amount = [dict[@"Ecard"] doubleValue]; break;
                    case 0: payInfoDoc.pay_Amount = [dict[@"Cash"] doubleValue]; break;
                    case 3: payInfoDoc.pay_Amount = [dict[@"Others"] doubleValue]; break;
                }
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,payInfoDoc.pay_Amount] forKey:[_paymentModeName objectAtIndex:[payInfoDoc.pay_Mode integerValue]]]];
            }
            self.paymentHistoryDoc.paymentRemark = dict[@"Remark"];
            if (_page > 0)
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"余额"]];
            if (self.paymentHistoryDoc.paymentRemark.length > 0){
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"备注"]];
                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentRemark forKey:nil]];
            }
            [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
            
            NSArray *orderPayArray = dict[@"OrderList"];
            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
            if((NSNull *)orderPayArray != [NSNull null]){
                for(NSDictionary *obj in orderPayArray)
                {
                    tmpArray = [NSMutableArray array];
                    OrderPaymentDoc *orderPaymentDoc = [[OrderPaymentDoc alloc] init];
                    orderPaymentDoc.orderId = [obj[@"ID"] integerValue];
                    orderPaymentDoc.orderNumber = [NSString stringWithFormat:@"%lld",[obj[@"OrderNumber"] longLongValue]];
                    orderPaymentDoc.orderPaymentName = obj[@"ProductName"];
                    orderPaymentDoc.orderPaymentMoney = [obj[@"OrderPrice"] doubleValue];
                    orderPaymentDoc.orderType = [obj[@"ProductType"] integerValue];
                    
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderNumber forKey:@"订单编号"]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderPaymentName forKey:nil]];
                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN, orderPaymentDoc.orderPaymentMoney] forKey:@"订单金额"]];
                    [tmpArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentArray addObject:orderPaymentDoc];
                    [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
                }
            }
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {

    }];
//    _requestGetPaymentDetailOperation = [[GPHTTPClient shareClient] requestGetPaymentDetailByID:Id withSuccess:^(id xml) {
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:NO success:^(id data, NSInteger code,  id message) {
//            
//            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
//            self.paymentHistoryDoc.paymentDispalyArray = [NSMutableArray array];
//            NSMutableArray *tmpArray = [NSMutableArray array];
//            
//            NSDictionary *dict = (NSDictionary *)data;
//            
//            self.paymentHistoryDoc.paymentTime = dict[@"PaymentTime"];
//            self.paymentHistoryDoc.paymentOperator = dict[@"Operator"];
//            self.paymentHistoryDoc.paymentTotalMoney = [dict[@"TotalPrice"] floatValue];
//            self.paymentHistoryDoc.paymentTime = [self.paymentHistoryDoc.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
//            
//            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentTime forKey:@"支付时间"]];
//            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentOperator forKey:@"操作人"]];
//            [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN,self.paymentHistoryDoc.paymentTotalMoney] forKey:@"支付总金额"]];
//            
//            for (PayInfoDoc *payInfoDoc in self.paymentHistoryDoc.paymentMode) {
//                switch ([payInfoDoc.pay_Mode integerValue]) {
//                    case 2:
//                        payInfoDoc.pay_Amount = [dict[@"BankCard"] floatValue];
//                        break;
//                    case 1:
//                        payInfoDoc.pay_Amount = [dict[@"Ecard"] floatValue];
//                        break;
//                    case 0:
//                        payInfoDoc.pay_Amount = [dict[@"Cash"] floatValue];
//                        break;
//                    case 3:
//                        payInfoDoc.pay_Amount = [dict[@"Others"] floatValue];
//                        break;
//                }
//                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN,payInfoDoc.pay_Amount] forKey:[_paymentModeName objectAtIndex:[payInfoDoc.pay_Mode integerValue]]]];
//            }
//            
//            self.paymentHistoryDoc.paymentRemark = dict[@"Remark"];
//            if (_page > 0)
//                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"余额"]];
//            if (self.paymentHistoryDoc.paymentRemark.length > 0){
//                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:nil forKey:@"备注"]];
//                [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:self.paymentHistoryDoc.paymentRemark forKey:nil]];
//            }
//            [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
//            
//            NSArray *orderPayArray = dict[@"OrderList"];
//            self.paymentHistoryDoc.paymentArray = [NSMutableArray array];
//            if((NSNull *)orderPayArray != [NSNull null]){
//                for(NSDictionary *obj in orderPayArray)
//                {
//                    tmpArray = [NSMutableArray array];
//                    OrderPaymentDoc *orderPaymentDoc = [[OrderPaymentDoc alloc] init];
//                    orderPaymentDoc.orderId = [obj[@"ID"] integerValue];
//                    orderPaymentDoc.orderNumber = obj[@"OrderNumber"];
//                    orderPaymentDoc.orderPaymentName = obj[@"ProductName"];
//                    orderPaymentDoc.orderPaymentMoney = [obj[@"OrderPrice"] floatValue];
//                    orderPaymentDoc.orderType = [obj[@"ProductType"] integerValue];
//                    
//                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderNumber forKey:@"订单编号"]];
//                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:orderPaymentDoc.orderPaymentName forKey:nil]];
//                    [tmpArray addObject:[[TwoElementDoc alloc] initWithValue:[NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN, orderPaymentDoc.orderPaymentMoney] forKey:@"订单金额"]];
//                    [tmpArray addObject:orderPaymentDoc];
//                    [self.paymentHistoryDoc.paymentArray addObject:orderPaymentDoc];
//                    [self.paymentHistoryDoc.paymentDispalyArray addObject:tmpArray];
//                }
//            }
//            [_tableView reloadData];
//            [SVProgressHUD dismiss];
//        } failure:^( NSInteger code, NSString *error) {
//            [SVProgressHUD dismiss];
//        }];
//
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}

@end
