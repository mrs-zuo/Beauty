//
//  ContactDetailViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by macmini on 13-9-11.
//  Copyright (c) 2013年 ace-009. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "DEFINE.h"
#import "NormalEditCell.h"
#import "ContentEditCell.h"
#import "ContactDoc.h"
#import "ScheduleDoc.h"
#import "EditContactDetailViewController.h"
#import "NavigationView.h"

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
    
    NavigationView *navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:@"编辑联系"];
    [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_Edit"] selector:@selector(goEditContactDetailPage)];
    [self.view addSubview:navigationView];
    
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.backgroundView = nil;
	myTableView.dataSource = self;
    myTableView.delegate = self;
    myTableView.showsHorizontalScrollIndicator = NO;
    myTableView.showsVerticalScrollIndicator = NO;
    myTableView.separatorColor = kTableView_LineColor;
    myTableView.autoresizesSubviews = UIViewAutoresizingNone;
    
    DLOG(@"%f", navigationView.frame.origin.y + navigationView.frame.size.height);
    if (IOS6)  {
      myTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - 64.0f - navigationView.frame.size.height - 5.0f);
    } else {
      myTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - 64.0f - navigationView.frame.size.height - 5.0f);
       myTableView.separatorInset = UIEdgeInsetsZero;
    }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
            [cell setContentText:contactDoc.cont_Remark];
            cell.contentEditText.returnKeyType = UIReturnKeyDefault;
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
        return contactDoc.height_cont_Remark;
    } else {
        return kTableView_HeightOfRow;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

- (void)goEditContactDetailPage
{
    [self performSegueWithIdentifier:@"goEditContactDetailViewFormContactDetailView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goEditContactDetailViewFormContactDetailView"]) {
        EditContactDetailViewController *editContactDetailViewController = segue.destinationViewController;
        editContactDetailViewController.contactDoc = contactDoc;
        editContactDetailViewController.delegate = self;
    }
}

#pragma mark - EditContactDetailViewControllerDelegate

- (void)editSuccessWithContactDoc:(ContactDoc *)newContactDoc
{
    contactDoc = newContactDoc;
    [myTableView reloadData];
}

@end
