//
//  GetDetailPayNewViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/16.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//
#import "CardPayanInDetailViewController.h"
#import "GetDetailPayNewViewController.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"
#import "getCardBalanceInfo.h"
#import "OrderListCell.h"
@interface GetDetailPayNewViewController ()
@property (weak, nonatomic)AFHTTPRequestOperation *requestECardInfoOperation;
@property (strong, nonatomic)NSMutableArray *getCardBalanceArray;
@end

@implementation GetDetailPayNewViewController

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height + 20 )];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO; 
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getCardBalance];
    self.title =@"账户交易记录";

}

-(void)getCardBalance
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para0 = @{@"CustomerID":@(CUS_CUSTOMERID),@"UserCardNo":[_cardInfo[0] valueForKey:@"userCardNo"],@"CardType":@([[_cardInfo[0] valueForKey:@"cardType"] integerValue] )};
   
    NSDictionary *dict = @{@"balanceID":@"BalanceID",
                           @"actionMode":@"ActionMode",
                           @"createTime":@"CreateTime",
                           @"amount":@"Amount",
                           @"balance":@"Balance",
                           @"actionModeName":@"ActionModeName",
                           @"actionType":@"ActionType",
                           @"changeType":@"ChangeType",
                           @"paymentID":@"PaymentID"};
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardBalanceByUserCardNo"  showErrorMsg:YES  parameters:para0 WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _getCardBalanceArray = [[NSMutableArray alloc]init];
            for (NSDictionary *obj in data)
            {
                getCardBalanceInfo *getBalanceInfo = [[getCardBalanceInfo alloc]init];
                [getBalanceInfo assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [_getCardBalanceArray addObject:getBalanceInfo];
            }
            
            
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];

}

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect cellSize = cell.frame;
    NSLog(@"cell.frame =%@",NSStringFromCGRect(cellSize));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCellPayBalance";
    
    if (indexPath.row == 0) {
        
        OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[ OrderListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        if (indexPath.row == 0) {
            NSString *plusString = @"";
            if ([[_getCardBalanceArray[indexPath.section] valueForKey:@"amount"] floatValue] < 0 ) {
                
                cell.totalPriceLabel.textColor = [UIColor redColor];
                plusString = @"-";
                
            }else if ([[_getCardBalanceArray[indexPath.section] valueForKey:@"amount"] floatValue] > 0){
                
                cell.totalPriceLabel.textColor = [UIColor greenColor];
                plusString = @"+";
                
            }
            
            CGFloat num = fabsf([[_getCardBalanceArray[indexPath.section] valueForKey:@"amount"]floatValue]);
            cell.dateLabel.text = [NSString stringWithString:[_getCardBalanceArray[indexPath.section] valueForKey:@"actionModeName"]];
            cell.nameLabel.text = [NSString stringWithString:[_getCardBalanceArray[indexPath.section] valueForKey:@"createTime"]];
            
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"%@%.2f",plusString,num];
            if (self.cardType == 2) {
                cell.accounNameLabel.text = [NSString stringWithFormat:@"%.2f",[[_getCardBalanceArray[indexPath.section] valueForKey:@"balance"] doubleValue]];
            }else
                cell.accounNameLabel.text = [NSString stringWithFormat:@"%@%.2f",CUS_CURRENCYTOKEN,[[_getCardBalanceArray[indexPath.section] valueForKey:@"balance"] doubleValue]];
        }
        
         return cell;
    }
    
    return nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return _getCardBalanceArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    CardPayanInDetailViewController *cardPayanInDetail = (CardPayanInDetailViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CardPayan"];
    cardPayanInDetail.cardType = [[_cardInfo[0] valueForKey:@"cardType"] integerValue];
    cardPayanInDetail.changeType = [[_getCardBalanceArray[indexPath.section] valueForKey:@"changeType"] integerValue];
    cardPayanInDetail.ID = [[_getCardBalanceArray[indexPath.section] valueForKey:@"balanceID"] integerValue];
    [self.navigationController pushViewController:cardPayanInDetail animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0)
    return 70;
    else return kTableView_HeightOfRow;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    return  kTableView_Margin;
}


-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, kTableView_Margin)];
    [headerView setBackgroundColor:kDefaultBackgroundColor];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    return kTableView_Margin;
}


@end
