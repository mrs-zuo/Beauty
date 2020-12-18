//
//  ReportMasterViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 14-1-20.
//  Copyright (c) 2014年 ace-009. All rights reserved.
//

#import "ReportMasterViewController.h"
#import "ReportBasicViewController.h"
#import "ReportListViewController.h"
#import "NavigationView.h"
#import "DEFINE.h"
#import "ReportCountViewController.h"
#import "ReportMarkingViewController.h"
#import "ReportStatisticsViewController.h"
#import "MyReportViewController.h"
#import "ReportFinancialViewController.h"

#define ACC_COM [[PermissionDoc sharePermission] rule_BusinessReport_Read]

@interface ReportMasterViewController ()
@property (nonatomic, strong) NSMutableArray *reportTitleArray;
@property (nonatomic, strong) NSMutableArray *reportSectionArray;
@property (nonatomic, strong) NSMutableArray *reportOurShopArray;
@property (nonatomic, strong) NSMutableArray *reportEachShopArray;
@property (nonatomic, strong) NSMutableArray *reportAllShopArray;
@property (nonatomic, assign) BOOL isOurShopShow;
@property (nonatomic, assign) BOOL isEachShopShow;
@property (nonatomic, assign) BOOL isAllShopShow;
@property (nonatomic, strong) UIButton *button;
@end

@implementation ReportMasterViewController

@synthesize isOurShopShow, isEachShopShow, isAllShopShow;
@synthesize button;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _reportTitleArray = [NSMutableArray array];

    if ([[PermissionDoc sharePermission] rule_MyReport_Read] ) {
        
        if (ACC_BRANCHID != 0) {
            [_reportTitleArray addObject:@"我的报表"];
        }
        
        [_reportTitleArray addObject:@"员工报表"];
        
    }
    isOurShopShow = NO;
    isEachShopShow = NO;
    isAllShopShow = NO;
    if ([[PermissionDoc sharePermission] rule_BusinessReport_Read]) {
        [_reportTitleArray addObject:@"分组报表"];
        
        _reportSectionArray = [NSMutableArray array];
        if (ACC_BRANCHID == 0) {
            _reportEachShopArray = [NSMutableArray array];
            [_reportEachShopArray addObject:@"各门店报表"];
            [_reportEachShopArray addObject:@"  周期数据统计"];
            [_reportEachShopArray addObject:@"  累计数据统计"];

            _reportAllShopArray = [NSMutableArray array];
            [_reportAllShopArray addObject:@"全公司报表"];
            [_reportAllShopArray addObject:@"  周期数据统计"];
            [_reportAllShopArray addObject:@"  累计数据统计"];
            
            [_reportSectionArray addObject:_reportEachShopArray];
            [_reportSectionArray addObject:_reportAllShopArray];
            
        } else {
            _reportOurShopArray = [NSMutableArray array];
            [_reportOurShopArray addObject:@"门店报表"];
            
            [_reportOurShopArray addObject:@"  财务数据总览"];
            //追加门店运营状况  2015.8.10 改为 运营状况统计
            [_reportOurShopArray addObject:@"  运营状况统计"];
            [_reportOurShopArray addObject:@"  周期数据统计"];
            [_reportOurShopArray addObject:@"  累计数据统计"];
            [_reportOurShopArray addObject:@"  数据统计分析"];

            [_reportSectionArray addObject:_reportOurShopArray];
        }
    }

    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"报表"];
    [self.view addSubview:navigationView];
    

    _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) -  5.0f);
    
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.separatorInset = UIEdgeInsetsZero;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_reportTitleArray count] + [_reportSectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (ACC_COM && (section >= _reportTitleArray.count) ) {
        if (section - _reportTitleArray.count == 0) {
            if (_reportOurShopArray) {
//                return  isOurShopShow ? 4 : 1;
                return isOurShopShow ? _reportOurShopArray.count : 1;
            }
            if (_reportEachShopArray) {
                return isEachShopShow ? 3 : 1;
            }

        }
        if (section - _reportTitleArray.count == 1) {
            if (_reportAllShopArray) {
                return isAllShopShow ? 4 : 1;
            }
  
        }
    }
        return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ReportMasterCell";
    static NSString *cellSection = @"ReportSection";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    UITableViewCell *section = [tableView dequeueReusableCellWithIdentifier:cellSection];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, (kTableView_HeightOfRow-20) /2, 200, 20)];
    titleLable.font = kFont_Light_16;
    titleLable.textColor = kColor_DarkBlue;
    [cell.contentView addSubview:titleLable];
    titleLable.tag = 1000 +indexPath.section;
    
    UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
    arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
    
    if (ACC_COM && (indexPath.section >= (_reportTitleArray.count))) {
        NSArray *array = [NSArray arrayWithArray:[_reportSectionArray objectAtIndex:(indexPath.section - (_reportTitleArray.count))]];
        switch (indexPath.row) {
            case 0:
            {
                if (section == nil) {
                    section = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellSection];
       
                        UIImageView *first = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up_arrow"]];
                        UIImageView *second = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"down_arrow"]];
                        first.frame = CGRectMake(290, kTableView_HeightOfRow / 2 - 15 / 2, 15.0f , 10.0f);
                        second.frame = CGRectMake(290, kTableView_HeightOfRow / 2 - 15 / 2, 15.0f , 10.0f);
                        first.tag = 100;
                        second.tag = 101;
                        
                        first.hidden = YES;
                        second.hidden = YES;
                        [section.contentView addSubview:first];
                        [section.contentView addSubview:second];
                        section.accessoryType = UITableViewCellAccessoryNone;

                }
                NSString * title = [array objectAtIndex:indexPath.row];
                
                if (IOS7) {
                    for (UIView *view in [[section subviews][0] subviews]) {
                        if ([view isMemberOfClass:[UIButton class]]) {
                            button = (UIButton*)view;
                        }
                    }
                } else {
                    for (UIView *view in [section subviews]) {
                        if ([view isMemberOfClass:[UIButton class]]) {
                            button = (UIButton*)view;
                        }
                    }
                }

                UIImage *imageShow = [UIImage imageWithCGImage:button.currentBackgroundImage.CGImage scale:2.0 orientation:UIImageOrientationLeft];
                UIImage *imageHidden = [UIImage imageWithCGImage:button.currentBackgroundImage.CGImage scale:2.0 orientation:UIImageOrientationRight];
                
                if ([title isEqualToString:@"各门店报表"]) {
                    [button setBackgroundImage:(isEachShopShow ? imageShow : imageHidden) forState:UIControlStateNormal];
                }
                if ([title isEqualToString:@"全公司报表"]) {
                    [button setBackgroundImage:(isAllShopShow ? imageShow : imageHidden) forState:UIControlStateNormal];
                }
                if ([title isEqualToString:@"门店报表"]) {
                    [button setBackgroundImage:(isOurShopShow ? imageShow : imageHidden) forState:UIControlStateNormal];
                }

                UIImageView *one = (UIImageView*)[section.contentView viewWithTag:100];
                UIImageView *two = (UIImageView*)[section.contentView viewWithTag:101];

                if ([title isEqualToString:@"各门店报表"]) {
                    one.hidden = !isEachShopShow;
                    two.hidden = isEachShopShow;
                }
                if ([title isEqualToString:@"全公司报表"]) {
                    one.hidden = !isAllShopShow;
                    two.hidden = isAllShopShow;
                }
                if ([title isEqualToString:@"门店报表"]) {
                    one.hidden = !isOurShopShow;
                    two.hidden = isOurShopShow;
                }
                
                [section.contentView addSubview:titleLable];
               
                UILabel *titleL = (UILabel*)[section.contentView viewWithTag:1000 +indexPath.section];
                titleL.text = title;
              

                section.textLabel.font = kFont_Light_16;
                section.textLabel.textColor = kColor_DarkBlue;
                
                return section;
            }
            case 1:
                [cell addSubview:arrowsImage];
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = kFont_Light_16;
                cell.textLabel.textColor = kColor_DarkBlue;
                return cell;
            case 2:
                [cell addSubview:arrowsImage];
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = kFont_Light_16;
                cell.textLabel.textColor = kColor_DarkBlue;
                return cell;
            case 3:
                [cell addSubview:arrowsImage];
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = kFont_Light_16;
                cell.textLabel.textColor = kColor_DarkBlue;
                return cell;
            case 4:
                [cell addSubview:arrowsImage];
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = kFont_Light_16;
                cell.textLabel.textColor = kColor_DarkBlue;
                return cell;
            case 5:
                [cell addSubview:arrowsImage];
                cell.textLabel.text = [array objectAtIndex:indexPath.row];
                cell.textLabel.font = kFont_Light_16;
                cell.textLabel.textColor = kColor_DarkBlue;
                return cell;
            default:
                NSLog(@"ReportMasterViewController is error indexPath");
                return cell;
        }
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell addSubview:arrowsImage];
        
        UILabel *title = (UILabel*)[cell.contentView viewWithTag:1000 +indexPath.section];
        
        title.text = [_reportTitleArray objectAtIndex:indexPath.section];

        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section >= _reportTitleArray.count ) {
        if (indexPath.row == 0) {
            NSString *reporTitler = [[_reportSectionArray objectAtIndex:(indexPath.section - _reportTitleArray.count)] objectAtIndex:0];
            if ([reporTitler isEqualToString:@"门店报表"]) {
                isOurShopShow = !isOurShopShow;
            }
            if ([reporTitler isEqualToString:@"各门店报表"]) {
                isEachShopShow = !isEachShopShow;
            }
            if ([reporTitler isEqualToString:@"全公司报表"]) {
                isAllShopShow = !isAllShopShow;
            }
            [_tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        }

        if (indexPath.row == 1) {
            NSString *reporTiter = [[_reportSectionArray objectAtIndex:(indexPath.section - _reportTitleArray.count)] objectAtIndex:0];
            if ([reporTiter isEqualToString:@"门店报表"]) {
                ReportFinancialViewController *financialVC = [[ReportFinancialViewController alloc] init];
                [self.navigationController pushViewController:financialVC animated:YES];
                
            } else if ([reporTiter isEqualToString:@"各门店报表"]){
                ReportListViewController *reportListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportListViewController"];
                reportListVC.reportTitle = reporTiter;
                [self.navigationController pushViewController:reportListVC animated:YES];
            } else {
                ReportBasicViewController *reportBasicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
                reportBasicVC.reportTitle = reporTiter;
                [self.navigationController pushViewController:reportBasicVC animated:YES];
            }
        }
        
        if (indexPath.row == 2) {
            NSString *reporTiter = [[_reportSectionArray objectAtIndex:(indexPath.section - _reportTitleArray.count)] objectAtIndex:0];
            if ([reporTiter isEqualToString:@"各门店报表"]) {
                ReportListViewController *reportListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportListViewController"];
                reportListVC.reportTitle = @"各门店统计";
                [self.navigationController pushViewController:reportListVC animated:YES];
            } else {
                
                ReportMarkingViewController *reportMarkingVC = [[ReportMarkingViewController alloc] init];
                [self.navigationController pushViewController:reportMarkingVC animated:YES];
//                ReportBasicViewController *reportBasicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
//                reportBasicVC.reportTitle = reporTiter;
//                [self.navigationController pushViewController:reportBasicVC animated:YES];
            }
        }
        if (indexPath.row == 3) {
            NSString *reporTiter = [[_reportSectionArray objectAtIndex:(indexPath.section - _reportTitleArray.count)] objectAtIndex:0];
            ReportBasicViewController *reportBasicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
            reportBasicVC.reportTitle = reporTiter;
            [self.navigationController pushViewController:reportBasicVC animated:YES];
        }
        if (indexPath.row == 4) {
            ReportCountViewController *reporCount = [[ReportCountViewController alloc] init];
            reporCount.branchID = ACC_BRANCHID;
            [self.navigationController pushViewController:reporCount animated:YES];

        }
        if (indexPath.row ==5) {
            ReportStatisticsViewController *statisticeVC = [[ReportStatisticsViewController alloc] init];
            [self.navigationController pushViewController:statisticeVC animated:YES];

        }
    }
    if (indexPath.section < _reportTitleArray.count) {
        NSString *reportTitleStr = [_reportTitleArray objectAtIndex:indexPath.section];
        if ([reportTitleStr isEqualToString:@"我的报表"])
        {
            
                NSNumber *isComissionCalc = [[NSUserDefaults standardUserDefaults]objectForKey:@"current_isComissionCalc"];
                if (isComissionCalc.boolValue) {
                    MyReportViewController *myReportVC = [[MyReportViewController alloc]init];
                    [self.navigationController pushViewController:myReportVC animated:YES];
                }else{
                    ReportBasicViewController *reportBasicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
                    reportBasicVC.reportTitle = [_reportTitleArray objectAtIndex:indexPath.section];
                    [self.navigationController pushViewController:reportBasicVC animated:YES];
                }

        } else {
            ReportListViewController *reportListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportListViewController"];
            reportListVC.reportTitle = [_reportTitleArray objectAtIndex:indexPath.section];
            [self.navigationController pushViewController:reportListVC animated:YES];
        }
    }
}

@end
