//
//  OrderPaymentDetailViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 14-11-19.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "OrderPaymentDetailViewController.h"
#import "PaymentHistoryDoc.h"
#import "TwoElementDoc.h"
#import "AFHTTPClient.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GPBHTTPClient.h"
#import "PayInfoDoc.h"
#import "OrderDetailViewController.h"
#import "OrderDoc.h"
#import "TitleView.h"
#import "AppDelegate.h"
#import "ProfitListRes.h"
#import "PerformanceTableViewCell.h"
#import "SalesConsultantListRes.h"


@interface OrderPaymentDetailViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetOrderPaymentDetailOperation;
@property(nonatomic,strong)NSMutableArray * payOrderListArr;
/*是否显示业绩参与*/
@property (nonatomic ,strong) NSNumber * isComissionCalc;
@end

@implementation OrderPaymentDetailViewController
@synthesize payOrderListArr;
@synthesize isComissionCalc;
#pragma  mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    isComissionCalc = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_isComissionCalc"];
    TitleView *titleView = [[TitleView alloc] init];
    [titleView getTitleView:@"订单支付详情"];
    [self.view addSubview:titleView];
    
    _tableView.allowsSelection = YES;
    _tableView.autoresizingMask = UIViewAutoresizingNone;
    _tableView.showsVerticalScrollIndicator = YES;
    _tableView.backgroundView = nil;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.frame = CGRectMake(5.0f, titleView.frame.origin.y + titleView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f -  5.0f);
    if (IOS7 || IOS8) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
}
- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
        if(self.isComissionCalc.boolValue)
        {
            return  10 + paymentHistory.paymentMode.count  + (paymentHistory.paymentRemark.length > 0 ? 2 : 0) + paymentHistory.profitListArrs.count + paymentHistory.salesConsultantListArrs.count;
        }
        else
        {
            return  7 + paymentHistory.paymentMode.count  + (paymentHistory.paymentRemark.length > 0 ? 2 : 0);
        }
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.paymentHistoryArray.count) {
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7){
            NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(300.f, 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < 38 ? 38 : height;
        }
        //        if(indexPath.row == paymentHistoryDoc.paymentMode.count + 5) {
        //            NSString *accString = [paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
        //            NSInteger height = [accString sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height + 18;
        //            return height < 38 ? 38 :height;
        //        }
    }
    
    return kTableView_HeightOfRow;
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
        title = [[UILabel alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 8, 120, 20)];
        [cell addSubview:title];
    }
    title.textColor = kColor_DarkBlue;
    title.tag = 1000;
    title.font = kFont_Light_16;
    
    UILabel *value = (UILabel *)[ cell viewWithTag:1001];
    if(!value){
        value = [[UILabel alloc] init];
        [cell addSubview:value];
    }
    value.frame = CGRectMake(160 + ((IOS6) ? 20.f : 10.f), 8, 135, 20);
    value.textColor = kColor_Black;
    value.font = kFont_Light_16;
    value.tag = 1001;
    value.textAlignment  = NSTextAlignmentRight;
    if (indexPath.section >= self.paymentHistoryArray.count &&payOrderListArr.count>0) {//订单
        NSDictionary * dic = [payOrderListArr objectAtIndex:indexPath.section-self.paymentHistoryArray.count];
        switch (indexPath.row) {
            case 0:
            {
                UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
                arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
                [cell.contentView addSubview:arrowsImage];
                
                value.frame = CGRectMake(130 + ((IOS6) ? 20.f : 10.f), 8, 155, 20);
                title.text = @"订单编号";
                value.text = [dic objectForKey:@"OrderNumber"];
                return cell;
            }
                break;
            case 1:
                title.text = [dic objectForKey:@"ProductName"];
                //                value.text = paymentHistoryDoc.paymentTime;
                return cell;
                break;
            case 2:
                title.text = @"订单金额";
                value.text = [NSString stringWithFormat:@"%@%.2f" ,MoneyIcon,[[dic objectForKey:@"TotalSalePrice"]doubleValue]];
                return cell;
                break;
                
            default:
                break;
        }
    }else{
        PaymentHistoryDoc *paymentHistoryDoc = [self.paymentHistoryArray objectAtIndex:indexPath.section];
        //显示提成比例
        if(self.isComissionCalc.boolValue)
        {
            //备注内容部分
            if(indexPath.row == paymentHistoryDoc.paymentMode.count + 10 + paymentHistoryDoc.profitListArrs.count + paymentHistoryDoc.salesConsultantListArrs.count) {
                cell = [tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
                NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 0, ((IOS6) ? 310.f : 300.f), (height <= 38 ? 34 : height))];
                textView.font = kFont_Light_16;
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
            else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 6){
                return [self configBranchSalesConsultantCell:tableView indexPath:indexPath];
            }else if((indexPath.row > paymentHistoryDoc.paymentMode.count + 6)  && (indexPath.row < paymentHistoryDoc.paymentMode.count + 7 + paymentHistoryDoc.salesConsultantListArrs.count) ){
                return [self configBranchSalesConsultantRateCell:tableView indexPath:indexPath paymentHistoryDoc:paymentHistoryDoc];
            }
            else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7 + paymentHistoryDoc.salesConsultantListArrs.count){
                value.frame = CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 215, 20);
                title.text = @"业绩参与金额";
                value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon, paymentHistoryDoc.salesConsultantMonery];
                return cell;
            }
            else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 8 + paymentHistoryDoc.salesConsultantListArrs.count){
                title.text = @"业绩参与";
                value.text = paymentHistoryDoc.profitListArrs.count == 0 ?@"无":@"";
                //            NSString *name = [paymentHistoryDoc.accArray componentsJoinedByString:@"、"];
                //            NSInteger height = [name sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(180, 70) lineBreakMode:NSLineBreakByCharWrapping].height;
                //            if (height > 20) {
                //                value.frame = CGRectMake(130 + ((IOS6) ? 20.f : 10.f), 8, 160, height);
                //                value.numberOfLines = 0;
                //                value.textAlignment = NSTextAlignmentLeft;
                //            }
                //            value.text = (name.length > 0 ? name:@"无");
                return cell;
            }else if((indexPath.row > paymentHistoryDoc.paymentMode.count + 8+ paymentHistoryDoc.salesConsultantListArrs.count)  && (indexPath.row < paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.salesConsultantListArrs.count + paymentHistoryDoc.profitListArrs.count) ){
                return [self configPerformanceProportionCell:tableView indexPath:indexPath paymentHistoryDoc:paymentHistoryDoc];
            }
            else if(indexPath.row == paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.profitListArrs.count + paymentHistoryDoc.salesConsultantListArrs.count)
            {
                title.text = @"备注";
                value.text = @"";
                return cell;
            }
            else if(indexPath.row == 0){
                title.text = @"交易编号";
                //            value.textColor = [UIColor greenColor];
                value.text = paymentHistoryDoc.paymentCodeString;
                return cell;
            }else if (indexPath.row == 1){
                title.text = @"交易时间";
                //            value.textColor = [UIColor redColor];
                value.frame = CGRectMake(kSCREN_BOUNDS.size.width - 170, 8, 160, 20);
                value.text = paymentHistoryDoc.paymentTime;
                return cell;
            }else if(indexPath.row ==2){
                title.text = @"交易门店";
                value.text = paymentHistoryDoc.BranchName;
                return cell;
            }else if (indexPath.row == 3) {
                title.text = @"交易类型";
                value.text = paymentHistoryDoc.paymentTypeStr;
                return cell;
            }
            else if (indexPath.row == 4) {
                title.text = @"操作人";
                value.text = paymentHistoryDoc.paymentOperator;
                return cell;
            }else if (indexPath.row == 5) {
                value.frame = CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 215, 20);
                title.text = @"交易总金额";
                value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon, paymentHistoryDoc.paymentTotalMoney];
                return cell;
            }else if(indexPath.row>5 && indexPath.row < 6 + paymentHistoryDoc.paymentMode.count )
            {
                PayInfoDoc *payInfoDoc = [paymentHistoryDoc.paymentMode objectAtIndex:indexPath.row-6];
                title.text = [NSString stringWithFormat:@"%@",payInfoDoc.card_name];
                title.textColor = kColor_Black;
                value.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,payInfoDoc.pay_Amount];
                
                if (payInfoDoc.pay_Mode == 6 || payInfoDoc.pay_Mode ==7) {
                    UILabel *lableRemove = (UILabel *)[cell viewWithTag:indexPath.section*100+indexPath.row];
                    [lableRemove removeFromSuperview];
                    UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(50 + ((IOS6) ? 20.f : 10.f), 8, 110, 20)];
                    lable.textColor = kColor_Black;
                    lable.font = kFont_Light_16;
                    lable.textAlignment  = NSTextAlignmentRight;
                    lable.tag = indexPath.section*100+indexPath.row;
                    [cell addSubview:lable];
                    
                    
                    if (payInfoDoc.pay_Mode == 6){
                        
                        lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.pay_Amount];
                    }
                    
                    if (payInfoDoc.cardType ==2) {
                        lable.text = [NSString stringWithFormat:@"%.2f 抵",payInfoDoc.cardPay_Amount];
                    }else
                        lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.cardPay_Amount];
                    
                }
            }
        }
        //不显示提成比例
        else
        {
            //备注内容部分
            if(indexPath.row == paymentHistoryDoc.paymentMode.count + 7) {
                cell = [tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell)
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identify];
                NSInteger height = [paymentHistoryDoc.paymentRemark sizeWithFont:kFont_Light_16 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500.f) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(((IOS6) ? 10.f : 5.f), 0, ((IOS6) ? 310.f : 300.f), (height <= 38 ? 34 : height))];
                textView.font = kFont_Light_16;
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
                title.text = @"交易编号";
                //            value.textColor = [UIColor greenColor];
                value.text = paymentHistoryDoc.paymentCodeString;
                return cell;
            }else if (indexPath.row == 1){
                title.text = @"交易时间";
                //            value.textColor = [UIColor redColor];
                value.frame = CGRectMake(kSCREN_BOUNDS.size.width - 170, 8, 160, 20);
                value.text = paymentHistoryDoc.paymentTime;
                return cell;
            }else if(indexPath.row ==2){
                title.text = @"交易门店";
                value.text = paymentHistoryDoc.BranchName;
                return cell;
            }else if (indexPath.row == 3) {
                title.text = @"交易类型";
                value.text = paymentHistoryDoc.paymentTypeStr;
                return cell;
            }
            else if (indexPath.row == 4) {
                title.text = @"操作人";
                value.text = paymentHistoryDoc.paymentOperator;
                return cell;
            }else if (indexPath.row == 5) {
                value.frame = CGRectMake(80 + ((IOS6) ? 20.f : 10.f), 8, 215, 20);
                title.text = @"交易总金额";
                value.text = [NSString stringWithFormat:@"%@ %.2f",MoneyIcon, paymentHistoryDoc.paymentTotalMoney];
                return cell;
            }else if(indexPath.row>5 && indexPath.row < 6 + paymentHistoryDoc.paymentMode.count )
            {
                PayInfoDoc *payInfoDoc = [paymentHistoryDoc.paymentMode objectAtIndex:indexPath.row-6];
                title.text = [NSString stringWithFormat:@"%@",payInfoDoc.card_name];
                title.textColor = kColor_Black;
                value.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,payInfoDoc.pay_Amount];
                
                if (payInfoDoc.pay_Mode == 6 || payInfoDoc.pay_Mode ==7) {
                    UILabel *lableRemove = (UILabel *)[cell viewWithTag:indexPath.section*100+indexPath.row];
                    [lableRemove removeFromSuperview];
                    UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(50 + ((IOS6) ? 20.f : 10.f), 8, 110, 20)];
                    lable.textColor = kColor_Black;
                    lable.font = kFont_Light_16;
                    lable.textAlignment  = NSTextAlignmentRight;
                    lable.tag = indexPath.section*100+indexPath.row;
                    [cell addSubview:lable];
                    
                    
                    if (payInfoDoc.pay_Mode == 6){
                        
                        lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.pay_Amount];
                    }
                    
                    if (payInfoDoc.cardType ==2) {
                        lable.text = [NSString stringWithFormat:@"%.2f 抵",payInfoDoc.cardPay_Amount];
                    }else
                        lable.text = [NSString stringWithFormat:@"%@%.2f 抵",MoneyIcon,payInfoDoc.cardPay_Amount];
                    
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
#pragma mark -  配置cell
//业绩参与人比例
- (PerformanceTableViewCell *)configPerformanceProportionCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath paymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    
    NSString *identifier =[NSString stringWithFormat:@"PerformanceCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    
    performanceCell.numText.hidden = NO;
    performanceCell.percentLab.hidden = NO;
    performanceCell.numText.enabled = NO;
    NSLog(@"indexPath.row  == %ld",(long)indexPath.row);
    if (paymentHistoryDoc.profitListArrs.count > 0) {
        ProfitListRes *profitRes = [paymentHistoryDoc.profitListArrs objectAtIndex:indexPath.row - (paymentHistoryDoc.paymentMode.count + 9 + paymentHistoryDoc.salesConsultantListArrs.count)];
        performanceCell.nameLab.text = profitRes.accountName;
        double temp =  profitRes.profitPct.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
    }
    return performanceCell;
}


//分店销售顾问提成
- (PerformanceTableViewCell *)configBranchSalesConsultantCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantCell%@",indexPath];
    PerformanceTableViewCell *branchSalesConsultantRateCell= [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!branchSalesConsultantRateCell) {
        branchSalesConsultantRateCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    branchSalesConsultantRateCell.delegate = self;
    branchSalesConsultantRateCell.nameLab.text = @"销售顾问提成比例";
    [branchSalesConsultantRateCell.nameLab setFont:kFont_Light_16];
    [branchSalesConsultantRateCell.nameLab setTextColor:kColor_DarkBlue];
    CGRect tempFrame = branchSalesConsultantRateCell.nameLab.frame;
    tempFrame.origin.x -=43;
    tempFrame.size.width =branchSalesConsultantRateCell.nameLab.frame.size.width+5;
    branchSalesConsultantRateCell.nameLab.frame = tempFrame;
    branchSalesConsultantRateCell.numText.hidden = YES;
    branchSalesConsultantRateCell.percentLab.hidden = YES;
    branchSalesConsultantRateCell.numText.enabled = NO;
    
    return branchSalesConsultantRateCell;
}

//分店销售顾问提成比例
- (PerformanceTableViewCell *)configBranchSalesConsultantRateCell:(UITableView *)tableView  indexPath:(NSIndexPath *)indexPath paymentHistoryDoc:(PaymentHistoryDoc *)paymentHistoryDoc {
    
    //
    NSString *identifier =[NSString stringWithFormat:@"BranchSalesConsultantRateCell%@",indexPath];
    PerformanceTableViewCell *performanceCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!performanceCell) {
        performanceCell = [[NSBundle mainBundle]loadNibNamed:@"PerformanceTableViewCell" owner:self options:nil].firstObject;
    }
    performanceCell.delegate = self;
    performanceCell.numText.hidden = NO;
    performanceCell.percentLab.hidden = NO;
    performanceCell.numText.enabled = NO;
    
    if (paymentHistoryDoc.profitListArrs.count > 0) {
        SalesConsultantListRes *salesConRes = [paymentHistoryDoc.salesConsultantListArrs objectAtIndex:indexPath.row - (paymentHistoryDoc.paymentMode.count + 7)];
        performanceCell.nameLab.text = salesConRes.salesConsultantName;
        double temp =  salesConRes.commissionRate.doubleValue * 100;
        performanceCell.numText.text = [NSString stringWithFormat:@"%.2f",temp];
        
    }
    return performanceCell;
}


#pragma mark - didSelectRowAtIndexPath

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.paymentHistoryArray.count &&payOrderListArr.count>0) {//订单
        if (indexPath.row == 0) {
            NSDictionary * dic = [payOrderListArr objectAtIndex:indexPath.section-self.paymentHistoryArray.count];
            OrderDetailViewController *orderDetail = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
            orderDetail.orderID = [[dic objectForKey:@"OrderID"] integerValue];
            orderDetail.productType = [[dic objectForKey:@"ProductType"] integerValue];
            orderDetail.objectID  = [[dic objectForKey:@"OrderObjectID"] integerValue];
            [self.navigationController pushViewController:orderDetail animated:YES];
        }
    }
}

#pragma mark - 接口
-(void)getPaymentDetailByOrderId:(NSInteger)orderID{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary * par =@{
                          @"OrderID":@((long)self.orderID),
                          @"PaymentID":@((long)self.paymentId)
                          };
    
    _requestGetOrderPaymentDetailOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Payment/GetPaymentDetailByOrderID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            if (self.paymentHistoryArray)
                [self.paymentHistoryArray removeAllObjects];
            else
                self.paymentHistoryArray = [[NSMutableArray alloc] init];
            for ( NSDictionary *dict in data){
                NSLog(@"dict =%@",dict);
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
                
                //交易类型
                payment.paymentTypeStr = [dict objectForKey:@"TypeName"];
                
                //                NSArray *proList = [dict objectForKey:@"ProfitList"] == [NSNull null] ? nil : [dict objectForKey:@"ProfitList"];
                //                NSMutableArray *tmp = [NSMutableArray array];
                //                for (NSDictionary *proDic in proList) {
                //                    NSString *accountName = [proDic objectForKey:@"AccountName"];
                //                    [tmp addObject:accountName];
                //                }
                //                payment.accArray = tmp;
                
                NSArray *proList = [dict objectForKey:@"ProfitList"] == [NSNull null] ? nil : [dict objectForKey:@"ProfitList"];
                for (NSDictionary *proDic in proList) {
                    ProfitListRes *profitRes = [[ProfitListRes alloc]init];
                    profitRes.accountID = [proDic objectForKey:@"AccountID"];
                    profitRes.accountName = [proDic objectForKey:@"AccountName"];
                    profitRes.profitPct = [proDic objectForKey:@"ProfitPct"];
                    [payment.profitListArrs addObject:profitRes];
                }
                double salesRemainRate = 1.0;
                NSArray *salesConsultantList = [dict objectForKey:@"SalesConsultantRates"] == [NSNull null] ? nil : [dict objectForKey:@"SalesConsultantRates"];
                for (NSDictionary *salesConDic in salesConsultantList) {
                    SalesConsultantListRes *salesConRes = [[SalesConsultantListRes alloc]init];
                    salesConRes.salesConsultantID = [salesConDic objectForKey:@"SalesConsultantID"];
                    salesConRes.salesConsultantName = [salesConDic objectForKey:@"SalesConsultantName"];
                    salesConRes.commissionRate = [salesConDic objectForKey:@"commissionRate"];
                    [payment.salesConsultantListArrs addObject:salesConRes];
                    salesRemainRate = salesRemainRate - salesConRes.commissionRate.doubleValue;
                }
                payment.salesConsultantMonery = payment.paymentTotalMoney * salesRemainRate;
                payment.paymentMode = [[NSMutableArray alloc] init];
                //                NSLog(@"支付方式Ar =%@",payment.paymentMode);
                
                for (int i=0; i<[[dict objectForKey:@"PaymentDetailList"] count]; i++) {
                    NSDictionary * dic = [[dict objectForKey:@"PaymentDetailList"] objectAtIndex:i];
                    PayInfoDoc *payInfoDoc = [[PayInfoDoc alloc] init];
                    payInfoDoc.pay_Mode = [[dic objectForKey:@"PaymentMode"] integerValue];
                    payInfoDoc.pay_Amount = [[dic objectForKey:@"PaymentAmount"] doubleValue];
                    payInfoDoc.cardPay_Amount = [[dic objectForKey:@"CardPaidAmount"] doubleValue];
                    payInfoDoc.card_name = [dic objectForKey:@"CardName"];
                    payInfoDoc.cardType = [[dic objectForKey:@"CardType"] integerValue];
                    payment.paymentRemark = [dict objectForKey:@"Remark"];
                    payment.BranchName = [dict objectForKey:@"BranchName"];
                    [payment.paymentMode addObject:payInfoDoc];
                }
                
                [self.paymentHistoryArray addObject:payment];
            }
            [_tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD dismiss];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
    
}

@end
