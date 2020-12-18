//
//  CardPayanInDetailViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/17.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "CardPayanInDetailViewController.h"
#import "SVProgressHUD.h"
#import "GPCHTTPClient.h"
#import "getBalanceDetailJSON.h"
#import "balanceInfoListJson.h"
#import "balancecardListJSON.h"
#import "OrderListJSON.h"
#import "NormalEditCell.h"
#import "AccountCellTableViewCell.h"
#import "OrderDetailAboutCommodityViewController.h"
#import "OrderDetailAboutServiceViewController.h"
#import "OrderDoc.h"

@interface CardPayanInDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
//@property (strong, nonatomic) IBOutlet UITableView *secondTableView;

@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic)AFHTTPRequestOperation *requestECardInfoOperation;
@property (strong, nonatomic)NSMutableArray *cardBalanceInfoFinal;
@property (strong, nonatomic)NSMutableArray *orderList;
@property (assign, nonatomic)NSInteger sections;
@property (assign, nonatomic)int i;
@property (assign, nonatomic)int j;
@property (assign, nonatomic)int x;
@property (assign, nonatomic)int a;
@property (assign, nonatomic)int b;
@property (assign, nonatomic)int c;
@property (assign, nonatomic)int e;
@property (assign, nonatomic)int f;
@property (assign, nonatomic)int g;
@property (assign, nonatomic)int h;
@property (strong,nonatomic)NSMutableArray * infoListArr ;
@property (strong,nonatomic)OrderDoc * orderDoc;

@property (nonatomic,copy) NSString *balanceMain_ActionModeName;
@end

@implementation CardPayanInDetailViewController
@synthesize myTableView;
@synthesize infoListArr;
@synthesize orderDoc;

-(void)viewWillAppear:(BOOL)animated{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self initData];
    [self getcardBalanceInfo];
}

-(void)initData
{
    _i = 0;
    _j = 0;
    _x = 0;
    _a = 0;
    _b = 0;
    _c = 0;
    _h = 0;
    _e = 0;
    _f = 0;
    _g = 0;
    
}

-(void)initTableView
{
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [myTableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height + 20)];
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.backgroundColor = [UIColor clearColor];

    self.title = @"账户交易详细";
    myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.alwaysBounceVertical = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSInteger section2 = 0;
    
    getBalanceDetailJSON *getbalanceDetail = [_cardBalanceInfoFinal objectAtIndex:0];
    
    
    if ([[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count] != 0) {
        for (int i = 0 ; i < [[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count]; i ++) {
            NSInteger num = [[[[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]objectAtIndex:i]valueForKey:@"balanceCardList"]count];
            section2 = num + section2;
            _sections = section2;
        }
        for (int i = 0; i < [_orderList count]; i++) {
            NSInteger num1 = [_orderList  count];
            section2 = section2 + num1;
        }
    }
    
    return infoListArr.count + _orderList.count +  2+ (getbalanceDetail.remark.length > 0 ? 1 : 0);
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0){
        return 5;
    }else if (section == 1){
        return 1;
        
    }else if (section > 1 && section < _sections + 2 )
    {
        return 2;
        
    }else if(section >= (2+[infoListArr count]) && section < ( 2 + [infoListArr count]+ _orderList.count)  && (section - _orderList.count -2 - infoListArr.count )>0 )
        return 3;
    
    return 2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //remark
    NSInteger section2 = 0;
    if ([[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count] != 0) {
        for (int i = 0 ; i < [[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count]; i ++) {
            NSInteger num = [[[[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]objectAtIndex:i]valueForKey:@"balanceCardList"]count];
            section2 = num + section2;
            _sections = section2;
        }
        for (int i = 0; i < [_orderList count]; i++) {
            NSInteger num1 = [_orderList  count];
            section2 = section2 + num1;
        }
    }
    
    getBalanceDetailJSON *getbalanceDetail = [_cardBalanceInfoFinal objectAtIndex:0];
    
    if(indexPath.section ==section2 + 2 &&getbalanceDetail.remark.length>0){
        if (indexPath.row==1) {
            NSInteger height = [getbalanceDetail.remark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            return height < kTableView_DefaultCellHeight ? kTableView_DefaultCellHeight : height;
        }
    }
    
    return kTableView_DefaultCellHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_Margin_TOP;
    }
    
    if (section == 1) {
        return kTableView_Margin_TOP;
    }
    
    if (section > 1 && section < (2+[infoListArr count])&& (infoListArr.count-(section-2)) >0) {
        
        balancecardListJSON * balanceJson = [infoListArr objectAtIndex:section-2];
        
        if (balanceJson.titleMode ==1 ) {
            
            return 40;
        }
        
    }
    
    return kTableView_Margin_TOP;
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView = [[UIView alloc]initWithFrame:CGRectMake(kTitle_TitleLabelX, -5, 300.0f, kTableView_DefaultCellHeight)];
    tempView.backgroundColor = kDefaultBackgroundColor;
    tempView.tag = section;
    UILabel *titleLabel = [[UILabel alloc ]initWithFrame:CGRectMake(kTitle_TitleLabelX, -5, 300.0f, kTableView_DefaultCellHeight)];
    [titleLabel setTextColor:kColor_TitlePink];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    [titleLabel setFont:kNormalFont_14];
    [tempView addSubview:titleLabel];
    

    if (section > 1 && section < (2+[infoListArr count]) && (infoListArr.count-(section-2)) >0) {
        
        balancecardListJSON * balanceJson = [infoListArr objectAtIndex:section-2];
        
        if (balanceJson.titleMode ==1 ) {
            if (section == 2) {
                titleLabel.text = _balanceMain_ActionModeName;
            }else{
                titleLabel.text = balanceJson.actionModeName;
            }
            titleLabel.textColor=kColor_Black;
        }
        
    }
    
    return tempView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section >= (2+[infoListArr count]) && indexPath.section < ( 2 + [infoListArr count]+ _orderList.count)  && (indexPath.section - _orderList.count -2 - infoListArr.count )>0 ){
        if (indexPath.row == 0){
            OrderListJSON *orderList = [_orderList objectAtIndex:indexPath.section - ((int)_sections + 2) ];
            if ([orderList.productType integerValue] ==1) {//商品
                
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
    
}


- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identity = [NSString stringWithFormat:@"Cell_%@",indexPath];
    NormalEditCell *cell = [myTableView dequeueReusableCellWithIdentifier:identity];
    
    if (cell == nil) {
        cell = [[NormalEditCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        cell.valueText.enabled = NO;
        cell.valueText.textColor = [UIColor blackColor];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSInteger count1 = 0;
    if ([[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count] != 0) {
        for (int i = 0 ; i < [[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]count]; i ++) {
            NSInteger num = [[[[_cardBalanceInfoFinal[0] valueForKey:@"balanceInfoList"]objectAtIndex:i]valueForKey:@"balanceCardList"]count];
            count1 = num + count1;
        }
        for (int i = 0; i < [_orderList count]; i++) {
            NSInteger num1 = [_orderList  count];
            count1 = count1 + num1;
        }
    }
    
    if (indexPath.section == 0) {
        getBalanceDetailJSON *getbalanceDetail = [_cardBalanceInfoFinal objectAtIndex:indexPath.section];
        if (indexPath.row == 0) {
            [cell setTitle:@"交易编号"];
            cell.valueText.text = [NSString stringWithFormat:@"%@",getbalanceDetail.balanceNumber];
            return cell;
        }else if (indexPath.row == 1){
            [cell setTitle:@"交易时间"];
            [cell setValue:[[_cardBalanceInfoFinal objectAtIndex:indexPath.section] valueForKey:@"createTime"] isEditing:NO];
            return cell;
        }else if (indexPath.row == 2){
            [cell setTitle:@"交易门店"];
            [cell setValue:[[_cardBalanceInfoFinal objectAtIndex:indexPath.section] valueForKey:@"branchName"] isEditing:NO];
            return cell;
        }else if (indexPath.row == 3){
            [cell setTitle:@"交易类型"];
            [cell setValue:[[_cardBalanceInfoFinal objectAtIndex:indexPath.section] valueForKey:@"changeTypeName"] isEditing:NO];
            return cell;
        }else if (indexPath.row == 4){
            [cell setTitle:@"操作人"];
            [cell setValue:[[_cardBalanceInfoFinal objectAtIndex:indexPath.section] valueForKey:@"oPerator"] isEditing:NO];
            return cell;
        }
        
    }else if (indexPath.section == 1){
        
        if (indexPath.row == 0){
            
            NSString *str = [[_cardBalanceInfoFinal objectAtIndex:indexPath.row]valueForKey:@"changeTypeName"];
            [cell setTitle:[NSString stringWithFormat:@"%@总额",str]];
            
            cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,fabs([[[_cardBalanceInfoFinal objectAtIndex:indexPath.row] valueForKey:@"amount"] doubleValue])];
        }
        
    }else if (indexPath.section > 1 && indexPath.section < (2+[infoListArr count]) && (infoListArr.count-(indexPath.section-2)) >0) {
        
        balancecardListJSON * balanceJson = [infoListArr objectAtIndex:indexPath.section-2];
        
        cell.valueText.textColor = [UIColor blackColor];
        
        if (indexPath.row == 0){
            if ([balanceJson.cardType integerValue] == 2){
                
                UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(60 + ((IOS6) ? 20.f : 10.f), 8, 130, 20)];
                lable.textColor = kColor_Black;
                lable.font = kFont_Light_16;
                lable.textAlignment  = NSTextAlignmentRight;
                lable.text = [NSString stringWithFormat:@"%.2f 抵",fabs([balanceJson.cardPaidAmount doubleValue])];
                
                if ([balanceJson.actionMode integerValue] ==1 || [balanceJson.actionMode integerValue] ==9 || [balanceJson.actionMode integerValue] ==11 ) {
                    
                    cell.valueText.text =  [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.amount doubleValue])];
                    [cell addSubview:lable];
                }else if ([balanceJson.actionMode integerValue] == 13){
                    
                    cell.valueText.text =  [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.cardPaidAmount doubleValue])];
                }else{
                    cell.valueText.text =  [NSString stringWithFormat:@"%.2f",fabs([balanceJson.amount doubleValue])];
                }
            }else if ([balanceJson.cardType integerValue] == 3)
            {
                UILabel * lable =[[UILabel alloc] initWithFrame:CGRectMake(60 + ((IOS6) ? 20.f : 10.f), 8, 130, 20)];
                lable.textColor = kColor_Black;
                lable.font = kFont_Light_16;
                lable.textAlignment  = NSTextAlignmentRight;
                lable.text = [NSString stringWithFormat:@"%@ %.2f 抵",CUS_CURRENCYTOKEN,fabs([balanceJson.cardPaidAmount doubleValue])];
                
                if ([balanceJson.actionMode integerValue] == 1 || [balanceJson.actionMode integerValue] ==9 || [balanceJson.actionMode integerValue] ==11 ) {
                    
                    cell.valueText.text =  [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.amount doubleValue])];
                    [cell addSubview:lable];
                    
                }else if ([balanceJson.actionMode integerValue] == 13){
                    
                    cell.valueText.text =  [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.cardPaidAmount doubleValue])];
                }else
                {
                    cell.valueText.text =  [NSString stringWithFormat:@"%@ %.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.amount doubleValue])];
                }
                
            }else{
                
                cell.valueText.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.amount doubleValue])];
            }
            
            [cell setTitle:balanceJson.cardName ];
            
        }else if (indexPath.row == 1){
            
            if ([balanceJson.cardType integerValue] == 2) {
                
//                [cell setValue:[NSString stringWithFormat:@"%.2f",fabs([balanceJson.balance doubleValue])] isEditing:NO];
                [cell setValue:[NSString stringWithFormat:@"%.2f",[balanceJson.balance doubleValue]] isEditing:NO];

            }else{
                
//                [cell setValue:[NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,fabs([balanceJson.balance doubleValue])] isEditing:NO];
                [cell setValue:[NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,[balanceJson.balance doubleValue]] isEditing:NO];

            }
            
            [cell setTitle:@"余额"];
            
        }
        
    }else if(indexPath.section >= (2+[infoListArr count]) && indexPath.section < ( 2 + [infoListArr count]+ _orderList.count)  && (indexPath.section - _orderList.count -2 - infoListArr.count )>0 ){
        
        OrderListJSON *orderList = [_orderList objectAtIndex:indexPath.section - (2+[infoListArr count]) ];
        
        if (indexPath.row == 0) {
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            [cell setTitle:@"订单编号"];
            [cell setValue:[orderList valueForKey:@"orderNumber"]isEditing:NO];
            [cell setAccessoryText:@"    "];
            CGRect valueRect=cell.valueText.frame;
            valueRect.origin.x=130;
            cell.valueText.frame=valueRect;
            return cell;
        }else if (indexPath.row == 1){
            cell.titleLabel.frame = CGRectMake(10.0f,15, 250, 20.0f);
            [cell setTitle:[orderList valueForKey:@"productName"]];
            [cell setValue:@"" isEditing:NO];
            cell.titleLabel.textColor=kColor_Black;
            return cell;
        }else if (indexPath.row == 2){
            
            [cell setTitle:@"订单金额"];
            [cell setValue:[NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,[[orderList valueForKey:@"totalSalePrice"]doubleValue]] isEditing:NO];
            
            return cell;
        }
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"备注";
            cell.valueText.text = @"";
        } else if(indexPath.row == 1){
            
            NSString *cellindity = [NSString stringWithFormat: @"AccountCell%@",indexPath];
            AccountCellTableViewCell *accountCell = [tableView dequeueReusableCellWithIdentifier:cellindity];
            if (accountCell == nil){
                accountCell = [[AccountCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellindity];
                accountCell.backgroundColor = [UIColor whiteColor];
            }
            
            accountCell.titleNameLabel.text = @"";
            accountCell.arrowsImage.hidden = YES;
            getBalanceDetailJSON *getbalanceDetail = [_cardBalanceInfoFinal objectAtIndex:0];
            NSInteger height = [getbalanceDetail.remark sizeWithFont:kNormalFont_14 constrainedToSize:CGSizeMake(((IOS6) ? 310.f : 300.f), 500) lineBreakMode:NSLineBreakByCharWrapping].height + 22;
            accountCell.contentText.frame = CGRectMake(((IOS6) ? 10.f : 5.f), 2, ((IOS6) ? 310.f : 300.f), height <= 38 ? 39: height);
            accountCell.contentText.font = kNormalFont_14;
            accountCell.contentText.text = getbalanceDetail.remark;
            accountCell.contentText.lineBreakMode = UILineBreakModeCharacterWrap;
            accountCell.contentText.numberOfLines = 0;
            accountCell.contentText.textAlignment = NSTextAlignmentLeft;
            accountCell.contentText.textColor = [UIColor blackColor];
            
            return accountCell;
        }
    }
    
    return cell;
}


-(void)getcardBalanceInfo{
    
    NSDictionary *para = @{@"ID":@((long)self.ID),@"CardType":@((long)self.cardType),@"ChangeType":@((long)self.changeType)};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *dict = @{@"balanceNumber":@"BalanceNumber",
                           @"balanceID":@"BalanceID",
                           @"amount":@"Amount",
                           @"paymentID":@"PaymentID",
                           @"changeTypeName":@"ChangeTypeName",
                           @"remark":@"Remark",
                           @"oPerator":@"Operator",
                           @"createTime":@"CreateTime",
                           @"targetAccount":@"TargetAccount",
                           @"branchName":@"BranchName"};
    
    
    NSDictionary *dict2 = @{@"actionMode" :@"ActionMode",
                            @"actionModeName" :@"ActionModeName",
                            @"cardType" :@"CardType",
                            @"cardName" :@"CardName",
                            @"amount" :@"Amount",
                            @"balance" :@"Balance",
                            @"userCardNo" :@"UserCardNo",
                            @"cardPaidAmount" :@"CardPaidAmount"};
    
    NSDictionary *dict3 = @{@"orderID" :@"OrderID",
                            @"orderNumber" :@"OrderNumber",
                            @"productName" :@"ProductName",
                            @"productType" :@"ProductType",
                            @"totalSalePrice" :@"TotalSalePrice",
                            @"orderObjectID" :@"OrderObjectID"};
    
    
    
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Ecard/GetBalanceDetailInfo"  showErrorMsg:YES  parameters:para WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _cardBalanceInfoFinal = [[NSMutableArray alloc]init];
            _orderList = [[NSMutableArray alloc]init];
            
            getBalanceDetailJSON *getbalanceDetail = [[getBalanceDetailJSON alloc]init];
            [getbalanceDetail assignObjectPropertyWithDictionary:data andObjectPropertyAssociatedDictionary:dict];
            
            NSArray *firstLoop1 = [[NSArray alloc]init];
            
            firstLoop1 = [data objectForKey:@"OrderList"];
            
            getbalanceDetail.balanceInfoList = [[NSMutableArray alloc]init];
            
            if ([firstLoop1 isKindOfClass:[NSNull class]]) {
                
            }else{
                for (NSDictionary *objFirst in firstLoop1)
                {
                    OrderListJSON *orderList = [[OrderListJSON alloc]init];
                    [orderList assignObjectPropertyWithDictionary:objFirst andObjectPropertyAssociatedDictionary:dict3];
                    [_orderList addObject:orderList];
                    
                    orderDoc = [[OrderDoc alloc]init];
                    [orderDoc setOrder_ObjectID:[orderList.orderObjectID integerValue]];
                    [orderDoc setOrder_ID:[orderList.orderID longLongValue]];
                    [orderDoc setOrder_Number:orderList.orderNumber];
                    [orderDoc setOrder_Type:[orderList.productType integerValue]];
                    [orderDoc setOrder_ProductName:orderList.productName];
                }
            }
            
            /*
             ** 支入支出卡列表
             */
            
            infoListArr = [[NSMutableArray alloc] init];
            
            NSDictionary * firstLoop = [data objectForKey:@"BalanceMain" ];
            
            if (![firstLoop isKindOfClass:[NSNull class]])
            {
                balanceInfoListJson *balanceInfo = [[balanceInfoListJson alloc]init];
                balanceInfo.balanceCardList = [[NSMutableArray alloc]init];
                balanceInfo.actionMode = [firstLoop objectForKey:@"ActionMode"];
                balanceInfo.actionModeName = [firstLoop objectForKey:@"ActionModeName"];
                _balanceMain_ActionModeName = [firstLoop objectForKey:@"ActionModeName"];
                int countSec = 0 ;
                for (NSDictionary * dic in [firstLoop objectForKey:@"BalanceCardList"]) {
                    
                    balancecardListJSON *balanceCard = [[balancecardListJSON alloc]init];
                    [balanceCard assignObjectPropertyWithDictionary:dic andObjectPropertyAssociatedDictionary:dict2];
                    
                    if (countSec ==0) {
                        
                        [balanceCard setTitleMode:1];
                    }
                    
                    [infoListArr addObject:balanceCard];
                    [balanceInfo.balanceCardList addObject:balanceCard];
                    
                    countSec ++ ;
                }
                
                [getbalanceDetail.balanceInfoList addObject:balanceInfo];
            }
            /*
             ** BalanceSec
             */
            
            NSDictionary * secountLoop = [data objectForKey:@"BalanceSec"];
            
            if (![secountLoop isKindOfClass:[NSNull class]]) {
                balanceInfoListJson *balanceInfoSec = [[balanceInfoListJson alloc]init];
                balanceInfoSec.balanceCardList = [[NSMutableArray alloc]init];
                balanceInfoSec.actionMode = [secountLoop objectForKey:@"ActionMode"];
                balanceInfoSec.actionModeName = [secountLoop objectForKey:@"ActionModeName"];
                
                int count = 0 ;
                
                for (NSDictionary * dic in [secountLoop objectForKey:@"BalanceCardList"]) {
                    
                    balancecardListJSON *balanceCard = [[balancecardListJSON alloc]init];
                    [balanceCard assignObjectPropertyWithDictionary:dic andObjectPropertyAssociatedDictionary:dict2];
                    if (count ==0) {
                        
                        [balanceCard setTitleMode:1];
                    }
                    [infoListArr addObject:balanceCard];
                    [balanceInfoSec.balanceCardList addObject:balanceCard];
                    
                    count ++ ;
                }
                
                [getbalanceDetail.balanceInfoList addObject:balanceInfoSec];
            }
            [_cardBalanceInfoFinal addObject:getbalanceDetail];
            
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
        [myTableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
