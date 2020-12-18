//
//  PayDetail_ViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "PayDetail_ViewController.h"
#import "NormalEditCell.h"
#import "CommodityDoc.h"
#import "CustomerCardDoc.h"
#import "DFTableAlertView.h"
#import "OrderPayViewController.h"
#import "OrderDoc.h"

@interface PayDetail_ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(strong ,nonatomic) UITableView * myTableView;
@property (weak, nonatomic) AFHTTPRequestOperation *getCardDiscountList;
@property (weak, nonatomic) AFHTTPRequestOperation *requestPaymentInfo;
@property (weak, nonatomic) AFHTTPRequestOperation *requestGetPay;
@property (strong, nonatomic) NSMutableDictionary * cardDic;
@property (assign, nonatomic) double allTotalPrice;
@property (assign, nonatomic) double allCardPrice;
@property(nonatomic,strong)NSMutableArray * commodityArray_Selected;
@end

@implementation PayDetail_ViewController
@synthesize myTableView;
@synthesize cardDic;
@synthesize allTotalPrice;
@synthesize allCardPrice;


-(void)viewWillAppear:(BOOL)animated
{
    [self getPaymentInfo];
}
- (void)viewDidLoad {
    self.isShowButton = YES;
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    self.title = @"购买详情";
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [self initTableView];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, myTableView.frame.origin.y + myTableView.frame.size.height, kSCREN_BOUNDS.size.width, 49.0f)];
    footView.backgroundColor = kColor_FootView;
    [self.view addSubview:footView];
    UIImageView *footViewImage = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 49.0f)];
    [footViewImage setImage:[UIImage imageNamed:@"common_footImage"]];
    [footView addSubview:footViewImage];
    UIButton *buy_Button = [UIButton buttonWithTitle:@"确定购买"
                                              target:self
                                            selector:@selector(buyNowAction)
                                               frame:CGRectMake(5,5, kSCREN_BOUNDS.size.width - 10, 39)
                                       backgroundImg:nil
                                    highlightedImage:nil];
    buy_Button.backgroundColor = [UIColor colorWithRed:182/255. green:165/255. blue:145/255. alpha:1.];
    buy_Button.titleLabel.font=kNormalFont_14;
    [footView addSubview:buy_Button];

    cardDic = [[NSMutableDictionary alloc] init];
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake( 0, 0, kSCREN_BOUNDS.size.width,kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 49.0f)style:UITableViewStyleGrouped];
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizingMask = UIViewAutoresizingNone;
    myTableView.delegate = self;
    myTableView.dataSource = self;
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [myTableView setTableFooterView:view];
    [self.view addSubview:myTableView];
    
}

//确认购买
-(void)buyNowAction
{
    [self cofirmPay];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_DefaultCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return kTableView_Margin_TOP;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == self.commodityArray_Selected.count)
        return 2;
    return 6;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.commodityArray_Selected.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    NormalEditCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        cell.valueText.userInteractionEnabled = NO;
        cell.valueText.textColor = kColor_Black;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(indexPath.section == self.commodityArray_Selected.count)
    {

            switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = @"合计";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,allTotalPrice];
                break;
            case 1:
                cell.titleLabel.text = @"会员总价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,allCardPrice];
                break;
            default:
                break;
        }
    }else
    {
        CommodityDoc * commodity = [self.commodityArray_Selected objectAtIndex:indexPath.section];

        switch (indexPath.row) {
            case 0:
                cell.titleLabel.text = commodity.comm_CommodityName;
                cell.valueText.text = @"";
                break;
            case 1:
            {
                cell.titleLabel.text = @"数量";
                cell.valueText.text = [NSString stringWithFormat:@"%ld",(long)commodity.comm_Quantity];
            }
                break;
            case 2:
                cell.titleLabel.text = @"原价";
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",CUS_CURRENCYTOKEN,commodity.comm_TotalMoney];
                break;
            case 3:
            {
                cell.valueText.textColor = kColor_Editable;
                cell.titleLabel.text = @"e账户";
                cell.valueText.text = commodity.comm_CardName;
                UIButton *Button = [UIButton buttonWithTitle:@""
                                                              target:self
                                                            selector:@selector(checkCardBalance:)
                                                               frame:CGRectMake(200.0f, 0, 110, kTableView_HeightOfRow)
                                                       backgroundImg:nil
                                                    highlightedImage:nil];
                [cell.contentView addSubview:Button];
                Button.tag = indexPath.section;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
                break;
            case 4:
                cell.titleLabel.text = @"会员价";
                    cell.valueText.text = [NSString stringWithFormat:@"%@%.2Lf",CUS_CURRENCYTOKEN,commodity.comm_DiscountMoney];
                break;
            case 5:
                cell.titleLabel.text = @"购买门店";
                cell.valueText.text = commodity.comm_BranchName;
                break;
                
            default:
                break;
        }
    }
      
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)addAction:(UIButton *)sender
{
    CommodityDoc * com = [self.commodityArray_Selected objectAtIndex:sender.tag-2000];
    
    com.comm_Quantity ++ ;
    
    [com setComm_Quantity:com.comm_Quantity --];
    [com setComm_DiscountMoney:[com retDiscountMoney]];
    [com setComm_TotalMoney:[com retTotalMoney]];
    
    [self countAllTotalPrice];
    [self countAllCardPrice];
    [myTableView reloadData];
}

//计算价格

-(double)countAllTotalPrice
{
    allTotalPrice = 0 ;
    for (CommodityDoc * commod in self.commodityArray_Selected) {
        allTotalPrice = allTotalPrice + commod.comm_TotalMoney;
    }
    return allTotalPrice;
}

-(double)countAllCardPrice
{
    allCardPrice = 0 ;
    for (CommodityDoc * commod in self.commodityArray_Selected) {
        if (commod.comm_CardID == 0) { // 不适用e账户
            allCardPrice = allCardPrice + commod.comm_TotalMoney;
        } else {
            allCardPrice = allCardPrice + commod.comm_DiscountMoney;
        }
    }
    return allCardPrice;
}

#pragma mark choosePaymenAndChooseCard

-(void)checkCardBalance:(UIButton *)sender
{
    [self cardShowList:sender.tag];

}

-(void)cardShowList:(NSInteger)index
{
    NSArray * cardForProductListArr = [cardDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]];
    
    DFTableAlertView *alert = [DFTableAlertView tableAlertTitle:@"e账户列表" NumberOfRows:^NSInteger(NSInteger section) {
        return cardForProductListArr.count;
        
    } CellOfIndexPath:^UITableViewCell *(DFTableAlertView *alert, NSIndexPath *indexPath) {
        NSString *ecardCell = [NSString stringWithFormat:@"ecardCell %@",indexPath];
        UITableViewCell *cell = [alert.table dequeueReusableCellWithIdentifier:ecardCell];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ecardCell];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            //if (IOS8) {
                //cell.layoutMargins = UIEdgeInsetsZero;
            //}
            
            CustomerCardDoc * cardDoc = [cardForProductListArr objectAtIndex:indexPath.row];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f,-5,kSCREN_BOUNDS.size.width - 20,kTableView_DefaultCellHeight)];
            label.tag = 100;
            label.textColor = kColor_TitlePink;
            label.font = kNormalFont_14;
            label.text = [NSString stringWithFormat:@"%@(%.2f)",cardDoc.cardName,cardDoc.Discount];
            [cell.contentView addSubview:label];
        }
        return cell;
    }];
    
    [alert configureSelectionBlock:^(NSIndexPath *selectedIndex) {
        
        CustomerCardDoc * cardDoc = [cardForProductListArr objectAtIndex:selectedIndex.row];
        
        CommodityDoc * commod = [self.commodityArray_Selected objectAtIndex:index];
        commod.comm_CardName = cardDoc.cardName;
        commod.comm_CardID = cardDoc.cardId;
        [self setupComm_DiscountMoneyWithCommodityDoc:commod customerCardDoc:cardDoc];
        [self countAllCardPrice];
        [myTableView reloadData];
        
    } Completion:^{
        
    }];
    
    [alert show];
}
#pragma mark - 计算会员价
- (void)setupComm_DiscountMoneyWithCommodityDoc:(CommodityDoc *)aCommodityDoc customerCardDoc:(CustomerCardDoc *)aCustomerCardDoc
{
    if (aCommodityDoc.comm_MarketingPolicy == 0) { //原价销售
        aCommodityDoc.comm_DiscountMoney = aCommodityDoc.comm_UnitPrice * aCommodityDoc.comm_Quantity;
    }else if (aCommodityDoc.comm_MarketingPolicy == 1){ // 折扣价销售
        if (aCommodityDoc.comm_CardID  == 0) { // 不适用e账户
            aCommodityDoc.comm_DiscountMoney = aCommodityDoc.comm_UnitPrice * aCommodityDoc.comm_Quantity;
        }else {
            aCommodityDoc.comm_DiscountMoney = aCommodityDoc.comm_UnitPrice * aCustomerCardDoc.Discount * aCommodityDoc.comm_Quantity;
        }
    }else{
        if (aCommodityDoc.comm_CardID == 0) { // 不适用e账户
            aCommodityDoc.comm_DiscountMoney = aCommodityDoc.comm_UnitPrice * aCommodityDoc.comm_Quantity;
        }else {
            aCommodityDoc.comm_DiscountMoney = aCommodityDoc.comm_PromotionPrice * aCustomerCardDoc.Discount * aCommodityDoc.comm_Quantity;
        }
    }
}

//获取用户储值卡折扣列表
- (void)GetCardDiscountList1:(CommodityDoc *)commod idx:(NSInteger)index defaulCardID:(NSInteger)dcid
{
    if ([[cardDic objectForKey:[NSString stringWithFormat:@"%ld",(long)index]] count] >0) {
        [self cardShowList:index];
        return;
    }
    NSDictionary * par =@{
                          @"ProductCode":@((long long)commod.comm_Code),
                          @"BranchID":@(commod.comm_BranchID),
                          @"ProductType":@((long)commod.comm_Type)
                          
                             };
    _getCardDiscountList = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardDiscountList" showErrorMsg:YES  parameters:par WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            bool hasCardBuy=false;
            for (NSDictionary * dic in data) {
                CustomerCardDoc * cardDoc = [[CustomerCardDoc alloc] init];
                [cardDoc setCardName:[dic objectForKey:@"CardName"]];
                [cardDoc setCardNO:[dic objectForKey:@"UserCardNo"]];
                [cardDoc setDiscount:[[dic objectForKey:@"Discount"] doubleValue]];
                [cardDoc setCardId:[[dic objectForKey:@"CardID"] integerValue]];
                
                [arr addObject:cardDoc];
                if(dcid==[[dic objectForKey:@"CardID"] integerValue]){
                    hasCardBuy=true;
                }
            }
            
            if (arr.count ==0) {
                commod.comm_CardID = 0;
                commod.comm_CardName = @"不适用";
                [commod setComm_DiscountMoney:[commod retTotalMoney]];
            }
            else{
                if(!hasCardBuy){
                    CustomerCardDoc * ccd=[arr objectAtIndex:0];
                    commod.comm_CardName=ccd.cardName;
                    commod.comm_CardID=ccd.cardId;
                    [self setupComm_DiscountMoneyWithCommodityDoc:commod customerCardDoc:ccd];
                    [self countAllCardPrice];
                }
            }
            CustomerCardDoc * cardDoc = [[CustomerCardDoc alloc] init];
            [cardDoc setCardName:@"不使用e账户"];
            [cardDoc setCardId:0];
            [cardDoc setDiscount:1];
            [arr insertObject:cardDoc atIndex:0];
            [cardDic setObject:arr forKey:[NSString stringWithFormat:@"%ld",(long)index]];
            
            [myTableView reloadData];
            
        } failure:^(NSInteger code, NSString *error) {
            [myTableView reloadData];
        }];
    } failure:^(NSError *error) {
        
    }];
}


-(void)getPaymentInfo{
    
    [SVProgressHUD showWithStatus:@"Loading..."];

    NSDictionary *para = @{@"CartIDList":self.cartIdArr};
    
    _requestPaymentInfo = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Commodity/getProductInfoList"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message){
           
            self.commodityArray_Selected = [[NSMutableArray alloc] init];
            
            int i=0;
            
            for (NSDictionary * CartDetailDic in data) {
                
                CommodityDoc *com = [[CommodityDoc alloc] init];
                [com setComm_BranchID:[[CartDetailDic objectForKey:@"BranchID"]integerValue]];
                [com setComm_BranchName:[CartDetailDic objectForKey:@"BranchName"]];
                [com setCart_ID:[CartDetailDic objectForKey:@"CartID"]];
                [com setComm_Code:[[CartDetailDic objectForKey:@"Code"] longLongValue]];
                [com setComm_ID:[[CartDetailDic objectForKey:@"ID"] integerValue]];
                [com setComm_Type:[[CartDetailDic objectForKey:@"ProductType"] integerValue]];
                
                [com setComm_CommodityName:[CartDetailDic objectForKey:@"Name"]];
                [com setComm_Quantity:[[CartDetailDic objectForKey:@"Quantity"] integerValue]];
                [com setComm_UnitPrice:[[CartDetailDic objectForKey:@"UnitPrice"] doubleValue]];
                [com setComm_Type:[[CartDetailDic objectForKey:@"ProductType"] integerValue]];
                [com setComm_MarketingPolicy:[[CartDetailDic objectForKey:@"MarketingPolicy"] integerValue]];
                
                [com setComm_CardID:[[CartDetailDic objectForKey:@"CardID"] integerValue]];
                [com setComm_CardName:[CartDetailDic objectForKey:@"CardName"]];
                com.comm_PromotionPrice = [[CartDetailDic objectForKey:@"PromotionPrice"] doubleValue];

                /*
                 * 计算单比商品总价格
                 */
                [com setComm_TotalMoney:[com retTotalMoney]];
               
                //单比会员总价
                if ([[CartDetailDic objectForKey:@"CardID"] integerValue] <= 0) {
                    
                    [com setComm_DiscountMoney:[com retTotalMoney]];
                } else {
                    
                    [com setComm_DiscountMoney:[com retDiscountMoney]];
                }
                
                [self.commodityArray_Selected addObject:com];
                
                // 请求卡列表
                NSInteger intDefaultCardID = [[CartDetailDic objectForKey:@"CardID"] integerValue];
                
                [self GetCardDiscountList1:com idx:i defaulCardID:intDefaultCardID];
                i++;
            }
        
            
            [self countAllTotalPrice];
            
            [self countAllCardPrice];
            
            [myTableView reloadData];
            
        }failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        
    }];
}

//下单
-(void)cofirmPay{
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    NSMutableArray * muArr = [[NSMutableArray alloc] init];
    for (CommodityDoc * doc in  self.commodityArray_Selected) {
        NSDictionary * dict = @{
                                    @"CartID":doc.cart_ID,
                                    @"CardID":@((long)doc.comm_CardID),
                                    @"ProductID":@((long)doc.comm_ID),
                                    @"ProductCode":@((long long)doc.comm_Code),
                                    @"ProductType":@((long)doc.comm_Type),
                                    @"Quantity":@((long)doc.comm_Quantity),
                                    @"BranchID":@((long)doc.comm_BranchID),
                                    @"TotalOrigPrice": [NSString stringWithFormat:@"%.2Lf",doc.comm_TotalMoney],
                                    @"TotalCalcPrice":[NSString stringWithFormat:@"%.2Lf",doc.comm_DiscountMoney],
                                    @"TotalSalePrice":@-1
                                };
        [muArr addObject:dict];
    }
    
    NSDictionary *para = @{@"CustomerID":@((long)CUS_CUSTOMERID),
                           @"OrderList":muArr
                           };
    
    _requestGetPay = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Order/AddNewOrder"  showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message){
            
            [SVProgressHUD showSuccessWithStatus2:message];

            NSMutableArray * orderArray_Selected = [[NSMutableArray alloc] init];
            for (NSString * orderID in data) {
                OrderDoc * order = [[OrderDoc alloc] init];
                order.order_ID = [orderID integerValue];
                [orderArray_Selected addObject:order];
            }
            self.hidesBottomBarWhenPushed = YES;
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            OrderPayViewController *pay = (OrderPayViewController*)[sb instantiateViewControllerWithIdentifier:@"OrderPayController"];
            pay.payDetaiDelectedOrderArr = orderArray_Selected;
            [self.navigationController pushViewController:pay animated:YES];
            
        }failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showSuccessWithStatus2:error];
        }];
        
    } failure:^(NSError *error) {
        
    }];
    
}

//四舍六入
- (NSString *)notRounding:(double)price afterPoint:(NSInteger)position
{
    NSLog(@"price1 =%f",price);
     NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
     NSDecimalNumber *ouncesDecimal;
     NSDecimalNumber *roundedOunces;
     ouncesDecimal = [[NSDecimalNumber alloc] initWithDouble:price]; NSLog(@"NSDecimalNumber =%@",ouncesDecimal);
     roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
     return [NSString stringWithFormat:@"%@",roundedOunces];
}


@end
