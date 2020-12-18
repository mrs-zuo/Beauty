//
//  FilterComOrderController.m
//  GlamourPromise.Beauty.Business
//
//  Created by TRY-MAC01 on 15/7/17.
//  Copyright (c) 2015年 ace-009. All rights reserved.
//

#import "FilterComOrderController.h"
#import "NavigationView.h"
#import "DFUITableView.h"
#import "OrderInfoCell.h"
#import "FooterView.h"
#import "SelectViewController.h"
#import "ComOrderFilter.h"
#import "ColorImage.h"

@interface FilterComOrderController ()<UITableViewDataSource, UITableViewDelegate, SelectViewControllerDelegate>
@property (nonatomic, weak) NavigationView *navigaView;
@property (nonatomic, weak) DFUITableView *tableView;
@property (nonatomic, strong) ComOrderFilter *selectFilter;
@end

@implementation FilterComOrderController

static NSString *cellIdentifier = @"filterCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)initView
{
    self.view.backgroundColor = kColor_Background_View;
    self.tableView.frame = CGRectMake(5.0f, self.navigaView.frame.origin.y + self.navigaView.frame.size.height, 310.0f, 120);
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    FooterView *footerView = [[FooterView alloc]initWithTarget:self subTitle:@"筛选" submitAction:@selector(searchCustomer) deleteTitle:@"重置" deleteAction:@selector(resetData)];

    footerView.deleteButton.frame = CGRectMake(0.0f,  10, 148.0f, 36.0f);
    footerView.submitButton.frame = CGRectMake(0.0f + footerView.deleteButton.frame.size.width + 7, 10, 148.0f, 36.0f);
    footerView.frame = CGRectMake(5.0, self.tableView.frame.origin.y +self.tableView.frame.size.height - 20, 310.0, 51.0);
    [self.view addSubview:footerView];
}

- (void)initData
{
    self.selectFilter = [[ComOrderFilter alloc] init];
    self.selectFilter.customerName = self.originFilter.customerName;
    self.selectFilter.personName = self.originFilter.personName;
}

- (void)searchCustomer
{
    if ([self.delegate respondsToSelector:@selector(searchCustomer:person:)]) {
        self.originFilter.customerName = self.selectFilter.customerName;
        self.originFilter.personName = self.selectFilter.personName;
        [self.delegate searchCustomer:self.selectFilter.customerName person:self.selectFilter.personName];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetData
{
    self.selectFilter = [[ComOrderFilter alloc] init];
    [self.tableView reloadData];
}

- (void)selectNameOfFilterNameObject:(NSString *)nameObject titleName:(NSString *)title
{
    if ([title isEqualToString:@"选择顾客"]) {
        self.selectFilter.customerName = nameObject;
    } else {
        self.selectFilter.personName = nameObject;
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableView_HeightOfRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"选择顾客";
        cell.detailTextLabel.text = self.selectFilter.customerName ? self.selectFilter.customerName : @"请选择顾客";
    } else {
        cell.textLabel.text = @"美丽顾问";
        cell.detailTextLabel.text = self.selectFilter.personName ? self.selectFilter.personName : @"请选择美丽顾问";
    }
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.detailTextLabel.frame =CGRectMake(150, 0, 130, kTableView_HeightOfRow);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SelectViewController *selectVC = [[SelectViewController alloc] init];
    selectVC.dataArray = (indexPath.section == 0 ? self.customerList : self.accountList);
    selectVC.selectTitle = (indexPath.section == 0 ? @"选择顾客" : @"选择美丽顾问");
    selectVC.selectName = (indexPath.section == 0 ? self.selectFilter.customerName : self.selectFilter.personName);
    selectVC.delegate = self;
    [self.navigationController pushViewController:selectVC animated:YES];
}

- (NavigationView *)navigaView
{
    if (_navigaView == nil) {
        NavigationView *nav = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"结单筛选"];
        
        [self.view addSubview:_navigaView = nav];
    }
    return _navigaView;
}

- (DFUITableView *)tableView
{
    if (_tableView == nil) {
        DFUITableView *tab = [[DFUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tab.delegate = self;
        tab.dataSource = self;
        tab.separatorColor = kTableView_LineColor;
        [tab registerClass:[OrderInfoCell class] forCellReuseIdentifier:cellIdentifier];
        [self.view addSubview:_tableView = tab];
    }
    return _tableView;
}

@end
