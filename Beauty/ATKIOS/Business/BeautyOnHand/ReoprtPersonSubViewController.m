//
//  ReoprtPersonSubViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/4/8.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "ReoprtPersonSubViewController.h"
#import "GPNavigationController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "NormalEditCell.h"
#import "ReportPersonAnalyzeViewController.h"
#import "ReportPersonAnalyzeCompositorViewController.h"

@interface ReoprtPersonSubViewController ()  <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) NSMutableArray *data;
@property(nonatomic,strong)UITableView *tableView;
@end

@implementation ReoprtPersonSubViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f,  5.0f) title:@"员工业务数据统计"];
    
    [self.view addSubview:navigationView];
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - 64.0f - ( 5.0f + navigationView.frame.size.height) - 5.0f);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = kTableView_LineColor;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = nil;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
        _tableView.sectionFooterHeight = 0;
        _tableView.sectionHeaderHeight = 10;
    }
    if ((IOS7 || IOS8)) _tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:_tableView];
    
    _data = [NSMutableArray arrayWithObjects:@"员工业绩占比图表",@"员工业绩排行榜", nil];
}
#pragma mark - UITableViewDataSource && UITableViewDelegate

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
    return kTableView_HeightOfRow;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentity = @"NormalEditCell";
    NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentity];
    if (cell ==  nil) {
        cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentity];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    cell.titleLabel.text = _data[indexPath.section];
    cell.valueText.textColor = [UIColor blackColor];
    cell.valueText.enabled = NO;
    [cell setAccessoryText:@"   "];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            ReportPersonAnalyzeViewController *personVC = [[ReportPersonAnalyzeViewController alloc]init];
            [self.navigationController pushViewController:personVC animated:YES];
        }
            break;
        case 1:
        {
            ReportPersonAnalyzeCompositorViewController *personAnalyzeCompositorVC = [[ReportPersonAnalyzeCompositorViewController alloc]init];
            [self.navigationController pushViewController:personAnalyzeCompositorVC animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
