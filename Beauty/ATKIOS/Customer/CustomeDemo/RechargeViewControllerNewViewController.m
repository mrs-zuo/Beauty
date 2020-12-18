//
//  RechargeViewControllerNewViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by 楊婉菱 on 2015/8/13.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "RechargeViewControllerNewViewController.h"
#import "NormalEditCell.h"
#import "GPCHTTPClient.h"
#import "SVProgressHUD.h"
#import "CustomerCard.h"
#import "RandomColor.h"
#import "CardInfoJson.h"
#import "RechargeViewController.h"
#import "discountListJSON.h"
#import "AccountListTableViewCell.h"
#import "AccountInAndOutList_ViewController.h"
#import "WelfareViewController.h"


@interface RechargeViewControllerNewViewController ()<sendDefaultToPrevous>

@property (strong,nonatomic)NSMutableArray *cardDefault;
@property (assign,nonatomic)NSInteger indexPath;

@property (weak, nonatomic) AFHTTPRequestOperation *requestECardInfoOperation;
@property (strong, nonatomic)NSMutableArray *thirdPageCard;
@property (copy, nonatomic)NSString *cardNo;
@property (strong, nonatomic)NSMutableArray *cardInfoList;

@end

@implementation RechargeViewControllerNewViewController


-(void)setToDefaultOrNot:(NSMutableArray *)deFaultOrNot index:(NSInteger)indexPath{
    for (CustomerCard *card in _thirdPageCard)
    {
        [card setValue:@"NO" forKey:@"isDefault"];
    }
    
    [deFaultOrNot[0] setValue:@"YES" forKey:@"isDefault"];
    
    [self getCardInfoUpdate:deFaultOrNot];
   
}


-(void)getCardInfoUpdate:(NSMutableArray*)arrayCard{
    
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID),
                              @"UserCardNo":[arrayCard[0] valueForKey:@"userCardNo"] };
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/UpdateCustomerDefaultCard"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
         [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self getCardList];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;

    [super viewWillAppear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(6, 0, kSCREN_BOUNDS.size.width-12, kSCREN_BOUNDS.size.height  - 49 + 15)];

    self.title = @"我的账户";

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    UIButton * accountBt = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, kSCREN_BOUNDS.size.height - 44.0f - 49.0f,kSCREN_BOUNDS.size.width,49)];
    accountBt.backgroundColor = [UIColor whiteColor];
    accountBt.titleLabel.font=kNormalFont_14;
    [accountBt setTitle:@"账户交易记录" forState:UIControlStateNormal];
    [accountBt setTitleColor:[UIColor colorWithRed:171/255. green:171/255. blue:171/255. alpha:1.] forState:UIControlStateNormal];
    [accountBt addTarget:self action:@selector(chooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:accountBt];

    
    [self getCardList];
}

-(void)chooseAction:(UIButton *)sender
{   self.hidesBottomBarWhenPushed = YES;
    AccountInAndOutList_ViewController * list = [[AccountInAndOutList_ViewController alloc] init];
    [self.navigationController pushViewController:list animated:YES];
}

#pragma mark -  UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _thirdPageCard.count+1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == _thirdPageCard.count) {
        //福利包
        AccountListTableViewCell  *AccountCell = [self configAccountCellTableViewCell:tableView indexPath:indexPath];
        AccountCell.layer.cornerRadius = 8;
        AccountCell.titleNameLabel.text = @"福利包";
        AccountCell.backgroundColor = [UIColor whiteColor];
        AccountCell.titleNameLabel.frame = CGRectMake(15.0f, 15.0f, 130.0f, 20.0f);
        AccountCell.imageNext.frame = CGRectMake(AccountCell.contentView.frame.size.width-33, 32, 15, 18);
        return AccountCell;
    }else {
        AccountListTableViewCell  *AccountCell = [self configAccountCellTableViewCell:tableView indexPath:indexPath];
        AccountCell.layer.cornerRadius = 8;
        CustomerCard * customerCard = [[CustomerCard alloc] init];
        customerCard = [_thirdPageCard objectAtIndex:indexPath.section];
        
        UIButton *  defaultImageView = [[UIButton alloc] initWithFrame:CGRectMake(255, 0,40, 25)];
        defaultImageView.backgroundColor = [UIColor colorWithRed:254/255. green:147/255. blue:30/255. alpha:1.];
        [defaultImageView setTitle:@"默认" forState:UIControlStateNormal];
        defaultImageView.titleLabel.font = kNormalFont_14;
        defaultImageView.tag = 1001;
        defaultImageView.userInteractionEnabled = NO;
        [AccountCell addSubview:defaultImageView];
        defaultImageView.hidden = YES;
        
        if (customerCard.isDefault) {
            defaultImageView.hidden = NO;
        }
        AccountCell.titleNameLabel.text = customerCard.cardName;
        AccountCell.contentText.text = [NSString stringWithFormat:@"%@",customerCard.userCardNo];
        AccountCell.backgroundColor = [UIColor clearColor];
        
        if (customerCard.cardTypeID == 1) {
            
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,customerCard.cardBalance];
            
        }else if(customerCard.cardTypeID == 2)
        {
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%.2Lf",customerCard.cardBalance];
            
        }else if(customerCard.cardTypeID == 3)
        {
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%@ %.2Lf",CUS_CURRENCYTOKEN,customerCard.cardBalance];
 
        }
//        AccountCell.titleNameLabel.frame = CGRectMake(30.0f, 15.0f, 130.0f, 20.0f);
//        AccountCell.imageNext.frame = CGRectMake(AccountCell.contentView.frame.size.width-33, 50, 15, 18);
        return AccountCell;
    }
}

// 配置NormalEditCell
- (AccountListTableViewCell *)configAccountCellTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell1%ld%ld",(long)indexPath.row,(long)indexPath.section];
    AccountListTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[AccountListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    UIImageView *imageView= (UIImageView *)[cell viewWithTag:1001];
    [imageView removeFromSuperview];
    
    return cell;
}
#pragma mark -  UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    
    if (indexPath.section == _thirdPageCard.count) {
        WelfareViewController * welfareVC = [[WelfareViewController alloc] init];
        [self.navigationController pushViewController:welfareVC animated:YES];
    }else if (indexPath.section == _thirdPageCard.count + 1) {
        AccountInAndOutList_ViewController *list = [[AccountInAndOutList_ViewController alloc] init];
        [self.navigationController pushViewController:list animated:YES];
    }else{
        CustomerCard * customerCard = [_thirdPageCard objectAtIndex:indexPath.section];
        [self getCardInfo:customerCard];
    }
    
}
-(void)ChangePage{

    [self performSegueWithIdentifier:@"toPayDetailSegue" sender:self];
}


#pragma mark - 接口
-(void)getCardInfo:(CustomerCard *)customerCard{
    
    NSDictionary *paraGet = @{@"CustomerID":@(CUS_CUSTOMERID),
                              @"UserCardNo":customerCard.userCardNo};
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *dict = @{@"discountName" : @"DiscountName",
                           @"discount" : @"Discount"};
    
    
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCardInfo"  showErrorMsg:YES  parameters:paraGet WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            CardInfoJson *cardInfoJson = [[CardInfoJson alloc]init];
            
            cardInfoJson.cardID = [data objectForKey:@"CardID"];
            cardInfoJson.cardName = [data objectForKey:@"CardName"];
            cardInfoJson.userCardNo = [data objectForKey:@"UserCardNo"];
            cardInfoJson.balance = [[data objectForKey:@"Balance"] doubleValue];
            cardInfoJson.currency = [data objectForKey:@"Currency"];
            cardInfoJson.cardCreatedDate = [data objectForKey:@"CardCreatedDate"];
            cardInfoJson.cardExpiredDate = [data objectForKey:@"CardExpiredDate"];
            cardInfoJson.cardDescription = [data objectForKey:@"CardDescription"];
            cardInfoJson.cardType = [data objectForKey:@"CardType"];
            cardInfoJson.cardTypeName = [data objectForKey:@"CardTypeName"];
            cardInfoJson.realCardNo = [data objectForKey:@"RealCardNo"];
            NSArray *discountList = [data objectForKey:@"DiscountList"];
            cardInfoJson.discountList = [[NSMutableArray alloc]init];
            
            for (NSDictionary *obj in discountList)
            {   discountListJSON *discountlistJSON = [[discountListJSON alloc]init];
                [discountlistJSON assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [cardInfoJson.discountList addObject:discountlistJSON];
            }
            _cardInfoList = [[NSMutableArray alloc]init];
            [_cardInfoList addObject:cardInfoJson];
            
            
            RechargeViewController *rechargeController = (RechargeViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"Recharge"];
           
            NSDictionary * dic = @{@"isDefault":[NSString stringWithFormat:@"%ld",(long)customerCard.isDefault],
                         @"cardTypeID":customerCard.userCardNo

                                   };
            _cardDefault = [NSMutableArray arrayWithObject:dic];
            
            rechargeController.cardDefaultOrNot = _cardDefault;
            rechargeController.cardList = _cardInfoList;
            rechargeController.iNdexPath = _indexPath;
            rechargeController.cardName = customerCard.cardName;
            rechargeController.cardNO = customerCard.userCardNo;
            rechargeController.cardType = customerCard.cardTypeID;
            rechargeController.cardBalance=customerCard.cardBalance;
            rechargeController.delegate = self;
            
            [self.navigationController pushViewController:rechargeController animated:YES];
            
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        
    } failure:^(NSError *error) {
        
    }];
}


-(void)getCardList{
    
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para0 = @{@"CustomerID":@(CUS_CUSTOMERID)};
    
    
    _requestECardInfoOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerCardList"  showErrorMsg:YES  parameters:para0 WithSuccess:^(id json){
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            _thirdPageCard = [[NSMutableArray alloc]init];
            
            for (NSDictionary *customerCardListDict in data){
                
                CustomerCard *customerCard = [[CustomerCard alloc]init];
                customerCard.cardName = [customerCardListDict objectForKey:@"CardName"];
                customerCard.cardBalance = [[customerCardListDict objectForKey:@"Balance"] doubleValue];
                customerCard.isDefault = [[customerCardListDict objectForKey:@"IsDefault"] integerValue];
                customerCard.userCardNo = [customerCardListDict objectForKey:@"UserCardNo"];
                customerCard.cardTypeID = [[customerCardListDict objectForKey:@"CardTypeID"] integerValue];
                
                [_thirdPageCard addObject:customerCard];
            }
            
            [SVProgressHUD dismiss];
            
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

@end
