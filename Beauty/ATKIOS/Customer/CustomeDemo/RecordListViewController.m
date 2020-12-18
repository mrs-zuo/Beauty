//
//  RecordListViewController.m
//  CustomeDemo
//
//  Created by macmini on 13-7-30.
//  Copyright (c) 2013年 MAC_Lion. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListCell.h"
#import "CustomerDoc.h"
#import "RecordDoc.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "GDataXMLDocument+ParseXML.h"
#import "QuestionPaper.h"
#import "QuestsListCell.h"
#import "SubjectListController.h"

@interface RecordListViewController ()
@property (strong,nonatomic) AFHTTPRequestOperation * requestRecordListOperation;

@end

@implementation RecordListViewController
@synthesize  recordArray;
@synthesize recordTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.isShowButton = YES;
    [super viewWillAppear:animated];
    [self requestRecordListByJson];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_requestRecordListOperation || [_requestRecordListOperation isExecuting]) {
        [_requestRecordListOperation cancel];
        _requestRecordListOperation = nil;
    }
    
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
}

- (void)awakeFromNib
{
    self.view.backgroundColor = kDefaultBackgroundColor;
}

static NSString *questsCell = @"questsCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [recordTableView setFrame:CGRectMake(0, 5, kSCREN_BOUNDS.size.width, kSCREN_BOUNDS.size.height  + 20  - 5)];
    if ((IOS7 || IOS8)) {
        self.edgesForExtendedLayout= UIRectEdgeNone;
    }
    self.title = @"专业记录";
    [recordTableView setAllowsSelection:YES];
    [recordTableView setShowsHorizontalScrollIndicator:NO];
    [recordTableView setShowsVerticalScrollIndicator:NO];
    [recordTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    recordTableView.separatorColor = kTableView_LineColor;
    [recordTableView setBackgroundColor:[UIColor clearColor]];
    
    [recordTableView registerClass:[QuestsListCell class] forCellReuseIdentifier:questsCell];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [recordArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestsListCell *cell = [tableView dequeueReusableCellWithIdentifier:questsCell];
    cell.paper = [self.recordArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [QuestsListCell computeQuestsListCellHeightWith:[self.recordArray objectAtIndex:indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.hidesBottomBarWhenPushed = YES;
    SubjectListController *subList = [[SubjectListController alloc] init];
    subList.quesPaper = [self.recordArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:subList animated:YES];
}

#pragma mark - 接口

-(void)requestRecordListByJson
{

    [SVProgressHUD showWithStatus:@"Loading..."];

    
    _requestRecordListOperation = [QuestionPaper requestAnswerPaperListCompletion:^(NSArray *array, NSString *mesg) {
        if (array) {
            recordArray = [array mutableCopy];
            [recordTableView reloadData];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showErrorWithStatus2:mesg];
        }
    }];
    
  }
-(void) deleteRecordInfoWithRecordListCell:(RecordListCell *)cell
{
    
}

-(void) editeRecordInfoWithRecordListCell:(RecordListCell *)cell
{
    
}

- (void)showMessage:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alertView show];
}
@end
