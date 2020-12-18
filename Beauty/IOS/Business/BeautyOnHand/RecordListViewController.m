//
//  RecordListViewController.m
//  GlamourPromise.Cosmetology.B
//
//  Created by GuanHui on 13-6-28.
//  Copyright (c) 2013年 ZhongHe. All rights reserved.
//

#import "RecordListViewController.h"
#import "RecordListCell.h"
#import "CustomerDoc.h"
#import "RecordDoc.h"
#import "GDataXMLNode.h"
#import "GPHTTPClient.h"
#import "SVProgressHUD.h"
#import "DEFINE.h"
#import "RecordEditViewController.h"
#import "NavigationView.h"
#import "AppDelegate.h"
#import "Tags.h"
#import "MJRefresh.h"
#import "DFFilterSet.h"
#import "FRNViewController.h"
#import "GPBHTTPClient.h"

#define ACCOUNT_RECORDFILTER [NSString stringWithFormat:@"%ld_RECORDFILTER", (long)ACC_ACCOUNTID]
typedef NS_ENUM(NSInteger, RECORDREFRESHTYPE)
{
    RECORDREFRESHHEADER,
    RECORDREFRESHFOOTER
};
@interface RecordListViewController ()<FRNViewDelegate>
@property (strong, nonatomic) AFHTTPRequestOperation *requestRecordInfoOperation;
@property (assign, nonatomic) NSInteger row_Selected;
@property (nonatomic, strong) DFFilterSet *filterContent;
@property (nonatomic, assign) NSInteger recordCount;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger recordPageIndex;
@property (nonatomic, strong) NSString *recordFileName;
@property (nonatomic, assign) BOOL   refresh;
@property (nonatomic, strong) NavigationView *navigationView;
@end

@implementation RecordListViewController
@synthesize recordArray;
@synthesize recordTableView;
@synthesize row_Selected;
@synthesize filterContent;
@synthesize recordCount;
@synthesize pageCount;
@synthesize recordPageIndex;
@synthesize recordFileName;
@synthesize refresh;
@synthesize navigationView;

- (NSString *)recordFileName
{
    recordFileName = @"RecordFilter";
    return recordFileName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationView = [[NavigationView alloc] initWithPosition:CGPointMake(0.0f, kORIGIN_Y + 5.0f) title:kMenu_Type == 0 ? @"与我相关的咨询" : @"咨询记录"];
    [self.view addSubview:navigationView];
    [self filterInit];
    if (kMenu_Type == 1){
        if ([[PermissionDoc sharePermission] rule_Record_Write])  {
            [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"icon_AddRecord"] selector:@selector(addRecordInfoAction)];
            [navigationView addButton1WithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(searchAction)];
        } else {
            [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(searchAction)];
        }
    } else {
        [navigationView addButtonWithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(searchAction)];
//        [navigationView addButton1WithTarget:self backgroundImage:[UIImage imageNamed:@"orderAdvancedFilterIcon"] selector:@selector(filterAction)];

    }
    
    [recordTableView setBackgroundView:nil];
    [recordTableView setBackgroundColor:[UIColor clearColor]];
    [recordTableView setAllowsSelection:NO];
    [recordTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [recordTableView setSeparatorColor:kTableView_LineColor];
    [recordTableView setShowsVerticalScrollIndicator:YES];
    [recordTableView setAutoresizingMask:UIViewAutoresizingNone];
    [self.recordTableView addHeaderWithTarget:self action:@selector(headerRefresh)];
    [self.recordTableView addFooterWithTarget:self action:@selector(footerRefresh)];


    if ((IOS7 || IOS8)) {
        recordTableView.frame = CGRectMake(5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 310.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  - 5.0f);
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else if (IOS6) {
        recordTableView.frame = CGRectMake(-5.0f, navigationView.frame.origin.y + navigationView.frame.size.height, 330.0f, kSCREN_BOUNDS.size.height - (HEIGHT_NAVIGATION_VIEW + 5.0f) - 64.0f  -5.0f);
    }
    self.refresh = YES;
    self.recordArray = [NSMutableArray array];
}

#pragma mark Filter init
- (void)filterInit
{
    self.filterContent = [[DFFilterSet alloc] init];
    if (kMenu_Type) { //右侧菜单
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.filterContent.customerID = appDelegate.customer_Selected.cus_ID;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.refresh == YES) {
        [self.recordTableView headerBeginRefreshing];
    } else {
        self.refresh = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark 刷新
- (void)headerRefresh
{
    self.recordPageIndex = 1;
    if (self.recordTableView.footerHidden) {
        self.recordTableView.footerHidden = NO;
    }
    [self requestRecordListByRecordID:0 PageIndex:self.recordPageIndex andPageSize:10 andType:RECORDREFRESHHEADER];
}

- (void)footerRefresh
{
    if (self.pageCount <= self.recordPageIndex || self.recordCount == recordArray.count) {
        [self.recordTableView footerEndRefreshing];
        self.recordTableView.footerHidden = YES;
        [SVProgressHUD showSuccessWithStatus:@"没有更多数据了"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    } else {
        self.recordPageIndex ++;
        RecordDoc *record = (RecordDoc *)[recordArray firstObject];
        [self requestRecordListByRecordID:record.RecordID PageIndex:self.recordPageIndex andPageSize:10 andType:RECORDREFRESHFOOTER];
    }
}

- (void)addRecordInfoAction
{
    row_Selected = -1;
    [self performSegueWithIdentifier:@"goRecordEditViewFromRecordListView" sender:self];
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [recordArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndentify = @"RecordListCell";
    RecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentify];
    if (cell == nil) {

        cell = [[RecordListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentify];
        if ((IOS7 || IOS8)) {
            cell.layer.masksToBounds = YES;
            cell.layer.cornerRadius = 4.0f;
            cell.layer.borderWidth  = 1.0f;
            cell.layer.borderColor  = BACKGROUND_COLOR_TITLE.CGColor;
        }
    }
    RecordDoc *recordDoc = [recordArray objectAtIndex:indexPath.section];
    [cell updateDate:recordDoc];
    [cell setDelegate:self];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecordDoc *recordDoc = [recordArray objectAtIndex:indexPath.section];
    return 50.0f + HEIGHT_CELL_TITLE * 2 + recordDoc.height_Suggestion + recordDoc.height_Problem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kTableView_Margin_TOP;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return kTableView_Margin_Bottom;
}

#pragma mark - RecordListCellDelegate
- (void)editeRecordInfoWithRecordListCell:(RecordListCell *)cell
{
    NSIndexPath *indexPath = [recordTableView indexPathForCell:cell];
    row_Selected = indexPath.section;
    [self performSegueWithIdentifier:@"goRecordEditViewFromRecordListView" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goRecordEditViewFromRecordListView"]) {
        if (row_Selected != -1) {
            RecordEditViewController *recordEditViewController = segue.destinationViewController;
            recordEditViewController.recordDoc = [recordArray objectAtIndex:row_Selected];
            recordEditViewController.isEditing = YES;
        } else {
            RecordEditViewController *recordEditViewController = segue.destinationViewController;
            recordEditViewController.isEditing = NO;
        }
    }
}

#pragma mark searchAction
- (void)searchAction
{
    FRNViewController *frnView = [[FRNViewController alloc] init];
    frnView.supFilter = self.filterContent;
    frnView.filterTitle = @"咨询筛选";
    frnView.filePath = self.recordFileName;
    frnView.delegate = self;
    [self.navigationController pushViewController:frnView animated:YES];
}
#pragma mark FrnViewDelegate
- (void)didnotRefresh
{
    self.refresh = NO;
}

#pragma mark - 接口
- (void)requestRecordListByRecordID:(NSInteger)recordID PageIndex:(NSInteger)pagIndex andPageSize:(NSInteger)pagSize andType:(RECORDREFRESHTYPE)type
{
    if (kMenu_Type == 1 && ((AppDelegate *)[[UIApplication sharedApplication] delegate]).customer_Selected.cus_ID == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AppDelegateNoChooserCustomerNotification object:nil];
        [self finishRefreshOfRecordList:type];
        return;
    }
    
    
    [SVProgressHUD showWithStatus:@"Loading"];
    
    NSString *par = [NSString stringWithFormat:@"{\"AccountID\":%ld,\"BranchID\":%ld,\"CompanyID\":%ld,\"RecordID\":%ld,\"FilterByTimeFlag\":%d,\"StartTime\":\"%@\",\"EndTime\":\"%@\",\"TagIDs\":\"%@\",\"PageIndex\":%ld,\"PageSize\":%ld,\"ResponsiblePersonID\":%ld,\"CustomerID\":%ld}", (long)ACC_ACCOUNTID , (kMenu_Type == 1 ? 0: ACC_BRANCHID), (long)ACC_COMPANTID, (long)recordID, filterContent.timeFlag, filterContent.startTime, filterContent.endTime, filterContent.tagIDs, (long)pagIndex, (long)pagSize, (long)filterContent.personID, (long)filterContent.customerID];

    _requestRecordInfoOperation = [[GPBHTTPClient sharedClient] requestUrlPath:@"/Record/getRecordListByAccountID" andParameters:par failureHandle:AFRequestFailureDefault WithSuccess:^(id json) {
        [SVProgressHUD dismiss];
        [ZWJson parseJsonWithJson:json showErrorMsg:NO success:^(id data, NSInteger code, id message) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            self.recordCount = [[data objectForKey:@"RecordCount"] integerValue];
            self.pageCount = [[data objectForKey:@"PageCount"] integerValue];
            if (self.pageCount > 0)
                [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)pagIndex, (long)self.pageCount]];
            else
                [self.navigationView setSecondLabelText:@""];
            
            if ([data objectForKey:@"RecordList"] != [NSNull null]) {
                NSArray *dataArray = [data objectForKey:@"RecordList"];
                [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    [tmpArray addObject:[[RecordDoc alloc] initWithDic:obj]];
                }];
            }
            if (type == RECORDREFRESHHEADER) {
                [recordArray removeAllObjects];
            }
            [recordArray addObjectsFromArray:tmpArray];
            [self finishRefreshOfRecordList:type];
            [self.recordTableView reloadData];
   
        } failure:^(NSInteger code, NSString *error) {
            [self finishRefreshOfRecordList:type];
            [SVProgressHUD showErrorWithStatus2:error touchEventHandle:^{}];
        }];
    } failure:^(NSError *error) {
        [self finishRefreshOfRecordList:type];
    }];
    
    /*
    _requestRecordInfoOperation = [[GPHTTPClient shareClient] requestGetRecordInfoByAccountIdWithFilterDoc:filterContent recordID:recordID  pageIndex:pagIndex andPageSize:pagSize success:^(id xml) {
         [SVProgressHUD dismiss];
        [ZWJson parseJsonWithXML:xml viewController:nil showSuccessMsg:NO showErrorMsg:YES success:^(id dataDic, id message) {
            NSMutableArray *tmpArray = [NSMutableArray array];
            self.recordCount = [[dataDic objectForKey:@"RecordCount"] integerValue];
            self.pageCount = [[dataDic objectForKey:@"PageCount"] integerValue];
            if (self.pageCount > 0)
                [self.navigationView setSecondLabelText:[NSString stringWithFormat:@"（第%ld/%ld页）",(long)pagIndex, (long)self.pageCount]];
            else
                [self.navigationView setSecondLabelText:@""];

            if ([dataDic objectForKey:@"RecordList"] != [NSNull null]) {
                NSArray *data = [dataDic objectForKey:@"RecordList"];
                [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    if (kMenu_Type) {
//                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//                        RecordDoc *recordInfo = [[RecordDoc alloc] initWithDic:obj];
//                        recordInfo.CustomerName = appDelegate.customer_Selected.cus_Name;
//                        [tmpArray addObject:recordInfo];
//                    } else {
                        [tmpArray addObject:[[RecordDoc alloc] initWithDic:obj]];
//                    }
                }];
            }
            if (type == RECORDREFRESHHEADER) {
                [recordArray removeAllObjects];
            }
            [recordArray addObjectsFromArray:tmpArray];
            [self finishRefreshOfRecordList:type];
            [self.recordTableView reloadData];
        } failure:^(NSString *error) {
            [self finishRefreshOfRecordList:type];
            [SVProgressHUD dismiss];
        }];
        
    } failure:^(NSError *error) {
        [SVProgressHUD dismiss];
        [self finishRefreshOfRecordList:type];
    }];
     */
    
}

- (void)finishRefreshOfRecordList:(RECORDREFRESHTYPE)type
{
    switch (type) {
        case RECORDREFRESHHEADER:
            [self.recordTableView headerEndRefreshing];
            break;
        case RECORDREFRESHFOOTER:
            [self.recordTableView footerEndRefreshing];
            break;
    }
}

@end

