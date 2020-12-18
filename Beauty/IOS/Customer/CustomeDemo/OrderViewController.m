//
//  OrderViewController.m
//  GlamourPromise.Beauty.Customer
//
//  Created by macmini on 14-1-10.
//  Copyright (c) 2014年 MAC_Lion. All rights reserved.
//

#import "OrderViewController.h"
#import "GDataXMLNode.h"
#import "GDataXMLDocument+ParseXML.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "TitleView.h"
#import "OrderListViewController.h"
#import "OrderPayViewController.h"
#import "UILabel+InitLabel.h"

@interface OrderViewController ()
@property(weak, nonatomic) AFHTTPRequestOperation *requestGetOrderOperation;
@property(assign, nonatomic) NSInteger allOrderCount;
@property(assign, nonatomic) NSInteger unpaidOrderCount;
@property(assign, nonatomic) NSInteger serviceOrderCount;
@property(assign, nonatomic) NSInteger commodityOrderCount;
@property(assign, nonatomic) NSInteger flag; //页面跳转标记： 0全部 1未完成服务 2未交付商品
@end

@implementation OrderViewController
@synthesize allOrderCount;
@synthesize unpaidOrderCount;
@synthesize flag;
@synthesize serviceOrderCount;
@synthesize commodityOrderCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的订单";
    
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    [_tableView setFrame:CGRectMake(0, 0, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height - 25.0f)];

    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundColor = kDefaultBackgroundColor;
    _tableView.backgroundView = nil;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self getOrderCountByJson];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_requestGetOrderOperation || [_requestGetOrderOperation isExecuting]) {
        [_requestGetOrderOperation cancel];
        _requestGetOrderOperation = nil;
    }
    
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
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *orderCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(272.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 2.0f, 18.0f, 16.5f)];
    orderCountLabel.tag = 100;
    [orderCountLabel setTextColor:[UIColor whiteColor]];
    [orderCountLabel setBackgroundColor:[UIColor clearColor]];
    [orderCountLabel setFont:kFont_Number_Menu_12];
    [orderCountLabel setTextAlignment:NSTextAlignmentCenter];
    
    
    UILabel *titelLable = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 2.0f, 180, 16.5f)];
    titelLable.tag = 2000+indexPath.section;
    [titelLable setTextColor:kColor_TitlePink];
    [titelLable setFont:kFont_Light_16];

    
    UIImageView *orderCountImage = [[UIImageView alloc] initWithFrame:CGRectMake(272.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 1.5f, 18.0f, 16.5f)];
    orderCountImage.tag = 101;
    orderCountImage.image = [UIImage imageNamed:@"remindBackground"];
    
    if (IOS6) {
        [orderCountLabel setFrame:CGRectMake(282.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 2.0f, 18.0f, 16.5f)];
        [orderCountImage setFrame:CGRectMake(282.0f, (kTableView_HeightOfRow - kCell_LabelHeight)/2 + 1.5f, 18.0f, 16.5f)];
    }
    
    static NSString *cellIndentify = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        UIImageView * arrowsImage = (UIImageView *)[cell.contentView viewWithTag:3000+indexPath.row];
        if (!arrowsImage) {
            arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow -12)/2, 10, 12)];
            arrowsImage.tag = 3000+indexPath.row;
            arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
            [cell.contentView addSubview:arrowsImage];
        }
        
        cell.accessoryView.backgroundColor = kColor_TitlePink;
        cell.textLabel.font = kFont_Light_16;
        cell.textLabel.textColor = kColor_TitlePink;
        cell.backgroundColor = [UIColor whiteColor];
        [cell addSubview:orderCountImage];
        [cell addSubview:orderCountLabel];
        [cell addSubview:titelLable];
    }
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    UILabel *title = (UILabel *)[cell viewWithTag:2000+indexPath.section];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            title.text = @"所有订单";
            if (allOrderCount > 99) {
                label.text = [NSString stringWithFormat:@"n"];
            } else {
               label.text = [NSString stringWithFormat:@"%ld", (long)allOrderCount];
            }
            
            return cell;
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            title.text = @"进行中的服务";
            if (serviceOrderCount > 99) {
                label.text = [NSString stringWithFormat:@"n"];
            } else {
                label.text = [NSString stringWithFormat:@"%ld", (long)serviceOrderCount];
            }
            return cell;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            title.text = @"待接收的商品";
            if (commodityOrderCount > 99) {
                label.text = [NSString stringWithFormat:@"n"];
            } else {
                label.text = [NSString stringWithFormat:@"%ld", (long)commodityOrderCount];
            }
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.hidesBottomBarWhenPushed = YES;
    if (indexPath.section == 0 && indexPath.row == 0) {
        flag = 0;
        [self performSegueWithIdentifier:@"gotoOrderListViewFromOrderView" sender:self];
    } else if(indexPath.section == 1 && indexPath.row == 0){
        flag = 1;
        [self performSegueWithIdentifier:@"gotoOrderListViewFromOrderView" sender:self];
    } else if(indexPath.section == 2 && indexPath.row == 0){
        flag = 2;
        [self performSegueWithIdentifier:@"gotoOrderListViewFromOrderView" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoOrderListViewFromOrderView"]) {
        OrderListViewController *detailController = segue.destinationViewController;
        if (flag == 0) {
            detailController.requestType = -1;
            detailController.requestStatus = -1;
            detailController.requestIsPaid = -1;
        } else if(flag == 1) {
            detailController.requestType = 0;
            detailController.requestStatus = 1;
            detailController.requestIsPaid = -1;
        } else if(flag == 2){
            detailController.requestType = 1;
            detailController.requestStatus = 1;
            detailController.requestIsPaid = -1;
        }
    }
}

#pragma mark - 接口

- (void)getOrderCountByJson
{
    [SVProgressHUD showWithStatus:@"Loading"];
    _requestGetOrderOperation = [[GPCHTTPClient sharedClient] requestUrlPath:@"/order/GetOrderCount"  showErrorMsg:YES  parameters:@{@"CustomerID":@(CUS_CUSTOMERID)} WithSuccess:^(id json) {
        [ZWJson parseJson:json showErrorMsg:YES success:^(id data, NSInteger code, id message) {
            allOrderCount = [data[@"Total"] integerValue];
            unpaidOrderCount = [data[@"Unpaid"] integerValue];
            commodityOrderCount = [data[@"UndeliveredCommodity"] integerValue];
            serviceOrderCount = [data[@"UncompletedService"] integerValue];
            [_tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSInteger code, NSString *error) {
            
        }];
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
    }];
//    _requestGetOrderOperation = [[GPHTTPClient shareClient] requestGetOrderCountViaJsonWithSuccess:^(id xml) {
//        [SVProgressHUD dismiss];
//        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id data, NSInteger code, id message) {
//            allOrderCount = [data[@"Total"] integerValue];
//            unpaidOrderCount = [data[@"Unpaid"] integerValue];
//            commodityOrderCount = [data[@"UndeliveredCommodity"] integerValue];
//            serviceOrderCount = [data[@"UncompletedService"] integerValue];
//            [_tableView reloadData];
//        } failure:^(NSInteger code, NSString *error) {
//            
//        }];
//    } failure:^(NSError *error) {
//        [SVProgressHUD dismiss];
//    }];
}
@end
