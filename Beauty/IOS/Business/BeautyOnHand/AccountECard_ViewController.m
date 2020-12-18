//
//  AccountECard_ViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 15/6/23.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "AccountECard_ViewController.h"
#import "RechargeViewController.h"
#import "NavigationView.h"
#import "RechargeViewController.h"
#import "GPBHTTPClient.h"
#import "CustomerDoc.h"
#import "AppDelegate.h"
#import "AccountListTableViewCell.h"
#import "UIAlertView+AddBlockCallBacks.h"
#import "AddEcard_ViewController.h"
#import "AccountInAndOutList_ViewController.h"
#import "ThirdPatmentRecords_ViewController.h"
#import "WelfareViewController.h"

@interface AccountECard_ViewController ()<UITableViewDelegate,UITableViewDataSource,AddNewCarddelegate>

@property(nonatomic,strong)UITableView * cardTableView;
@property (nonatomic) NSMutableArray *views;
@property (strong, nonatomic) CustomerDoc *customer_Selected;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCustomerListOperation;
@property (nonatomic,strong)NSMutableArray *cardMarr;
@property (nonatomic,strong) UIImageView * starimageView;
@property (nonatomic ,assign)int cardDefultCount;
@property (nonatomic,assign)NSString * intergralNO;
@property (nonatomic,assign)NSString *cashCouponNO;

@end

@implementation AccountECard_ViewController
@synthesize customer_Selected;
@synthesize cardTableView,starimageView;
@synthesize cardMarr;


- (void)viewWillAppear:(BOOL)animated
{
    starimageView.hidden = YES;
    [super viewWillAppear:animated];
    [self requestCardList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_Background_View;
    [self requestCardList];
    [self initTableView];
}

#pragma mark - init
-(void)initTableView
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"账户"];
    
#pragma mark 权限
    if ([[PermissionDoc sharePermission] rule_Recharge_Use]) {
        [navigationView addButtonWithFrameWithTarget:self backgroundImage:[UIImage imageNamed:@"add_card_ios"] backGroundColor:nil title:nil frame:CGRectMake(280, 1, 36, 36) tag:1  selector:@selector(addCard)];
    }
    
    [self.view addSubview:navigationView];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    cardTableView = [[UITableView alloc] initWithFrame:CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f)style:UITableViewStyleGrouped];
    cardTableView.allowsSelection = YES;
    cardTableView.showsHorizontalScrollIndicator = NO;
    cardTableView.showsVerticalScrollIndicator = NO;
    cardTableView.backgroundColor = [UIColor clearColor];
    cardTableView.separatorColor = kTableView_LineColor;
    cardTableView.autoresizingMask = UIViewAutoresizingNone;
    cardTableView.delegate = self;
    cardTableView.dataSource = self;
    cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        cardTableView.sectionFooterHeight = 0;
        cardTableView.sectionHeaderHeight = 10;
    }
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [cardTableView setTableFooterView:view];
    [self.view addSubview:cardTableView];
    
    if ((IOS7 || IOS8)) {
        cardTableView.frame = CGRectMake( 5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f - 5.0f);
        cardTableView.separatorInset = UIEdgeInsetsZero;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        cardTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  - 5.0f);
    }
    
    self.cardDefultCount = 0 ;
 }

#pragma mark - UITableViewDelegate && UITableViewDataSource

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
    return 1;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int count = 0 ;
    if (RMO(@"|5|") || RMO(@"|6|")) {
        count = 1;
    }
    return cardMarr.count+2+count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == cardMarr.count) {
        //福利包
        AccountListTableViewCell  *AccountCell = [self configAccountCellTableViewCell:tableView indexPath:indexPath];
        AccountCell.layer.cornerRadius = 8;
        AccountCell.titleNameLabel.text = @"福利包";
        AccountCell.backgroundColor = [UIColor colorWithRed:176/255.0f green:35/255.0f blue:42/255.0f alpha:1.0f];
        AccountCell.titleNameLabel.frame = CGRectMake(30.0f, 30.0f, 130.0f, 20.0f);
        AccountCell.imageNext.frame = CGRectMake(AccountCell.contentView.frame.size.width-33, 32, 15, 18);
        return AccountCell;
    }else if (indexPath.section == cardMarr.count+1) {
        //账户交易记录
        static NSString * str = @"cell";
        UITableViewCell * cell = [cardTableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:str];
        }
        cell.layer.cornerRadius = 8 ;
        cell.textLabel.text = @"账户交易记录";
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.textLabel.font = kFont_Medium_18 ;
        UIImageView * imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(cardTableView.frame.size.width-23, 13, 15, 18)];
        imageNext.image = [UIImage imageNamed:@"blueArrows"];
        [cell.contentView addSubview:imageNext];
        return cell;
    }else if (indexPath.section == (cardMarr.count+2)) {
        //第三方交易查询
        static NSString * str = @"cell";
        UITableViewCell * cell = [cardTableView dequeueReusableCellWithIdentifier:str];
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:str];
        }
        cell.layer.cornerRadius = 8 ;
        cell.textLabel.text = @"第三方交易查询";
        cell.textLabel.textColor = kColor_DarkBlue;
        cell.textLabel.font = kFont_Medium_18 ;
        UIImageView * imageNext = [[UIImageView alloc] initWithFrame:CGRectMake(cardTableView.frame.size.width-23, 13, 15, 18)];
        imageNext.image = [UIImage imageNamed:@"blueArrows"];
        [cell.contentView addSubview:imageNext];
        return cell;
    }
    else
    {
        AccountListTableViewCell  *AccountCell = [self configAccountCellTableViewCell:tableView indexPath:indexPath];
        AccountCell.layer.cornerRadius = 8;
        starimageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 15, 15)];
        starimageView.image = [UIImage imageNamed:@"yellowStar"];
        starimageView.tag = 1001;
        [AccountCell addSubview:starimageView];
        starimageView.hidden = YES;
        if ([[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"IsDefault"] boolValue]) {
            starimageView.hidden = NO;
        }

        AccountCell.titleNameLabel.text = [[cardMarr objectAtIndex:indexPath.section] objectForKey:@"CardName"];
        
        NSInteger type = [[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"CardTypeID"] integerValue];
        
        AccountCell.contentText.text = [NSString stringWithFormat:@"%@",[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"UserCardNo"]];
        
        if (type==1) {
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,[[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"Balance"] doubleValue]];
            AccountCell.backgroundColor = [UIColor colorWithRed:249/255.0f green:152/255.0f blue:55/255.0f alpha:1.0f];
            self.cardDefultCount = 1;
        }else if(type ==2)
        {
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%.2f",[[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"Balance"] doubleValue]];
            AccountCell.backgroundColor = [UIColor colorWithRed:144/255.0f green:87/255.0f blue:203/255.0f alpha:1.0f];
        }else if(type ==3)
        {
            AccountCell.priceLable.text = [NSString stringWithFormat:@"%@%.2f",MoneyIcon,[[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"Balance"] doubleValue]];
            AccountCell.backgroundColor = [UIColor colorWithRed:129/255.0f green:193/255.0f blue:55/255.0f alpha:1.0f];
        }
        AccountCell.titleNameLabel.frame = CGRectMake(30.0f, 15.0f, 130.0f, 20.0f);
        AccountCell.imageNext.frame = CGRectMake(AccountCell.contentView.frame.size.width-33, 50, 15, 18);
        return AccountCell;//设置
    }
    
    return nil;
}

// 配置NormalEditCell
- (AccountListTableViewCell *)configAccountCellTableViewCell:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSString *cellIndentify =[NSString stringWithFormat: @"NormalEditCell1%ld%ld",(long)indexPath.row,(long)indexPath.section];
    AccountListTableViewCell *cell = [cardTableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[AccountListTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndentify];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];

    UIImageView *imageView= (UIImageView *)[cell viewWithTag:1001];
    [imageView removeFromSuperview];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == cardMarr.count + 1 ||  indexPath.section == (cardMarr.count + 2)) {
        return kTableView_HeightOfRow;
    }
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     if (indexPath.section == cardMarr.count) {
         WelfareViewController *welfareVC = [[WelfareViewController alloc]init];
         
         [self.navigationController pushViewController:welfareVC animated:YES];

     }else if (indexPath.section == cardMarr.count +1) {
        AccountInAndOutList_ViewController * inOut =[[AccountInAndOutList_ViewController alloc] init];
        [self.navigationController pushViewController:inOut animated:YES];
    }else if (indexPath.section == (cardMarr.count+2)){
    
        ThirdPatmentRecords_ViewController * records = [[ThirdPatmentRecords_ViewController alloc] init];
        records.customerID = (long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID;
        records.viewFor = 2 ;
        [self.navigationController pushViewController:records animated:YES];
        
    }else{
            //跳转到E卡详情页
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            RechargeViewController * recharge = [sb instantiateViewControllerWithIdentifier:@"RechargeViewController"];
            recharge.type = [[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"CardTypeID"] intValue];;//ecard
            recharge.defaultCard = [[[cardMarr objectAtIndex:indexPath.section] objectForKey:@"IsDefault"] boolValue];
            recharge.userCardNo = [[cardMarr objectAtIndex:indexPath.section]objectForKey:@"UserCardNo"];
            recharge.intergralNO = self.intergralNO;
            recharge.cashCouponNO = self.cashCouponNO;
            [self.navigationController pushViewController:recharge animated:YES];
    }
}

-(void)addCard
{
    AddEcard_ViewController * addCard = [[AddEcard_ViewController alloc] init];
    addCard.delegate = self ;
    addCard.cardNumber = (self.defaultCardNO.length >0 ? 1: 0);
    [self.navigationController pushViewController:addCard animated:YES];
}

-(void)requestCardList
{
    NSDictionary * dic =@{@"CustomerID":[NSString stringWithFormat:@"%ld",(long)((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID]};
    _requestCustomerListOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/ECard/GetCustomerCardList" andParameters:dic failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            cardMarr = [[NSMutableArray alloc] init];
            cardMarr = data;
            for (NSDictionary * dic in cardMarr) {
                if ([[dic objectForKey:@"CardTypeID"] integerValue] ==2) {
                    self.intergralNO = [dic objectForKey:@"UserCardNo"];
                }
                if ([[dic objectForKey:@"CardTypeID"] integerValue] ==3) {
                    self.cashCouponNO = [dic objectForKey:@"UserCardNo"];
                }
                
                if ([[dic objectForKey:@"IsDefault"] boolValue]) {
                    self.defaultCardNO = [dic objectForKey:@"UserCardNo"];
                }
            }
            [cardTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
