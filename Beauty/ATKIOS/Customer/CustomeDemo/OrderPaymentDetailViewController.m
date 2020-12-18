//
//  OrderPaymentDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-11-19.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderPaymentDetailViewController.h"
#import "PaymentHistoryDoc.h"
#import "TwoElementDoc.h"
#import "AFHTTPClient.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "ZWJson.h"
#import "PayInfoDoc.h"
#import "OrderDetailViewController.h"
#import "OrderDoc.h"
#import "TitleView.h"
#import "PaymentHistoryDoc.h"
#import "PayInfoDoc.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "OrderDetailAboutServiceViewController.h"

@interface OrderPaymentDetailViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetOrderPaymentDetailOperation;
@property(nonatomic,strong)NSMutableArray * payOrderListArr;
@end

@implementation OrderPaymentDetailViewController
@synthesize payOrderListArr;
#pragma  mark -
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    _tableView.frame = CGRectMake(0,0,kSCREN_BOUNDS.size.width , kSCREN_BOUNDS.size.height -kNavigationBar_Height + 20);
    self.title = @"订单支付详情";
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPaymentDetailByOrderId:_orderID];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderPaymentDetailOperation || [_requestGetOrderPaymentDetailOperation isExecuting]) {
        [_requestGetOrderPaymentDetailOperation cancel];
        _requestGetOrderPaymentDetailOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}
#pragma mark - UItableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paymentHistoryArray.count+ payOrderListArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section >= self.paymentHistoryArray.count) { //订单
        return 3;
    }else{
        PaymentHistoryDoc *paymentHistory = [self.paymentHistoryArray objectAtIndex:section];
        return  5
        + paymentHistory.paymentMode.count  + (paymentHistory.paymentRemark.length > 0 ? 2 : 0);
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.paymentHistoryArray.count) {
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7){
            NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
        }
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 5) {
            NSString *accString = [paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
            NSInteger height = [accString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height + 18;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight :height;
        }
    }
    return kTableView_DefaultCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"Remark";
    UITableViewCell *cell = nil;
    NSString *identify1 =[NSString stringWithFormat:@"TwoElement_%ld_%ld",(long)indexPath.row,(long)indexPath.section];
    cell = [tableView dequeueReusableCellWithIdentifier:identify1];
    if(!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify1];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = kColor_White;
    UILabel *title = (UILabel *)[ cell viewWithTag:1000];
    if(!title){
        title = [[UILabel alloc] initWithFrame:CGRectMake(((IOS6) ? 20.f : 10.f), 15, 100, kLabel_DefaultHeight)];
        [cell addSubview:title];
    }
    title.textColor = kColor_TitlePink;
    title.tag = 1000;
    title.font = kNormalFont_14;
    
    UILabel *value = (UILabel *)[ cell viewWithTag:1001];
    if(!value){
        value = [[UILabel alloc] init];
        [cell addSubview:value];
    }
    value.frame = CGRectMake(120 + ((IOS6) ? 20.f : 10.f), 15, 180, kLabel_DefaultHeight);
    value.textColor = kColor_Black;
    value.font = kNormalFont_14;
    value.tag = 1001;
    value.textAlignment  = NSTextAlignmentRight;
    if (indexPath.section >= self.paymentHistoryArray.count &&payOrderListArr.count>0) {//订单
        NSDictionary * dic = [payOrderListArr objectAtIndex:indexPath.section-self.paymentHistoryArray.count];
        switch (indexPath.row) {
            case 0:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                value.frame = CGRectMake(120 + ((IOS6) ? 20.f : 10.f), 15, 160, kLabel_DefaultHeight);
                title.text = @"订单编号";
                value.text = [dic objectForKey:@"OrderNumber"];
                return cell;
                break;
            case 1:
                title.frame = CGRectMake(((IOS6) ? 20.f : 10.f), 15, 160, kLabel_DefaultHeight);
                title.text = [dic objectForKey:@"ProductName"];
                return cell;
                break;
            case 2:
                title.text = @"订单金额";
                value.text = [NSString stringWithFormat:@"%@%.2f" ,CUS_CURRENCYTOKEN,[[dic objectForKey:@"TotalSalePrice"]doubleValue]];
                return cell;
                break;
                
            default:
                break;
        }
    }else{
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        //备注内容部分
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7) {
            cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell)
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
            NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 0, ((IOS6) ? 310.f : 300.f), (height <= kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height))];
            textView.font = kNormalFont_14;
            textView.scrollEnabled = NO;
            textView.editable = NO;
            textView.text = paymentHistoryDoc.paymentRemark;
            textView.backgroundColor = [UIColor clearColor];
            cell = [[UITableViewCell alloc]init];
            cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [cell addSubview:textView];
            cell.backgroundColor = kColor_White;
            return cell;
        }
        else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 6)
        {
            title.text = @"备注";
            value.text = @"";
            return cell;
        }
        else if(indexPath.row == 0){
            title.text = @"支付编号";
            value.text = paymentHistoryDoc.paymentCodeString;
            return cell;
        }else if (indexPath.row == 1){
            title.text = @"支付时间";
            value.text = paymentHistoryDoc.paymentTime;
            return cell;
        }else if(indexPath.row ==2){
            title.text = @"支付门店";
            value.text = paymentHistoryDoc.branchName;
            return cell;
        }else if (indexPath.row == 3) {
            title.text = @"操作人";
            value.text = paymentHistoryDoc.paymentOperator;
            return cell;
        }else if (indexPath.row == 4) {
            title.text = @"支付总金额";
            value.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN, paymentHistoryDoc.paymentTotalMoney];
            return cell;
        }else if(indexPath.row>4 && indexPath.row < 5 + paymentHistoryDoc.paymentMode.count )
        {
            PayInfoDoc *payInfoDoc = [paymentHistoryDoc.paymentMode objectAtIndex:indexPath.row-5];
            title.frame=CGRectMake(30,15,110, 20);
            title.text = [NSString stringWithFormat:@"%@",payInfoDoc.card_name];
            title.textColor = kColor_Black;
            value.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,payInfoDoc.pay_Amount];
            
            if ([payInfoDoc.pay_Mode integerValue] == 6 || [payInfoDoc.pay_Mode integerValue] == 7) {
                UILabel *lableRemove = (UILabel *)[cell viewWithTag:indexPath.section*100+indexPath.row];
                [lableRemove removeFromSuperview];
                UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 110, 20)];
                lable.textColor = kColor_Black;
                lable.font = kNormalFont_14;
                lable.textAlignment  = NSTextAlignmentRight;
                lable.tag = indexPath.section*100+indexPath.row;
                if (payInfoDoc.cardType ==2) {
                    lable.text = [NSString stringWithFormat:@"%.2Lf 抵",payInfoDoc.cardPay_Amount];
                }else
                    lable.text = [NSString stringWithFormat:@"%@%.2Lf 抵",CUS_CURRENCYTOKEN,payInfoDoc.cardPay_Amount];
                [cell addSubview:lable];
                if ([payInfoDoc.pay_Mode integerValue] == 6){
                    value.text = [NSString stringWithFormat:@"%@%.2Lf",CUS_CURRENCYTOKEN,payInfoDoc.pay_Amount];
                }
            }
        }
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.section >= self.paymentHistoryArray.count &&payOrderListArr.count>0) {//订单
         NSDictionary * dic = [payOrderListArr objectAtIndex:indexPath.section-self.paymentHistoryArray.count];
        
        OrderDoc * orderDoc = [[OrderDoc alloc] init];
        orderDoc.order_ObjectID = [[dic objectForKey:@"OrderObjectID"] integerValue];
         
        orderDoc.orderID = [[dic objectForKey:@"OrderID"] integerValue];
        orderDoc.order_ID = [[dic objectForKey:@"OrderID"] integerValue];
         
        orderDoc.order_Type = [[dic objectForKey:@"ProductType"] integerValue];
        orderDoc.productType = [[dic objectForKey:@"ProductType"] integerValue];
        if ([orderDoc productType] == 1) {//商品
            OrderDetailAboutCommodityViewController *commod = (OrderDetailAboutCommodityViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutCommodityViewController"];
            commod.orderDoc = orderDoc;
            [self.navigationController pushViewController:commod animated:YES];
        }else
        {
            OrderDetailAboutServiceViewController *serve =  (OrderDetailAboutServiceViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailAboutServiceViewController"];
            serve.orderDoc = orderDoc;
            [self.navigationController pushViewController:serve animated:YES];
        }
     }
}

#pragma mark - 接口
-(void)getPaymentDetailByOrderId:(NSInteger)orderID{
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSDictionary *para = @{@"OrderID":@(orderID)};
    _requestGetOrderPaymentDetailOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/payment/GetPaymentDetailByOrderID"  showErrorMsg:YES  parameters:para
     WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            if (self.paymentHistoryArray)
                [self.paymentHistoryArray removeAllObjects];
            else
                self.paymentHistoryArray = [[NSMutableArray alloc] init];
            for ( NSDictionary *dict in data){

                payOrderListArr = [[NSMutableArray alloc] init];
                if ([[dict allKeys] containsObject:@"PaymentOrderList"]){
                    if (![[dict objectForKey:@"PaymentOrderList"] isKindOfClass:[NSNull class]]) {
                        [payOrderListArr addObjectsFromArray:[dict objectForKey:@"PaymentOrderList"]];//orderList
                    }
                }
                PaymentHistoryDoc *payment = [[PaymentHistoryDoc alloc] init];
                payment.paymentTime = [dict objectForKey:@"PaymentTime"] == [NSNull null] ? nil : [dict objectForKey:@"PaymentTime"];
                payment.paymentOperator = [dict objectForKey:@"Operator"];
                payment.paymentTotalMoney = [[dict objectForKey:@"TotalPrice"] doubleValue];
                payment.paymentTime = [payment.paymentTime stringByReplacingOccurrencesOfString:@"T" withString:@" "];
                payment.paymentNumber = [[dict objectForKey:@"OrderNumber"] integerValue];
                payment.paymentCodeString = [dict objectForKey:@"PaymentCode"];
                
                NSArray *proList = [dict objectForKey:@"ProfitList"] == [NSNull null] ? nil : [dict objectForKey:@"ProfitList"];
                NSMutableArray *tmp = [NSMutableArray array];
                for (NSDictionary *proDic in proList) {
                    NSString *accountName = [proDic objectForKey:@"AccountName"];
                    [tmp addObject:accountName];
                }
                payment.accArray = tmp;
                payment.paymentMode = [[NSMutableArray alloc] init];
                

                for (int i=0; i<[[dict objectForKey:@"PaymentDetailList"] count]; i++) {
                    NSDictionary * dic = [[dict objectForKey:@"PaymentDetailList"] objectAtIndex:i];
                    PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                    payInfoDoc.pay_Mode = [dic objectForKey:@"PaymentMode"];
                    payInfoDoc.pay_Amount = [[dic objectForKey:@"PaymentAmount"] doubleValue];
                    payInfoDoc.cardPay_Amount = [[dic objectForKey:@"CardPaidAmount"] doubleValue];
                    payInfoDoc.card_name = [dic objectForKey:@"CardName"];
                    payInfoDoc.cardType = [[dic objectForKey:@"CardType"] integerValue];
                    payment.paymentRemark = [dict objectForKey:@"Remark"];
                    payment.branchName = [dict objectForKey:@"BranchName"];
                    [payment.paymentMode addObject:payInfoDoc];
                }
                [self.paymentHistoryArray addObject:payment];
            }
            [_tableView reloadData];
             [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
             [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}


@end
