//
//  MyReportViewController.m
//  GlamourPromise.Beauty.Business
//
//  Created by macmini on 16/5/3.
//  Copyright © 2016年 ace-009. All rights reserved.
//

#import "MyReportViewController.h"
#import "NavigationView.h"
#import "ReportBasicViewController.h"
#import "PushMoenyViewController.h"


@interface MyReportViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *myDatas;

@end

@implementation MyReportViewController

- (void)initData
{
    self.myDatas = [NSMutableArray arrayWithObjects:@"业绩",@"提成", nil];
}
- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"我的报表"];
    [self.view addSubview:navigationView];
    
    _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, kSCREN_BOUNDS.size.width - 10, kSCREN_BOUNDS.size.height - (navigationView.frame.origin.y + navigationView.frame.size.height) -  5.0f) style:UITableViewStyleGrouped];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    _myTableView.showsHorizontalScrollIndicator = NO;
    _myTableView.showsVerticalScrollIndicator = NO;
    _myTableView.backgroundView = nil;
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.separatorColor = kTableView_LineColor;
    _myTableView.separatorInset = UIEdgeInsetsZero;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone&&screenSize.height > screenSize.width&&screenSize.height == 568) {
        _myTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN + 5 )];
    }
    [self.view addSubview:_myTableView];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initView];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.myDatas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  kTableView_HeightOfRow;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"ReportMasterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        cell.backgroundColor = [UIColor whiteColor];
        UILabel * titleLable = [[UILabel alloc] initWithFrame:CGRectMake(5, (kTableView_HeightOfRow-20) /2, 200, 20)];
        titleLable.font = kFont_Light_16;
        titleLable.textColor = kColor_DarkBlue;
        titleLable.tag = 100;
        [cell.contentView addSubview:titleLable];
        UIImageView * arrowsImage = [[UIImageView alloc] initWithFrame:CGRectMake(295, (kTableView_HeightOfRow-12)/2, 10, 12)];
        arrowsImage.image = [UIImage imageNamed:@"arrows_bg"];
        [cell.contentView addSubview:arrowsImage];
    }
    UILabel * titleLable = [cell.contentView viewWithTag:100];
    titleLable.text = self.myDatas[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.myDatas[indexPath.row];
    if ([title isEqualToString:@"业绩"]) {
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
        ReportBasicViewController *reportBasicVC = [board instantiateViewControllerWithIdentifier:@"ReportBasicViewController"];
        reportBasicVC.reportTitle = @"我的报表";
        [self.navigationController pushViewController:reportBasicVC animated:YES];
    } else if ([title isEqualToString:@"提成"]) {
        PushMoenyViewController *pushVC = [[PushMoenyViewController alloc]init];
        [self.navigationController pushViewController:pushVC animated:YES];
    }
}



@end
