//
//  BusinessViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-3-27.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "BusinessViewController.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "UILabel+InitLabel.h"
#import "SalonDetailViewController.h"
#import "TitleView.h"
#import "AccountDetailViewController.h"

@interface BusinessViewController ()
@end

@implementation BusinessViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kColor_Background_View;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    TitleView *titleView = [[TitleView alloc] init];
//    [self.view addSubview:[titleView getTitleView:[[NSUserDefaults standardUserDefaults]objectForKey:@"CUSTOMER_COMPANYABBREVIATION"]]];
       [self.view addSubview:[titleView getTitleView:@"商家信息"]];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [_tableView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, kSCREN_BOUNDS.size.height - 25.0f)];
    } else {
        _tableView.frame = CGRectMake(-5.0f, 41.0f, 330.0f, kSCREN_BOUNDS.size.height  - 45.0f );
    }
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = kColor_Background_View;
    _tableView.backgroundView = nil;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 5.f;
    } else {
        return 2.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(ACC_BRANCHID == 0)
        return 4;
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    }
    else if (section == 3) {
        return 1;
    }
    else if (section == 4) {
        return 1;
    }
    else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIndentify = @"businessCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];

    }
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, (kTableView_HeightOfRow -20)/2, 200, 20)];
    titleLable.font = kFont_Light_14;
    titleLable.tag = 1000+indexPath.section;
    [cell.contentView addSubview:titleLable];
    
    UILabel *label = (UILabel *)[cell viewWithTag:1000+indexPath.section];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            label.text = @"商家详情";
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            label.text = @"门店信息";
            return cell;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0 && ACC_BRANCHID != 0) {
            label.text = @"本店信息";
            return cell;
        }else if (indexPath.row == 0){
            label.text = @"我的信息";
            return cell;
        }
    }
    else if (indexPath.section == 3){
        if (indexPath.row == 0 && ACC_BRANCHID != 0) {
            label.text = @"我的信息";
            //label.text = [NSString stringWithFormat:@"(%d)", 1];
            return cell;
        }else if(indexPath.row == 0){
            label.text = @"公告";
            return cell;
        }
    }
    else if (indexPath.section == 4){
        if (indexPath.row ==0) {
            label.text = @"公告";
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"goCompanyViewFromBusinessView" sender:self];
    } else if(indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"goShopListViewFromBusinessView" sender:self];
    } else if(indexPath.section == 2 && indexPath.row == 0){
        if(ACC_BRANCHID == 0)
            [self performSegueWithIdentifier:@"goAccountDetailViewFromBusinessView" sender:self];
        else
            [self performSegueWithIdentifier:@"goShopViewFromBusinessView" sender:self];
    } else if(indexPath.section == 3 && indexPath.row == 0){
        if(ACC_BRANCHID == 0)
            [self performSegueWithIdentifier:@"goNoticeViewFromBusinessView" sender:self];
        else
            [self performSegueWithIdentifier:@"goAccountDetailViewFromBusinessView" sender:self];
    } else if(indexPath.section == 4 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"goNoticeViewFromBusinessView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goCompanyViewFromBusinessView"]) {
        SalonDetailViewController *detailController = segue.destinationViewController;
        detailController.tag = 0;
    }
    if ([segue.identifier isEqualToString:@"goAccountDetailViewFromBusinessView"]) {
        AccountDetailViewController *detailController = segue.destinationViewController;
        detailController.accountId = ACC_ACCOUNTID;
    }
    if ([segue.identifier isEqualToString:@"goShopViewFromBusinessView"]) {
        SalonDetailViewController *detailController = segue.destinationViewController;
        detailController.branchId = ACC_BRANCHID;
        detailController.tag = 1;
    }
}

@end
