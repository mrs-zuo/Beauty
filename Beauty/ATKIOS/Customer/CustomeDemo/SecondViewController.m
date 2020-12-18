                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             //
//  SecondViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by TRY-MAC01 on 15/9/1.
//  Copyright (c) 2015年 MAC_Lion. All rights reserved.
//

#import "SecondViewController.h"
#import "CompanyDoc.h"  
#import "ShopListCell.h"
#import "ShopInfoModel.h"
#import "ShopInfoViewController.h"

#import "SalonDetailViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) AFHTTPRequestOperation *salonListOperation;
@property (nonatomic) CompanyDoc *companyDoc_Selected;
@property (strong) NSMutableArray *salonList;

@end

@implementation SecondViewController
@synthesize salonList;
@synthesize companyDoc_Selected;

static NSString *cellIndentify = @"MyCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.tableView.frame = CGRectMake(0,-35,kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 40);

    self.tableView.separatorColor = kTableView_LineColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 70;
    [self.tableView registerClass:[ShopListCell class] forCellReuseIdentifier:cellIndentify];
    [self.tableView reloadData];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requesSalonList];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [salonList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    ShopInfoModel *salonData = [self.salonList objectAtIndex:indexPath.row];
    cell.shop = salonData;
    return cell;
}
#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.parentViewController.hidesBottomBarWhenPushed = YES;
    ShopInfoModel *shopInfo = [self.salonList objectAtIndex:indexPath.row];
    ShopInfoViewController *salonInfoVC = [[ShopInfoViewController alloc] init];
    salonInfoVC.currentShop = shopInfo;
    salonInfoVC.BranchID =  shopInfo.BranchID;
    [self.navigationController pushViewController:salonInfoVC animated:YES];
}
#pragma mark - 接口

- (void)requesSalonList
{
     NSDictionary *para;
    if ([CLLocationManager locationServicesEnabled] &&([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)) {
        NSNumber *longitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"longitude"];
        NSNumber *latitude = [[NSUserDefaults standardUserDefaults]objectForKey:@"latitude"];
        if (longitude && latitude) {
            para = @{@"Longitude":longitude,
                     @"Latitude":latitude,
                     };
        }
    }
    _salonListOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/company/getBranchList"  showErrorMsg:YES  parameters:para WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            NSMutableArray *salonArray = [NSMutableArray array];
            [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [salonArray addObject:[[ShopInfoModel alloc] initWithDic:obj]];
            }];
            salonList = salonArray;
            [self.tableView reloadData];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
    }];
}

@end
