//
//  ContactDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "ContactDoc.h"
#import "ScheduleDoc.h"

@interface ContactDetailViewController ()
@end

@implementation ContactDetailViewController
@synthesize myTableView;
@synthesize contactDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
    myTableView.autoresizesSubviews = UIViewAutoresizingNone;
    myTableView.frame = CGRectMake(-5.0f, 41.0f, 330.0f, kSCREN_BOUNDS.size.height - 44.0f - 5.0f);
    
    //在(IOS7 || IOS8)的情况下重新计算起始点
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
        [myTableView setFrame:CGRectMake(5.0f, 41.0f, 310.0f, 550.0f)];
    }
    
    //初始化TitleView
    TitleView *titleView = [[TitleView alloc] init];
    [self.view addSubview:[titleView getTitleView:@"订单详情"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setMyTableView:nil];
    [super viewDidUnload];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"timeCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"时间";
            cell.valueText.text = contactDoc.cont_Schedule.sch_ScheduleTime;
            cell.valueText.enabled = NO;
            cell.valueText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        } else {
            static NSString *cellIndentify = @"stateCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"状态";
            if (contactDoc.cont_Schedule.sch_Completed == 0) {
                cell.valueText.text = @"未完成";
            } else {
                cell.valueText.text = @"已完成";
            }
            cell.valueText.enabled = NO;
            cell.valueText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }else {
        if (indexPath.row == 0) {
            static NSString *cellIndentify = @"contactRecordCell";
            NormalEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[NormalEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.titleLabel.text = @"联系记录";
            cell.valueText.enabled = NO;
            cell.valueText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }else {
            static NSString *cellIndentify = @"contactContentCell";
            ContentEditCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
            if (cell == nil) {
                cell = [[ContentEditCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
            }
            cell.contentEditText.text = contactDoc.cont_Remark;
            cell.contentEditText.editable = NO;
            cell.contentEditText.textColor = [UIColor blackColor];
            cell.backgroundColor = [UIColor whiteColor];
            return cell;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        return 120.0f;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return kTableView_WithTitle;
    } else {
        return kTableView_Margin;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kTableView_Margin)];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, kTableView_Margin)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

@end
