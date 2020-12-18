//
//  CollectListViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 15/10/12.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "CollectListViewController.h"
#import "CommodityDetailViewController.h"
#import "ServiceDetailViewController.h"

static CGFloat kTableViewCell_Height = 80;

@interface CollectListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,strong)NSArray * collectListArr;
@property (weak, nonatomic) AFHTTPRequestOperation *requestCollectList;
@end

@implementation CollectListViewController
@synthesize myTableView;
@synthesize collectListArr;

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getCollectList];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kDefaultBackgroundColor;
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"我的收藏";
    [self initTableView];
    
}

-(void)initTableView
{
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width,  kSCREN_BOUNDS.size.height - kNavigationBar_Height + 20 - 5)];
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

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewCell_Height;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return collectListArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentify = [NSString stringWithFormat:@"cell_%@",indexPath];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        UIImageView * topImageView =  topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTableViewCell_Height, kTableViewCell_Height)];
        topImageView.tag = 1000;
        [cell.contentView addSubview:topImageView];
        
        UILabel * titleLable  = [[UILabel alloc] initWithFrame:CGRectMake(kTableViewCell_Height + 10, 15, 200, 15)];
        titleLable.tag = 2000;
        titleLable.font = kNormalFont_14;
        titleLable.textColor = kColor_TitlePink;
        [cell.contentView addSubview:titleLable];
        
        UILabel * priceLable  = [[UILabel alloc] initWithFrame:CGRectMake(kTableViewCell_Height + 10, 50, 200, 15)];
        priceLable.tag = 3000;
        priceLable.font = kNormalFont_14;
        priceLable.textColor = kColor_Black;
        [cell.contentView addSubview:priceLable];

    }
  
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView * topImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
    NSDictionary * collectDic = [collectListArr objectAtIndex:indexPath.section];
    [topImageView setImageWithURL:[NSURL URLWithString:[collectDic objectForKey:@"ImgUrl"]] placeholderImage:[UIImage imageNamed:@"productDefaultImage"]];

    UILabel * titleLable = (UILabel *)[cell.contentView viewWithTag:2000];
    titleLable.text = [NSString stringWithFormat:@"%@  %@",[collectDic objectForKey:@"ProductName"],[collectDic objectForKey:@"Specification"]] ;

    UILabel * priceLable = (UILabel *)[cell.contentView viewWithTag:3000];
    priceLable.text = [NSString stringWithFormat:@"%@%@",CUS_CURRENCYTOKEN,[collectDic objectForKey:@"UnitPrice"]];
    
    return cell;
}
#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    NSDictionary * collectDic = [collectListArr objectAtIndex:indexPath.section];
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    if ([[collectDic objectForKey:@"ProductType"] integerValue]) {
        
        CommodityDetailViewController * commodity = (CommodityDetailViewController*)[sb instantiateViewControllerWithIdentifier:@"CommodityDetailViewController"];
        commodity.commodityCode = [[collectDic objectForKey:@"ProductCode"] longLongValue];
        [self.navigationController pushViewController:commodity animated:YES];
        
        
    }else{

        ServiceDetailViewController * service = (ServiceDetailViewController*)[sb instantiateViewControllerWithIdentifier:@"ServiceDetailViewController"];
        service.commodityCode = [[collectDic objectForKey:@"ProductCode"] longLongValue];
        [self.navigationController pushViewController:service animated:YES];
    }
}

#pragma mark - 接口
-(void)getCollectList
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary * Par = @{
                            @"ProductType":@(-1)
                           };
    _requestCollectList = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Customer/GetFavorteList" showErrorMsg:YES  parameters:Par WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            
            collectListArr = data;
            NSLog(@"collect =%@",collectListArr);
            [myTableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
        [SVProgressHUD dismiss];
        [myTableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
}



@end
