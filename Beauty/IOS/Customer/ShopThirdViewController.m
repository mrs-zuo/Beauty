//
//  ShopThirdViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/2.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "ShopThirdViewController.h"
#import "GPCHTTPClient.h"
#import "AccountDoc.h"  
#import "ServiceCell.h"
#import "AccountDetailViewController.h"
#import "ShopInfoModel.h"

@interface ShopThirdViewController ()
@property (nonatomic, weak) AFHTTPRequestOperation *accountListRequest;
@property (nonatomic, strong) NSMutableArray *accountArray;
@end

@implementation ShopThirdViewController

static NSString *cellIndentify = @"ServiceCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.frame = CGRectMake(0,-5, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - kNavigationBar_Height- (0.5 + 5) + 20);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = kTableView_LineColor;
    [self.tableView registerClass:[ServiceCell class] forCellReuseIdentifier:cellIndentify];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestAccountList];
}


#pragma mark UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accountArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    AccountDoc *accDoc = [self.accountArray objectAtIndex:indexPath.row];
    cell.accountDoc = accDoc;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.parentViewController.hidesBottomBarWhenPushed = YES;

    AccountDoc *accDoc = [self.accountArray objectAtIndex:indexPath.row];
    AccountDetailViewController *accDetailVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AccountDetail"];

    accDetailVC.accountId = accDoc.acc_ID;
    [self.navigationController pushViewController:accDetailVC animated:YES];
}
#pragma mark -  接口
- (void)requestAccountList
{
    NSDictionary *para = @{@"CustomerID":@(CUS_CUSTOMERID),
                           @"Flag":@(2),
                           @"BranchID":@(self.shopInfo.BranchID)};

    _accountListRequest = [[GPCHTTPClient sharedClient] requestUrlPath:@"/account/getAccountListForCustomer" showErrorMsg:YES parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            NSDictionary *dict = @{@"acc_ID":@"AccountID",
                                   @"acc_Name":@"AccountName",
                                   @"acc_Department":@"Department",
                                   @"acc_Title":@"Title",
                                   @"acc_Expert":@"Expert",
                                   @"acc_HeadImgURL":@"HeadImageURL",
                                   @"acc_PinYin":@"PinYin",
                                   @"acc_PinYinFirst":@"PinYinFirst"};
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                AccountDoc *account =[[AccountDoc alloc] init];
                [account assignObjectPropertyWithDictionary:obj andObjectPropertyAssociatedDictionary:dict];
                [tmpArray addObject:account];
            }];
            self.accountArray = [tmpArray mutableCopy];
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        
    }];
}
@end
