//
//  ShopSecondViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//
const CGFloat kCell_Height = 113.0;


#import "ShopSecondViewController.h"
#import "GPCHTTPClient.h"
#import "SalesPromotionModel.h"
#import "PromotionDetail_ViewController.h" 
#import "IndexTableViewCell.h"


@interface ShopSecondViewController ()
@property (nonatomic, weak) AFHTTPRequestOperation *salesPromotionRequest;
@property (nonatomic, strong) NSMutableArray *promotionArray;

@end

@implementation ShopSecondViewController
static NSString *salesIden = @"salesIden";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestSalesPromotion];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0,-10, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height -kNavigationBar_Height- (0.5 + 5) + 20);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = kColor_Clear;
    self.tableView.separatorColor = kTableView_LineColor;
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
}

#pragma mark -  UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.promotionArray count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCell_Height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_DefaultHeaderViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_DefaultFooterViewHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier =@"Cell";
    IndexTableViewCell *cell = (IndexTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"IndexTableViewCell" owner:self options:nil] objectAtIndex:0];
        cell.backgroundColor = kColor_White;
        cell.tintColor = kColor_White;
    }
    SalesPromotionModel *sales = self.promotionArray[indexPath.section];
    cell.data = sales;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PromotionDetail_ViewController *promotionController = [[PromotionDetail_ViewController alloc]init];
    promotionController.promotionCode = [self.promotionArray[indexPath.section] valueForKey:@"PromotionCode"];
    [self.navigationController pushViewController:promotionController animated:YES];
}

#pragma mark - 促销信息的网络请求
- (void)requestSalesPromotion
{
    [SVProgressHUD showWithStatus:@"Loading"];
    NSDictionary *para = @{@"ImageHeight":@(kCell_Height),
                           @"ImageWidth":@150,
                           @"BranchID":@((long)self.BranchID)
                           };

    _salesPromotionRequest = [[GPCHTTPClient sharedClient] requestUrlPath:@"/Promotion/GetPromotionList" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [array addObject:[[SalesPromotionModel alloc] initWithDic:obj]];
            }];
            self.promotionArray = [array mutableCopy];
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            [SVProgressHUD showErrorWithStatus:error];
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
}
@end
